# frozen_string_literal: true

describe 'Plugins(vault): expose vault', plugin: :vault do
  before { stub_const('VaultConfig', vault_class) }

  before { allow(Vault).to receive(:logical).and_return(logical_double) }

  let(:logical_double) { instance_double(Vault::Logical) }

  let(:returned_data) do
    instance_double(Vault::Secret).tap do |instance|
      allow(instance).to receive(:data).and_return(secret_data)
    end
  end
  let(:secret_data) do
    { data: { production: { kek: 'pek', cheburek: true }, other_key: "<%= 1 + 1 %>" } }
  end

  let(:vault_class) do
    Class.new(Qonfig::DataSet) do
      setting :based_on_path do
        expose_vault 'kv/data/path_based', via: :path, env: :production
      end

      setting :based_on_env_key do
        expose_vault 'kv/data/env_key', via: :env_key, env: 'production'
      end
    end
  end

  specify 'defines config object by vault instructions and specific environment settings' do
    expect(Vault.logical).to(
      receive(:read).with('kv/data/production/path_based').and_return(returned_data)
    )
    expect(Vault.logical).to receive(:read).with('kv/data/env_key').and_return(returned_data)

    VaultConfig.new.settings.tap do |conf|
      expect(conf.based_on_path.other_key).to eq(2)
      expect(conf.based_on_path.production).to be_a(Qonfig::Settings)
      expect(conf.based_on_env_key).to have_attributes(kek: 'pek', cheburek: true)
    end
  end

  context 'when provided env argument is an Object' do
    specify 'raises an error' do
      expect do
        Class.new(Qonfig::DataSet) do
          expose_vault 'kv/data/path_based', via: Object.new, env: :production
        end
      end.to raise_error(Qonfig::ArgumentError)
    end
  end

  context 'when provided via argument is an Object' do
    specify 'raises an error' do
      expect do
        Class.new(Qonfig::DataSet) do
          expose_vault 'kv/data/path_based', via: :path, env: Object.new
        end
      end.to raise_error(Qonfig::ArgumentError)
    end
  end

  context 'when provided via is not supported' do
    specify 'raises an error' do
      expect do
        Class.new(Qonfig::DataSet) do
          expose_vault 'kv/data/path_based', via: :kek, env: :production
        end
      end.to raise_error(Qonfig::ArgumentError)
    end
  end

  context 'when provided env is empty' do
    specify 'raises an error' do
      expect do
        Class.new(Qonfig::DataSet) do
          expose_vault 'kv/data/path_based', via: :path, env: ''
        end
      end.to raise_error(Qonfig::ArgumentError)
    end
  end

  context "when provided key doesn't exist" do
    let(:vault_class) do
      Class.new(Qonfig::DataSet) do
        expose_vault 'kv/data/env_key', via: :env_key, env: 'kekduction'
      end
    end

    specify 'raises an error' do
      expect(Vault.logical).to receive(:read).with('kv/data/env_key').and_return(returned_data)

      expect { VaultConfig.new }.to raise_error(/does not contain settings with <kekduction>/)
    end
  end

  context 'with not strict mode' do
    let(:vault_class) do
      Class.new(Qonfig::DataSet) do
        setting :based_on_env_key do
          expose_vault 'kv/data/env_key', via: :env_key, env: 'production', strict: false
        end
      end
    end

    let(:secret_data) { Hash[] }

    specify "doesn't fail and uses empty config" do
      expect(Vault.logical).to receive(:read).with('kv/data/env_key').and_return(returned_data)

      conf = nil
      expect { conf = VaultConfig.new }.not_to raise_error
      expect(conf.to_h['based_on_env_key']).to be_empty
    end
  end
end
