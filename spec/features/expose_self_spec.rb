# frozen_string_literal: true

describe 'Expose self (expose __END__)' do
  specify 'defines config object by __END__ instructions and specific environment settings' do
    class ExposeSelfConfig < Qonfig::DataSet
      setting :test_env do
        expose_self env: :test
      end

      setting :dev_env do
        expose_self env: :development
      end

      setting :stage_env do
        expose_self env: :staging
      end

      setting :prod_env do
        expose_self env: :production
      end
    end

    settings = ExposeSelfConfig.new.settings

    # :test env key
    expect(settings.test_env.api_mode_enabled).to eq(true)
    expect(settings.test_env.db_driver).to eq('in_memory')
    expect(settings.test_env.logging).to eq(false)
    expect(settings.test_env.credentials).to eq({})

    # :production env key
    expect(settings.prod_env.api_mode_enabled).to eq(true)
    expect(settings.prod_env.db_driver).to eq('rom')
    expect(settings.prod_env.logging).to eq(true)
    expect(settings.prod_env.credentials).to eq({})

    # :development env key
    expect(settings.dev_env.api_mode_enabled).to eq(true)
    expect(settings.dev_env.db_driver).to eq('sequel')
    expect(settings.dev_env.logging).to eq(false)
    expect(settings.dev_env.credentials).to eq({})

    # :staging env key
    expect(settings.stage_env.api_mode_enabled).to eq(true)
    expect(settings.stage_env.db_driver).to eq('active_record')
    expect(settings.stage_env.logging).to eq(true)
    expect(settings.stage_env.credentials).to eq({})
  end


  describe 'failures and inconsistent situations' do
    describe 'definition level errors' do
      specify 'fails when :env attribute has non-string / non-symbol / non-numeric value' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_self env: Object.new
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when :env is empty' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_self env: ''
          end
        end.to raise_error(Qonfig::ArgumentError)
      end
    end
  end
end

__END__

default: &default
  api_mode_enabled: true
  logging: true
  db_driver: in_memory
  throttle_requests: false
  credentials: {}

development:
  <<: *default
  db_driver: sequel
  logging: false

test:
  <<: *default
  logging: false

staging:
  <<: *default
  db_driver: active_record
  throttle_requests: true

production:
  <<: *default
  db_driver: rom
  throttle_requests: true
