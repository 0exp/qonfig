# frozen_string_literal: true

describe 'Save to .yml (YAML)' do
  describe 'saving' do
    let(:config_file_name) { "#{SecureRandom.uuid}.yml" }
    let(:config_file_path) { SpecSupport.artifact_path(config_file_name) }
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        setting :sentry do
          setting :user, 'D@iVeR'
          setting :callback, -> { 'loaded' }
        end

        setting :server_port, 123
        setting :enabled, true
      end
    end
    let(:config) { config_klass.new }

    context 'with key symbolization' do
      before do
        # NOTE: step 1) save config (each config's value can be pre-processed via block)
        config.save_to_yaml(path: config_file_path, symbolize_keys: true) do |value|
          value.is_a?(Proc) ? value.call : value
        end
      end

      specify 'correctly represents config as YAML' do
        # NOTE: step 2) read saved file
        file_data = File.read(config_file_path)

        expect(file_data).to eq(<<~YAML.strip << "\n")
          ---
          :sentry:
            :user: D@iVeR
            :callback: loaded
          :server_port: 123
          :enabled: true
        YAML
      end
    end

    context 'without key symbolization' do
      before do
        # NOTE: step 1) save config (each config's value can be pre-processed via block)
        config.save_to_yaml(path: config_file_path, symbolize_keys: false) do |value|
          value.is_a?(Proc) ? value.call : value
        end
      end

      specify 'correctly represents config as YAML' do
        # NOTE: step 2) read saved file
        file_data = File.read(config_file_path)

        expect(file_data).to eq(<<~YAML.strip << "\n")
          ---
          sentry:
            user: D@iVeR
            callback: loaded
          server_port: 123
          enabled: true
        YAML
      end
    end

    specify 'support for Pathname in file path' do
      config.save_to_yaml(path: Pathname.new(config_file_path), symbolize_keys: false) do |value|
        value.is_a?(Proc) ? value.call : value
      end

      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~YAML.strip << "\n")
        ---
        sentry:
          user: D@iVeR
          callback: loaded
        server_port: 123
        enabled: true
      YAML
    end

    specify 'rewrites existing file' do
      config_a = Class.new(Qonfig::DataSet) do
        setting :kek, 'kek'
      end.new

      config_b = Class.new(Qonfig::DataSet) do
        setting :pek, 'pek'
      end.new

      # first save (initial write)
      config_a.save_to_yaml(path: config_file_path)
      file_data = File.read(config_file_path) # NOTE: initial path
      expect(file_data).to eq(<<~YAML.strip << "\n")
        ---
        kek: kek
      YAML

      # subsequent save (rewrite)
      config_b.save_to_yaml(path: config_file_path)
      file_data = File.read(config_file_path) # NOTE: same path
      expect(file_data).to eq(<<~YAML.strip << "\n")
        ---
        pek: pek
      YAML
    end
  end

  describe 'data representation' do
    let(:config_file_name) { "#{SecureRandom.uuid}.yml" }
    let(:config_file_path) { SpecSupport.artifact_path(config_file_name) }
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        setting :true_bollean, true
        setting :false_boolean, false
        setting :empty_object, {}
        setting :filled_object, { a: 1, b: nil, 'c' => true, d: '1', e: false }
        setting :null_data, nil
        setting :collection, ['1', 2, true, false, nil, [], {}]
      end
    end
    let(:config) { config_klass.new }

    specify 'correctly represents YAML data types' do
      # NOTE: step 1) save config
      config.save_to_yaml(path: config_file_path)

      # NOTE: step 2) read saved file
      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~YAML.strip << "\n")
        ---
        true_bollean: true
        false_boolean: false
        empty_object: {}
        filled_object:
          :a: 1
          :b: ~
          c: true
          :d: '1'
          :e: false
        null_data: ~
        collection:
        - '1'
        - 2
        - true
        - false
        - ~
        - []
        - {}
      YAML
    end
  end

  describe 'saving with native YAML settings' do
    let(:config_file_name) { "#{SecureRandom.uuid}.yml" }
    let(:config_file_path) { SpecSupport.artifact_path(config_file_name) }
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        setting :server do
          setting :address, 'localhost'
          setting :port, 12_345
        end

        setting :enabled, true
      end
    end
    let(:config) { config_klass.new }

    specify '(SMOKE TEST) uses native YAML.dump(...) attributes (:options kwarg)' do
      config = config_klass.new
      config.save_to_yaml(path: config_file_path, options: {
        # NOTE: put current YAML version in start of file (in first line)
        indentation: 2, header: true
      })
      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~YAML.strip << "\n")
        %YAML 1.1
        ---
        server:
          address: localhost
          port: 12345
        enabled: true
      YAML
    end
  end
end
