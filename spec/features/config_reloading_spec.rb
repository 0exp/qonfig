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

    # re-define and append settings
    class ReloadableConfig
      setting :db do
        setting :adapter, 'mongoid' # re-define defaults
      end

      setting :enable_api, false # append new setting
    end

    expect(config.to_h).to match(
      'db' => { 'adapter' => 'postgresql' },
      'logging' => true # internal state has initial value (not a changed previously)
    )

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
  end
end
