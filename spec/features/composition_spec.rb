# frozen_string_literal: true

describe 'Composition' do
  specify 'config composition (multiple inheritance)' do
    class WebAPIConfig < Qonfig::DataSet
      setting :version, '0.1.0'
      setting :header, 'app.vendor'
      setting :strategy do
        setting :format, :json
      end
    end

    class ServerConfig < Qonfig::DataSet
      setting :port, 8080
      setting :host, '0.0.0.0'
      setting :enable_middlewares, true
    end

    class DataBaseConfig < Qonfig::DataSet
      setting :username, 'kek'
      setting :password, 'pek'
      setting :connection do
        setting :host, 'google.com'
        setting :port, 12_345
      end
    end

    class ProjectConfig < Qonfig::DataSet
      compose ServerConfig

      setting :api do
        compose WebAPIConfig
      end

      setting :db do
        compose DataBaseConfig
      end

      setting :limits do
        setting :withdraw, 1_000_000
        setting :deposit, 3_000_000
      end
    end

    config = ProjectConfig.new

    config.configure do |conf|
      expect(conf.api.version).to eq('0.1.0')
      expect(conf.api.header).to eq('app.vendor')
      expect(conf.db.username).to eq('kek')
      expect(conf.db.password).to eq('pek')
      expect(conf.port).to eq(8080)
      expect(conf.host).to eq('0.0.0.0')
      expect(conf.enable_middlewares).to eq(true)
      expect(conf.limits.withdraw).to eq(1_000_000)
      expect(conf.limits.deposit).to eq(3_000_000)

      expect(conf[:api][:version]).to eq('0.1.0')
      expect(conf[:api][:header]).to eq('app.vendor')
      expect(conf[:db][:username]).to eq('kek')
      expect(conf[:db][:password]).to eq('pek')
      expect(conf[:port]).to eq(8080)
      expect(conf[:host]).to eq('0.0.0.0')
      expect(conf[:enable_middlewares]).to eq(true)
      expect(conf[:limits][:withdraw]).to eq(1_000_000)
      expect(conf[:limits][:deposit]).to eq(3_000_000)

      # reconfgure
      conf.api.version = '0.2.0'
      conf.api.header = 'app.super.vendor'
      conf.db.username = 'che'
      conf.db.password = 'burek'
      conf.port = 8081
      conf.host = 'app.google.com'
      conf.enable_middlewares = false
      conf.limits.withdraw = 0
      conf.limits.deposit = 1_000

      expect(conf.api.version).to eq('0.2.0')
      expect(conf.api.header).to eq('app.super.vendor')
      expect(conf.db.username).to eq('che')
      expect(conf.db.password).to eq('burek')
      expect(conf.port).to eq(8081)
      expect(conf.host).to eq('app.google.com')
      expect(conf.enable_middlewares).to eq(false)
      expect(conf.limits.withdraw).to eq(0)
      expect(conf.limits.deposit).to eq(1_000)

      expect(conf[:api][:version]).to eq('0.2.0')
      expect(conf[:api][:header]).to eq('app.super.vendor')
      expect(conf[:db][:username]).to eq('che')
      expect(conf[:db][:password]).to eq('burek')
      expect(conf[:port]).to eq(8081)
      expect(conf[:host]).to eq('app.google.com')
      expect(conf[:enable_middlewares]).to eq(false)
      expect(conf[:limits][:withdraw]).to eq(0)
      expect(conf[:limits][:deposit]).to eq(1_000)
    end
  end
end
