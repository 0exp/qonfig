# frozen_string_literal: true

describe 'Inheritance' do
  specify 'config inheritance works correclty' do
    class FrameworkConfig < Qonfig::DataSet
      setting :version, '0.1.0'

      setting :defaults do
        setting :path, '/a/b/c'
      end
    end

    class UnknownConfig < Qonfig::DataSet
      setting :unkown_data, true
    end

    class SharedConfig < Qonfig::DataSet
      setting :google_api do
        setting :token, 'test-google-api'
      end

      setting :admin_access_required, false

      compose FrameworkConfig
    end

    class ClientConfig < SharedConfig
      compose UnknownConfig

      setting :google_api do
        setting :client_token, 'client-test-google-api'
      end

      setting :defaults, nil
    end

    client_config = ClientConfig.new

    client_config.settings.tap do |config|
      # own settings
      expect(config.google_api.client_token).to eq('client-test-google-api')
      expect(config.defaults).to eq(nil)
      expect(config[:google_api][:client_token]).to eq('client-test-google-api')
      expect(config[:defaults]).to eq(nil)

      # inherited settings
      expect(config.google_api.token).to eq('test-google-api')
      expect(config.admin_access_required).to eq(false)
      expect(config[:google_api][:token]).to eq('test-google-api')
      expect(config[:admin_access_required]).to eq(false)

      # inherited composition
      expect(config.version).to eq('0.1.0')
      expect(config[:version]).to eq('0.1.0')

      # own composition
      expect(config.unkown_data).to eq(true)
      expect(config[:unkown_data]).to eq(true)
    end

    # hash representation
    expect(client_config.to_h).to match(
      'google_api' => {
        'client_token' => 'client-test-google-api',
        'token' => 'test-google-api'
      },
      'defaults' => nil,
      'admin_access_required' => false,
      'version' => '0.1.0',
      'unkown_data' => true
    )

    # reconfigure
    client_config.configure do |config|
      config.google_api.client_token = 'none'
      config.defaults = { a: 1 }
      config.google_api.token = 'anti-hype'
      config.admin_access_required = true
      config.version = '0.2.0'
      config.unkown_data = nil
    end

    client_config.settings.tap do |config|
      expect(config.google_api.client_token).to eq('none')
      expect(config.defaults).to match(a: 1)
      expect(config.google_api.token).to eq('anti-hype')
      expect(config.admin_access_required).to eq(true)
      expect(config.version).to eq('0.2.0')
      expect(config.unkown_data).to eq(nil)

      expect(config[:google_api][:client_token]).to eq('none')
      expect(config[:defaults]).to match(a: 1)
      expect(config[:google_api][:token]).to eq('anti-hype')
      expect(config[:admin_access_required]).to eq(true)
      expect(config[:version]).to eq('0.2.0')
      expect(config[:unkown_data]).to eq(nil)
    end

    expect(client_config.to_h).to match(
      'google_api' => {
        'client_token' => 'none',
        'token' => 'anti-hype'
      },
      'defaults' => { a: 1 },
      'admin_access_required' => true,
      'version' => '0.2.0',
      'unkown_data' => nil
    )
  end
end
