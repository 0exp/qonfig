# frozen_string_literal: true

describe 'Clear options' do
  specify '#clear - sets all options to nil' do
    ENV['QONFIG_CLEAR_GENERIC_OPTION'] = 'true'
    ENV['QONFIG_CLEAR_MEGA_SECRET_VALUE'] = '100500'

    class SimplifiedConfig < Qonfig::DataSet
      setting :a do
        setting :b do
          setting :c, 55
        end
      end

      load_from_env prefix: 'QONFIG_CLEAR'
    end

    class CleansedConfig < Qonfig::DataSet
      setting :database do
        setting :user, '0exp'
        setting :password, 'test123'
      end

      setting :travis do
        load_from_yaml File.expand_path(
          File.join('..', '..', 'fixtures', 'travis_settings.yml'),
          Pathname.new(__FILE__).realpath
        )
      end

      setting :self_data do
        load_from_self
      end

      setting :env_data do
        load_from_env convert_values: true, prefix: /\AQONFIG_CLEAR.*\z/i
      end

      setting :composed do
        compose SimplifiedConfig
      end
    end

    config = CleansedConfig.new

    config.clear!

    expect(config[:database][:user]).to eq(nil)
    expect(config[:database][:password]).to eq(nil)
    expect(config[:travis][:sudo]).to eq(nil)
    expect(config[:travis][:language]).to eq(nil)
    expect(config[:travis][:rvm]).to eq(nil)
    expect(config[:self_data][:secret_key]).to eq(nil)
    expect(config[:self_data][:api_host]).to eq(nil)
    expect(config[:self_data][:connection_timeout][:seconds]).to eq(nil)
    expect(config[:self_data][:connection_timeout][:enabled]).to eq(nil)
    expect(config[:env_data][:QONFIG_CLEAR_GENERIC_OPTION]).to eq(nil)
    expect(config[:env_data][:QONFIG_CLEAR_MEGA_SECRET_VALUE]).to eq(nil)
    expect(config[:composed][:a][:b][:c]).to eq(nil)

    expect(config.to_h).to match(
      'database' => { 'user' => nil, 'password' => nil },
      'travis' => {
        'sudo' => nil,
        'language' => nil,
        'rvm' => nil
      },
      'self_data' => {
        'secret_key' => nil,
        'api_host' => nil,
        'connection_timeout' => {
          'seconds' => nil,
          'enabled' => nil
        }
      },
      'env_data' => {
        'QONFIG_CLEAR_GENERIC_OPTION' => nil,
        'QONFIG_CLEAR_MEGA_SECRET_VALUE' => nil
      },
      'composed' => {
        'a' => { 'b' => { 'c' => nil } },
        'QONFIG_CLEAR_GENERIC_OPTION' => nil,
        'QONFIG_CLEAR_MEGA_SECRET_VALUE' => nil
      }
    )
  end
end

__END__

secret_key: top-mega-secret
api_host: super.puper-google.com
:connection_timeout:
   seconds: 10
   enabled: false
