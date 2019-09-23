# frozen_string_literal: true

describe 'Config imports' do
  specify do
    class ImportedConfig < Qonfig::DataSet
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

    ImpConfig = ImportedConfig.new

    class UltraSimpleApplication
      include Qonfig::Imports

      import_settings(
        ImpConfig,
        'credentials.login',
        'credentials.password',
        'job_que.options',
        prefix: 'config_'
      )
    end

    app = UltraSimpleApplication.new
    # binding.pry

    simple_object = Object.new
    ImpConfig.export_settings(simple_object, 'credentials.login', prefix: 'config_')
    # binding.pry
  end
end
