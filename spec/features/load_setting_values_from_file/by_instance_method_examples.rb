# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Style/Semicolon
shared_examples 'load setting values from file by instance methods' do |file_name:, file_with_env_name:, file_format:, load_by:|
  specify "load values from #{file_format} file over existing (strict, explicit format, no env)" do
    config = Class.new(Qonfig::DataSet) do
      setting :enabled, true
      setting :adapter, 'undefined'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    config.public_send(load_by, file_name)

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify "load values from #{file_format} file (strict, dynamic format, no env)" do
    config = Class.new(Qonfig::DataSet) do
      setting :enabled, nil
      setting :adapter, 'no-adapter'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    config.load_from_file(file_name)

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify 'support for Pathname in file path' do
    config = Class.new(Qonfig::DataSet) do
      setting :enabled, true
      setting :adapter, 'undefined'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    config.public_send(load_by, Pathname.new(file_name))

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify 'provides "do |config|" ability' do
    config = Class.new(Qonfig::DataSet) do
      setting :enabled, nil
      setting :adapter, 'no-adapter'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    config.public_send(load_by, file_name) do |conf|
      conf.enabled = true
      conf.credentials.user = 'do_config'
      conf.credentials.timeout = 0
    end

    expect(config.settings.enabled).to eq(true) # from do-config
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('do_config') # from do-config
    expect(config.settings.credentials.timeout).to eq(0) # from do-config

    config.public_send(load_by, file_with_env_name, expose: :test) do |conf|
      conf.credentials.user = 'super_expose_test'
    end

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('super_expose_test') # from do-config
    expect(config.settings.credentials.timeout).to eq(321)

    config.public_send(load_by, file_with_env_name, expose: :production) do |conf|
      conf.adapter = 'overwatch'
    end

    expect(config.settings.enabled).to eq(true)
    expect(config.settings.adapter).to eq('overwatch') # from do-config
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify 'can expose environment-based settings defined by key' do
    config = Class.new(Qonfig::DataSet) do
      setting :enabled, true
      setting :adapter, 'resque'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    config.public_send(load_by, file_with_env_name, expose: :test)

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('D@iVeR')
    expect(config.settings.credentials.timeout).to eq(321)

    config.public_send(load_by, file_with_env_name, expose: :production)

    expect(config.settings.enabled).to eq(true)
    expect(config.settings.adapter).to eq('que')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  specify 'fails when file does not exist (default strict behavior (strict: true))' do
    config = nil
    nonexistent_file = SpecSupport.fixture_path('values_file', "atata.#{file_format}")

    expect do
      config = Class.new(Qonfig::DataSet) do
        setting :enabled, true
        setting :adapter, 'undefined'
        setting(:credentials) { setting :user; setting :timeout }
      end.new

      config.public_send(load_by, nonexistent_file)
    end.to raise_error(Qonfig::FileNotFoundError)

    # NOTE: check that original settings has original values
    expect(config.settings.enabled).to eq(true)
    expect(config.settings.adapter).to eq('undefined')
    expect(config.settings.credentials.user).to eq(nil)
    expect(config.settings.credentials.timeout).to eq(nil)
  end

  specify 'does not fail when file does not exist and strict behaviour is disabled (strict: false)' do
    nonexistent_file = SpecSupport.fixture_path('values_file', "atata.#{file_format}")

    config = Class.new(Qonfig::DataSet) do
      setting :enabled, true
      setting :adapter, 'undefined'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    expect { config.public_send(load_by, nonexistent_file, strict: false) }.not_to raise_error

    # NOTE: check that original settings has original values
    expect(config.settings.enabled).to eq(true)
    expect(config.settings.adapter).to eq('undefined')
    expect(config.settings.credentials.user).to eq(nil)
    expect(config.settings.credentials.timeout).to eq(nil)
  end

  specify 'fails when method attributes are incorrect' do
    config = Class.new(Qonfig::DataSet) do
      setting :enabled, true
      setting :adapter, 'undefined'
      setting(:credentials) { setting :user; setting :timeout }
    end.new

    # incorrect file path
    expect do
      config.public_send(load_by, 123)
    end.to raise_error(Qonfig::ArgumentError)

    # incorrect :expose
    expect do
      config.public_send(load_by, file_name, expose: 123)
    end.to raise_error(Qonfig::ArgumentError)

    # incorrect :strict
    expect do
      config.public_send(load_by, file_name, strict: 123)
    end.to raise_error(Qonfig::ArgumentError)
  end
end
# rubocop:enable Layout/LineLength, Style/Semicolon
