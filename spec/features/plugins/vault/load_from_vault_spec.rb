# frozen_string_literal: true

describe 'Plugins(vault): Load from vault kv store', plugin: :vault do
  before { stub_const('VaultConfig', vault_class) }

  before { allow(Vault).to receive(:logical).and_return(logical_double) }

  let(:returned_data) do
    instance_double(Vault::Secret).tap do |instance|
      allow(instance).to receive(:data).and_return(secret_data)
    end
  end
  let(:logical_double) { instance_double(Vault::Logical) }
  let(:secret_data) { Hash[data: { kek: true, pek: 'cheburek', nested: Hash[key: 123] }] }

  let(:vault_class) do
    Class.new(Qonfig::DataSet) do
      load_from_vault 'kv/data/development'
    end
  end

  specify 'defines config object by vault instructions' do
    expect(Vault.logical).to receive(:read).with('kv/data/development').and_return(returned_data)

    VaultConfig.new.settings.tap do |conf|
      expect(conf).to have_attributes(kek: true, pek: 'cheburek')
      expect(conf.nested.key).to eq(123)
    end
  end

  context 'with not exist path' do
    let(:expected_error_args) do
      [Qonfig::FileNotFoundError, 'No such file or directory - Path kv/data/development not exist']
    end

    specify 'raises error' do
      expect(Vault.logical).to receive(:read).with('kv/data/development').and_return(nil)
      expect { VaultConfig.new }.to raise_error(*expected_error_args)
    end
  end

  context 'with Pathname at path argument' do
    let(:vault_class) do
      Class.new(Qonfig::DataSet) do
        load_from_vault Pathname('kv/data/development')
      end
    end

    specify 'converts it to string' do
      expect(Vault.logical).to receive(:read).with('kv/data/development').and_return(returned_data)

      VaultConfig.new
    end
  end

  context 'when strict set to false' do
    let(:vault_class) do
      Class.new(Qonfig::DataSet) do
        load_from_vault 'kv/data/development', strict: false
      end
    end

    specify "doesn't fail and uses empty config" do
      expect(Vault.logical).to receive(:read).with('kv/data/development').and_return(nil).twice

      expect { VaultConfig.new }.not_to raise_error
      expect(VaultConfig.new.to_h).to eq({})
    end
  end

  context 'when VaultError is raised' do
    let(:raised_error) { Vault::VaultError.new('Cool error') }

    specify 'raises VaultLoaderError' do
      expect(Vault.logical).to receive(:read).with('kv/data/development').and_raise(raised_error)

      expect { VaultConfig.new }.to raise_error(Qonfig::VaultLoaderError, 'Cool error')
    end
  end
end
