# frozen_string_literal: true

# rubocop:disable Metrics/LineLength, Style/Semicolon
shared_examples 'load setting values from file by macros' do |file_name:, file_with_env_name:, file_format:|
  specify "load values from #{file_format} file over existing (non-strict, explicit format, no env)" do
    config = Class.new(Qonfig::DataSet) do
      values_file file_name, format: file_format

      setting :enabled, true
      setting :adapter, 'undefined'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify "load values from #{file_format} file (non-strict, dynamic format, no env)" do
    config = Class.new(Qonfig::DataSet) do
      values_file file_name

      setting :enabled, nil
      setting :adapter, 'no-adapter'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify 'can expose environment-based settings defined by key' do
    test_config = Class.new(Qonfig::DataSet) do
      values_file file_with_env_name, expose: :test

      setting :enabled, true
      setting :adapter, 'resque'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    expect(test_config.settings.enabled).to eq(false)
    expect(test_config.settings.adapter).to eq('sidekiq')
    expect(test_config.settings.credentials.user).to eq('D@iVeR')
    expect(test_config.settings.credentials.timeout).to eq(321)

    production_config = Class.new(Qonfig::DataSet) do
      values_file file_with_env_name, expose: :production

      setting :enabled, true
      setting :adapter, 'resque'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    expect(production_config.settings.enabled).to eq(true)
    expect(production_config.settings.adapter).to eq('que')
    expect(production_config.settings.credentials.user).to eq('0exp')
    expect(production_config.settings.credentials.timeout).to eq(123)
  end

  specify 'does not fails when file does not exist (default non-strict behavior)' do
    config = nil

    expect do
      config = Class.new(Qonfig::DataSet) do
        values_file SpecSupport.fixture_path('values_file', "atata.#{file_format}")

        setting :enabled, true
        setting :adapter, 'undefined'
        setting(:credentials) { setting :user; setting :timeout }
      end.new
    end.not_to raise_error

    expect do
      # NOTE: (quietly :)) check that we can use expose param too :)
      Class.new(Qonfig::DataSet) do
        values_file SpecSupport.fixture_path('values_file', "atata.#{file_format}"), expose: :test
      end.new
    end.not_to raise_error

    # NOTE: check that original settings has original values
    expect(config.settings.enabled).to eq(true)
    expect(config.settings.adapter).to eq('undefined')
    expect(config.settings.credentials.user).to eq(nil)
    expect(config.settings.credentials.timeout).to eq(nil)
  end

  specify 'fails when file does not exist (with configured strict behavior)' do
    config_klass = Class.new(Qonfig::DataSet) do
      values_file SpecSupport.fixture_path('values_file', "atata.#{file_format}"), strict: true

      setting :enabled, true
      setting :adapter, 'undefined'
      setting(:credentials) { setting :user; setting :timeout }
    end

    expect { config_klass.new }.to raise_error(Qonfig::FileNotFoundError)
  end

  specify 'fails when method attributes are incorrect' do
    # incorrect file path
    expect do
      Class.new(Qonfig::DataSet) { values_file 123 }
    end.to raise_error(Qonfig::ArgumentError)

    # incorrect :format
    expect do
      Class.new(Qonfig::DataSet) { values_file file_name, format: 123 }
    end.to raise_error(Qonfig::ArgumentError)

    # incorrect :expose
    expect do
      Class.new(Qonfig::DataSet) { values_file file_name, expose: 123 }
    end.to raise_error(Qonfig::ArgumentError)

    # incorrect :strict
    expect do
      Class.new(Qonfig::DataSet) { values_file file_name, strict: 123 }
    end.to raise_error(Qonfig::ArgumentError)
  end
end
# rubocop:enable Metrics/LineLength, Style/Semicolon
