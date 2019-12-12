# frozen_string_literal: true

describe 'Save to .json (JSON)' do
  describe 'saving' do
    let(:config_file_name) { "#{SecureRandom.uuid}.json" }
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

    specify 'correctly represents config as JSON' do
      # NOTE: step 1) save config (each config's value can be pre-processed via block)
      config.save_to_json(path: config_file_path) do |value|
        value.is_a?(Proc) ? value.call : value
      end

      # NOTE: step 2) read saved file
      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~JSON.strip)
        {
         "sentry": {
          "user": "D@iVeR",
          "callback": "loaded"
         },
         "server_port": 123,
         "enabled": true
        }
      JSON
    end

    specify 'support for Pathname in file path' do
      config.save_to_json(path: Pathname.new(config_file_path)) do |value|
        value.is_a?(Proc) ? value.call : value
      end

      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~JSON.strip)
        {
         "sentry": {
          "user": "D@iVeR",
          "callback": "loaded"
         },
         "server_port": 123,
         "enabled": true
        }
      JSON
    end

    specify 'rewrites existing file' do
      config_a = Class.new(Qonfig::DataSet) do
        setting :kek, 'kek'
      end.new

      config_b = Class.new(Qonfig::DataSet) do
        setting :pek, 'pek'
      end.new

      # first save (initial write)
      config_a.save_to_json(path: config_file_path)
      file_data = File.read(config_file_path) # NOTE: initial path
      expect(file_data).to eq(<<~JSON.strip)
        {
         "kek": "kek"
        }
      JSON

      # subsequent save (rewrite)
      config_b.save_to_json(path: config_file_path)
      file_data = File.read(config_file_path) # NOTE: same path
      expect(file_data).to eq(<<~JSON.strip)
        {
         "pek": "pek"
        }
      JSON
    end
  end

  describe 'data representation' do
    let(:config_file_name) { "#{SecureRandom.uuid}.json" }
    let(:config_file_path) { SpecSupport.artifact_path(config_file_name) }
    let(:config_klass) do
      # rubocop:disable Style/BracesAroundHashParameters
      Class.new(Qonfig::DataSet) do
        setting :true_bollean, true
        setting :false_boolean, false
        setting :empty_object, {}
        setting :filled_object, { a: 1, b: nil, 'c' => true, d: '1', e: false }
        setting :null_data, nil
        setting :collection, ['1', 2, true, false, nil, [], {}]
      end
      # rubocop:enable Style/BracesAroundHashParameters
    end
    let(:config) { config_klass.new }

    specify 'correctly represents JSON data types' do
      # NOTE: step 1) save config
      config.save_to_json(path: config_file_path)

      # NOTE: step 2) read saved file
      file_data = File.read(config_file_path)

      expect(file_data).to eq(<<~JSON.strip)
        {
         "true_bollean": true,
         "false_boolean": false,
         "empty_object": {
         },
         "filled_object": {
          "a": 1,
          "b": null,
          "c": true,
          "d": "1",
          "e": false
         },
         "null_data": null,
         "collection": [  "1",  2,  true,  false,  null,  [],  {
          }]
        }
      JSON
    end
  end

  describe 'saving with native JSON settings' do
    let(:config_file_name) { "#{SecureRandom.uuid}.json" }
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

    specify '(SMOKE TEST) uses native JSON.generate(...) attributes (:options kwarg)' do
      config = config_klass.new
      config.save_to_json(path: config_file_path, options: {
        # NOTE: our options (save json representation in one line without spaces)
        indent: '', space: '', object_nl: ''
      })
      file_data = File.read(config_file_path)
      expect(file_data).to eq('{"server":{"address":"localhost","port":12345},"enabled":true}')
    end
  end
end
