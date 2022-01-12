# frozen_string_literal: true

require_relative 'context'

describe 'Plugins(vault): Load yaml from vault kv store', plugin: :vault do
  include_context 'vault context'

  before { stub_const('VaultConfig', vault_class) }

  let(:returned_data) do
    instance_double(Vault::Secret).tap do |instance|
      allow(instance).to receive(:data).and_return(secret_data)
    end
  end

  let(:secret_data) { Hash['file.yml': yaml_content] }
  let(:yaml_content) { YAML.dump(kek: 'pek') }

  let(:vault_class) do
    Class.new(Qonfig::DataSet) do
      load_from_yaml 'vault://kv/data/development/file.yml', use_kv: false
    end
  end

  specify 'defines config object by yaml instructions' do
    expect(Vault.logical).to receive(:read).with('kv/data/development').and_return(returned_data)
    VaultConfig.new.settings.tap do |conf|
      expect(conf).to have_attributes(kek: 'pek')
    end
  end

  context "when key doesn't exist" do
    let(:secret_data) { Hash[data: { 'other_file.yml': yaml_content }] }

    specify 'raises error' do
      expect(Vault.logical).to receive(:read).with('kv/data/development').and_return(returned_data)
      expect { VaultConfig.new }.to raise_error(Qonfig::FileNotFoundError)
    end
  end

  context 'when version specified' do
    let(:vault_class) do
      Class.new(Qonfig::DataSet) do
        load_from_yaml 'vault://kv/data/development/file.yml', version: 2
      end
    end

    let(:expected_path) { 'data/development' }

    specify 'uses kv store engine' do
      expect(Vault).to receive(:kv).with('kv').and_return(kv_double)
      expect(kv_double).to receive(:read).with(expected_path, 2).and_return(returned_data)

      VaultConfig.new.settings.tap do |conf|
        expect(conf).to have_attributes(kek: 'pek')
      end
    end
  end
end
