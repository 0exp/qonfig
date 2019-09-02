# frozen_string_literal: true

describe '#expose_self => format: :yaml' do
  specify ':yaml-format support' do
    class ExposeYamlEndDataConfig < Qonfig::DataSet
      setting :staging_env do
        expose_self format: :yaml, env: :staging
      end

      setting :prod_env do
        expose_self format: :yml, env: :production # NOTE: yml is the same as yaml
      end

      setting :test_env do
        expose_self format: :yaml, env: :test
      end
    end

    config = ExposeYamlEndDataConfig.new

    # NOTE: production env
    expect(config.settings.prod_env.credentials.user).to eq('admin')
    expect(config.settings.prod_env.credentials.password).to eq('123')
    expect(config.settings.prod_env.credentials.enabled).to eq(true)
    expect(config.settings.prod_env.api).to eq('google.com')
    expect(config.settings.prod_env.ports).to eq([10001, 10002, 10003])

    # NOTE: test env
    expect(config.settings.test_env.credentials.user).to eq('megaman')
    expect(config.settings.test_env.credentials.password).to eq('atata123')
    expect(config.settings.test_env.credentials.enabled).to eq(false)
    expect(config.settings.test_env.api).to eq('yandex.ru')
    expect(config.settings.test_env.ports).to eq([1, 2, 3])

    # NOTE: staging env
    expect(config.settings.staging_env.credentials.user).to eq('diablo')
    expect(config.settings.staging_env.credentials.password).to eq('testornot')
    expect(config.settings.staging_env.credentials.enabled).to eq(true)
    expect(config.settings.staging_env.api).to eq('battle.net')
    expect(config.settings.staging_env.ports).to eq([111, 222, 333])
  end
end

__END__

production:
  credentials:
    user: admin
    password: '123'
    enabled: true
  api: google.com
  ports:
    - 10001
    - 10002
    - 10003

test:
  credentials:
    user: megaman
    password: atata123
    enabled: false
  api: yandex.ru
  ports:
    - 1
    - 2
    - 3

staging:
  credentials:
    user: diablo
    password: testornot
    enabled: true
  api: battle.net
  ports:
    - 111
    - 222
    - 333
