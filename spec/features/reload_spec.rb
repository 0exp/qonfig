# frozen_string_literal: true

describe 'Config reloading' do
  specify 'config reloading works correctly' do
    class ReloadableConfig < Qonfig::DataSet
      setting :db do
        setting :adapter, 'postgresql'
      end

      setting :logging, false
    end

    config = ReloadableConfig.new

    expect(config.to_h).to match(
      'db' => { 'adapter' => 'postgresql' },
      'logging' => false
    )

    config.configure { |conf| conf.logging = true } # change internal state

    # re-define and append settings and validations
    class ReloadableConfig
      setting :db do
        setting :adapter, 'mongoid' # re-define defaults
      end

      setting :enable_api, false # append new setting

      validate :logging, :boolean, strict: true
    end

    expect(config.to_h).to match(
      'db' => { 'adapter' => 'postgresql' },
      'logging' => true # internal state has initial value (not a changed previously)
    )

    # new validator is not invoked (logging should be a boolean)
    expect { config.settings.logging = nil }.not_to raise_error

    # reload config settings
    config.reload!

    expect(config.to_h).to match(
      'db' => { 'adapter' => 'mongoid' },
      'logging' => false,
      'enable_api' => false
    )

    # reload with instant configuration
    config.reload! do |conf|
      conf.enable_api = true # changed instantly
    end

    expect(config.to_h).to match(
      'db' => { 'adapter' => 'mongoid' },
      'logging' => false,
      'enable_api' => true # value from isntant change
    )

    # reload with hash && proc configuration
    config.reload!(db: { adapter: 'oracloid' }) do |conf|
      conf.enable_api = true
    end

    expect(config.to_h).to match(
      'db' => { 'adapter' => 'oracloid' },
      'logging' => false,
      'enable_api' => true
    )

    # reload and set invalid options (logging cant be nil)
    expect { config.reload!(logging: nil) }.to raise_error(Qonfig::ValidationError)
  end
end
