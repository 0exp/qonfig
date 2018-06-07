# frozen_string_literal: true

describe 'Settings as Predicates' do
  specify 'boolean nature of the option value' do
    class BooleanCheckConfig < Qonfig::DataSet
      setting :database do
        setting :user
        setting :host, 'google.com'
      end

      setting :enable_mocks, true
    end

    config = BooleanCheckConfig.new

    # predicats
    expect(config.settings.database.user?).to eq(false)
    expect(config.settings.database.host?).to eq(true)
    expect(config.settings.enable_mocks?).to eq(true)
    # setting roots always returns true
    expect(config.settings.database?).to eq(true)

    # reconfigure and check again
    config.configure do |conf|
      conf.database.user = 'D@iVeR'
      conf.database.host = nil
      conf.enable_mocks = false
    end

    # predicates
    expect(config.settings.database.user?).to eq(true)
    expect(config.settings.database.host?).to eq(false)
    expect(config.settings.enable_mocks?).to eq(false)
    # setting roots always returns true
    expect(config.settings.database?).to eq(true)

    # clear all options
    config.configure do |conf|
      conf.database.user = nil
      conf.database.host = nil
      conf.enable_mocks = nil
    end

    # setting roots always returns true
    expect(config.settings.database?).to eq(true)
  end
end
