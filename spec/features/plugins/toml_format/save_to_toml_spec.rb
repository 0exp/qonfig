# frozen_string_literal: true

describe 'Save to .toml (Toml)' do
  before { Qonfig.plugin(:toml_format) }

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
          { 'server' => 'shoklude', 'ping' => true  }
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

    context 'config with supported toml types' do
      let(:config) do
        # rubocop:disable Style/BracesAroundHashParameters
        Class.new(Qonfig::DataSet) do
          setting :true_boolean, true
          setting :false_boolean, false
          setting :empty_object, {}
          setting :filled_object, { a: 1, b: nil, 'c' => true, d: '1', e: false }
          setting :null_data, nil
          setting :float_value, 123.456
          setting :collection, [%w[1 2], [3, 4], [true, false], []]
        end.new
        # rubocop:enable Style/BracesAroundHashParameters
      end

      specify 'correctly represents YAML data types' do
        # NOTE: step 1) save config
        config.save_to_toml(path: config_file_path)

        # NOTE: step 2) read saved file
        file_data = File.read(config_file_path)

        expect(file_data).to eq(<<~TOML.strip << "\n")
          collection = [["1", "2"], [3, 4], [true, false], []]
          false_boolean = false
          float_value = 123.456
          true_boolean = true
          [empty_object]
          [filled_object]
          a = 1
          c = true
          d = "1"
          e = false
        TOML
      end
    end

    context 'config with unsupported toml types' do
      let(:config) do
        Class.new(Qonfig::DataSet) do
          setting :collection, [[3, 4], %w[6 4], nil]
        end.new
      end

      specify 'fails with parser error' do
        expect { config.save_to_toml(path: config_file_path) }.to raise_error(::TomlRB::ParseError)
      end
    end
  end
end
