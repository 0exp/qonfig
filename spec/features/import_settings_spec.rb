# frozen_string_literal: true

describe 'Import settings as access methods to a class' do
  let(:config) do
    Class.new(Qonfig::DataSet) do
      setting :credentials do
        setting :admin, true
        setting :login, 'D@iVeR'
        setting :password, 'test123'
      end

      setting :job_que do
        setting :adapter, :sidekiq
        setting :options do
          setting :server, 'cloud'
          setting :auto_run, true
        end
      end
    end.new
  end

  before { stub_const('AppConfig', config) }

  specify 'each required setting is imported as an instance method with access to sliced value' do
    class SimpleImportCheckApp
      include Qonfig::Imports

      import_settings(AppConfig, 'credentials.login', 'job_que.options')
    end

    app_with_configs = SimpleImportCheckApp.new

    # NOTE: new methods
    expect(app_with_configs).to respond_to(:login)
    expect(app_with_configs).to respond_to(:options)

    # NOTE: get config values
    expect(app_with_configs.login).to eq('D@iVeR')
    expect(app_with_configs.options).to match('server' => 'cloud', 'auto_run' => true)

    # NOTE: change config options and try to get them from app_with_config again
    AppConfig.configure do |config|
      config.credentials.login = '0exp'
      config.job_que.options.server = 'localhost'
      config.job_que.options.auto_run = false
    end

    # NOTE: check cahnged configs
    expect(app_with_configs.login).to eq('0exp')
    expect(app_with_configs.options).to match('server' => 'localhost', 'auto_run' => false)
  end

  specify 'you can prefix imported methods' do
    class PrefixImportCheckApp
      include Qonfig::Imports

      import_settings(AppConfig, 'credentials.password', 'credentials.login', prefix: 'config_')
    end

    app_with_configs = PrefixImportCheckApp.new

    expect(app_with_configs).to respond_to(:config_login)
    expect(app_with_configs).to respond_to(:config_password)

    expect(app_with_configs.config_login).to eq('D@iVeR')
    expect(app_with_configs.config_password).to eq('test123')
  end

  specify 'you can define your own method name for each imported setting' do
    class ImportWithMappingsApp
      include Qonfig::Imports

      # NOTE: without prefix
      import_settings(AppConfig, mappings: {
        user_password: 'credentials.password',
        user_login: 'credentials.login',
        job_adapter: 'job_que.adapter'
      })

      # NOTE: with prefix
      import_settings(AppConfig, mappings: { job_server: 'cloud' }, prefix: 'config_')
    end

    app_with_configs = ImportWithMappingsApp.new

    expect(app_with_configs).to respond_to(:user_password)
    expect(app_with_configs).to respond_to(:user_login)
    expect(app_with_configs).to respond_to(:job_adapter)
    expect(app_with_configs).to respond_to(:config_job_server)

    expect(app_with_configs.user_password).to eq('test123')
    expect(app_with_configs.user_login).to eq('D@iVeR')
    expect(app_with_configs.job_adapter).to eq(:sidekiq)
    expect(app_with_configs.config_job_server).to eq('cloud')


    # NOTE: change cofnigs and check that each new method returns the real config value
    AppConfig.configure do |config|
      config.credentials.password = 'tratata123'
      config.credentials.login = '0exp'
      config.job_que.adapter = :resque
      config.job_que.server = 'aws'
    end

    expect(app_with_configs.user_password).to eq('tratata123')
    expect(app_with_configs.user_login).to eq('0exp')
    expect(app_with_configs.job_adapter).to eq(:resque)
    expect(app_with_configs.config_job_server).to eq('aws')
  end

  specify 'you can mix explicit keys, mappings and prefix' do
    class MixedImportCheckApp
      include Qonfig::Imports

      import_settings(AppConfig,
        'credentials', 'job_que.options', # simple keys
        mappings: { passwd: 'credentials.password', admn: 'credentials.admin' }, # mappings
        prefix: 'config_' # and prefix
      )
    end

    app_with_configs = MixedImportCheckApp.new

    expect(app_with_configs).to respond_to(:config_passwd)
    expect(app_with_configs).to respond_to(:config_admn)
    expect(app_with_configs).to respond_to(:config_credentials)
    expect(app_with_configs).to respond_to(:config_options)

    expdct(app_with_configs.config_passwd).to eq('test123')
    expect(app_with_configs.config_admn).to eq(true)
    expect(app_with_configs.config_credentials).to match(
      'admin'    => true,
      'login'    => 'D@iVeR',
      'password' => 'test123'
    )
    expect(app_with_configs.config_options).to eq(
      'server'   => :sidekiq,
      'auto_run' => true
    )
  end

  describe 'invalid imports' do

  end
end
