# frozen_string_literal: true

describe 'Import settings as access methods to a class' do
  let(:config) do
    Qonfig::DataSet.build do
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
    end
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
      import_settings(
        AppConfig,
        mappings: { job_server: 'job_que.options.server' },
        prefix: 'config_'
      )
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
      config.job_que.options.server = 'aws'
    end

    expect(app_with_configs.user_password).to eq('tratata123')
    expect(app_with_configs.user_login).to eq('0exp')
    expect(app_with_configs.job_adapter).to eq(:resque)
    expect(app_with_configs.config_job_server).to eq('aws')
  end

  specify 'you can mix explicit keys, mappings and prefix' do
    class MixedImportCheckApp
      include Qonfig::Imports

      import_settings(
        AppConfig,
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

    expect(app_with_configs.config_passwd).to eq('test123')
    expect(app_with_configs.config_admn).to eq(true)
    expect(app_with_configs.config_credentials).to match(
      'admin'    => true,
      'login'    => 'D@iVeR',
      'password' => 'test123'
    )
    expect(app_with_configs.config_options).to eq(
      'server'   => 'cloud',
      'auto_run' => true
    )
  end

  specify 'raw setting import (Qonfig::Settings object - or <value>)' do
    # NOTE: default non-raw import (import nested settings as hashes)
    class NonRawImportCheckApp
      include Qonfig::Imports
      import_settings(AppConfig, 'job_que', mappings: { creds: 'credentials' }, raw: false)
    end

    app_with_configs = NonRawImportCheckApp.new

    expect(app_with_configs).to respond_to(:job_que)
    expect(app_with_configs).to respond_to(:creds)
    expect(app_with_configs.creds).to be_a(Hash)
    expect(app_with_configs.job_que).to be_a(Hash)
    expect(app_with_configs.creds).to match(
      'admin' => true,
      'login' => 'D@iVeR',
      'password' => 'test123'
    )
    expect(app_with_configs.job_que).to match(
      'adapter' => :sidekiq,
      'options' => {
        'server' => 'cloud',
        'auto_run' => true
      }
    )

    # NOTE: raw import (import nested settings as Qonfig::Settings objects)
    class RawImportCheckApp
      include Qonfig::Imports
      import_settings(AppConfig, 'job_que', mappings: { creds: 'credentials' }, raw: true)
    end

    app_with_configs = RawImportCheckApp.new

    expect(app_with_configs).to respond_to(:job_que)
    expect(app_with_configs).to respond_to(:creds)
    expect(app_with_configs.job_que).to be_a(Qonfig::Settings)
    expect(app_with_configs.creds).to be_a(Qonfig::Settings)
    expect(app_with_configs.job_que.adapter).to eq(:sidekiq)
    expect(app_with_configs.job_que.options.server).to eq('cloud')
    expect(app_with_configs.job_que.options.auto_run).to eq(true)
    expect(app_with_configs.creds.admin).to eq(true)
    expect(app_with_configs.creds.login).to eq('D@iVeR')
    expect(app_with_configs.creds.password).to eq('test123')
  end

  specify 'incorrect attributes' do
    expect do
      Class.new do
        include Qonfig::Imports
        import_settings(123)
      end
    end.to raise_error(Qonfig::IncompatibleImportedConfigError)

    expect do
      Class.new do
        include Qonfig::Imports
        import_settings(AppConfig, 'kek.pek', prefix: Object.new)
      end
    end.to raise_error(Qonfig::IncorrectImportPrefixError)

    expect do
      Class.new do
        include Qonfig::Imports
        import_settings(AppConfig, 'pek.kek', 'kek.pek', Object.new)
      end
    end.to raise_error(Qonfig::IncorrectImportKeyError)

    expect do
      Class.new do
        include Qonfig::Imports
        import_settings(AppConfig, 'kek.pek', mappings: {
          Object.new => 'kek.pek'
        })
      end
    end.to raise_error(Qonfig::IncorrectImportMappingsError)

    expect do
      Class.new do
        include Qonfig::Imports
        import_settings(AppConfig, 'kek.pek', mappings: {
          some_method: Object.new
        })
      end
    end.to raise_error(Qonfig::IncorrectImportMappingsError)
  end
end
