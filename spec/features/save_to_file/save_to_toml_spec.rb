# frozen_string_literal: true

describe 'Save to .toml (Toml)' do
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
        setting :cost, 123.456
        setting :enabled, true

        setting :sub_configurations, [
          { 'server' => 'google',   'ping' => false },
          { 'server' => 'shoklude', 'ping' => true  },
        ]
      end
    end
    let(:config) { config_klass.new }

    before do
      config.save_to_toml(path: config_file_path) do |value|
        value.is_a?(Proc) ? value.call : value
      end
    end

    specify 'correctly represents config as YAML' do
      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~TOML.strip << "\n")
        cost = 123.456
        enabled = true
        server_port = 123
        [sentry]
        callback = "loaded"
        user = "D@iVeR"
        [[sub_configurations]]
        ping = false
        server = "google"
        [[sub_configurations]]
        ping = true
        server = "shoklude"
      TOML
    end

    specify 'rewrites existing file' do
      config_a = Class.new(Qonfig::DataSet) do
        setting :kek, 'kek'
      end.new

      config_b = Class.new(Qonfig::DataSet) do
        setting :pek, 'pek'
      end.new

      # first save (initial write)
      config_a.save_to_toml(path: config_file_path)
      file_data = File.read(config_file_path) # NOTE: initial path
      expect(file_data).to eq(<<~TOML.strip << "\n")
        kek = "kek"
      TOML

      # subsequent save (rewrite)
      config_b.save_to_toml(path: config_file_path)
      file_data = File.read(config_file_path) # NOTE: same path
      expect(file_data).to eq(<<~TOML.strip << "\n")
        pek = "pek"
      TOML
    end
  end

  describe 'data representation' do
    let(:config_file_name) { "#{SecureRandom.uuid}.yml" }
    let(:config_file_path) { SpecSupport.artifact_path(config_file_name) }
    let(:config_klass) do
      # rubocop:disable Style/BracesAroundHashParameters
      Class.new(Qonfig::DataSet) do
        setting :true_bollean, true
        setting :false_boolean, false
        setting :empty_object, {}
        setting :filled_object, { 'a' => 1, 'b' => 2, 'c' => 3 }
        setting :filled_symbolized_object, { a: 1, b: 2, c: 3 }
        setting :multi_hash, { a: 1, 'b' => 2 }
        # setting :filled_object, { a: 1, b: nil, 'c' => true, d: '1', e: false }
        # setting :null_data, nil
        # setting :collection, ['1', 2, true, false, nil, [], {}]
      end
      # rubocop:enable Style/BracesAroundHashParameters
    end
    let(:config) { config_klass.new }

    specify 'correctly represents YAML data types' do
      # NOTE: step 1) save config
      config.save_to_toml(path: config_file_path)

      # NOTE: step 2) read saved file
      file_data = File.read(config_file_path)

      binding.pry

      # expect(file_data).to eq(<<~YAML.strip << "\n")
      #   ---
      #   true_bollean: true
      #   false_boolean: false
      #   empty_object: {}
      #   filled_object:
      #     :a: 1
      #     :b: ~
      #     c: true
      #     :d: '1'
      #     :e: false
      #   null_data: ~
      #   collection:
      #   - '1'
      #   - 2
      #   - true
      #   - false
      #   - ~
      #   - []
      #   - {}
      # YAML
    end
  end

  # describe 'saving with native YAML settings' do
  #   let(:config_file_name) { "#{SecureRandom.uuid}.yml" }
  #   let(:config_file_path) { SpecSupport.artifact_path(config_file_name) }
  #   let(:config_klass) do
  #     Class.new(Qonfig::DataSet) do
  #       setting :server do
  #         setting :address, 'localhost'
  #         setting :port, 12_345
  #       end

  #       setting :enabled, true
  #     end
  #   end
  #   let(:config) { config_klass.new }

  #   specify '(SMOKE TEST) uses native YAML.dump(...) attributes (:options kwarg)' do
  #     config = config_klass.new
  #     config.save_to_yaml(path: config_file_path, options: {
  #       # NOTE: put current YAML version in start of file (in first line)
  #       indentation: 2, header: true
  #     })
  #     file_data = File.read(config_file_path)

  #     expect(file_data).to eq(<<~YAML.strip << "\n")
  #       %YAML 1.1
  #       ---
  #       server:
  #         address: localhost
  #         port: 12345
  #       enabled: true
  #     YAML
  #   end
  # end
end
