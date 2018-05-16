# frozen_string_literal: true

describe 'Definition' do
  specify 'config object definition, instantiation, settings access and mutation' do
    class Config < Qonfig::DataSet
      # setting with nested options
      setting :serializers do
        # :native by default
        setting :json, :native
      end

      # another setting with nested options
      setting :mutations do
        # subsetting
        setting :action do
          # nil by default
          setting :query
        end
      end

      # nested option reopening
      setting :serializers do
        # :native by default
        setting :xml, :native
      end

      setting :defaults do
        setting :test, false
      end
      # existing nested config redifinition (nested => value)
      setting :defaults, nil

      setting :shared, true
      # existind setting redifinition (value => nested)
      setting :shared do
        setting :convert, false
      end

      # setting without nested options
      setting :steps, 22
    end

    # instantiation
    config = Config.new

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq(:native)
    expect(config.settings.mutations.action.query).to eq(nil)
    expect(config.settings.steps).to eq(22)
    expect(config.settings.defaults).to eq(nil)
    expect(config.settings.shared.convert).to eq(false)

    # access via index named as a setting key
    expect(config.settings[:serializers][:json]).to eq(:native)
    expect(config.settings[:mutations][:action][:query]).to eq(nil)
    expect(config.settings[:steps]).to eq(22)

    # configuration via block (classic style)
    config.configure do |conf|
      conf.serializers.json = :oj
      conf.mutations.action.query = 'select'
      conf.steps = 31
    end

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq(:oj)
    expect(config.settings.mutations.action.query).to eq('select')
    expect(config.settings.steps).to eq(31)

    # access via option index named as a setting key
    expect(config.settings[:serializers][:json]).to eq(:oj)
    expect(config.settings[:mutations][:action][:query]).to eq('select')
    expect(config.settings[:steps]).to eq(31)

    # configuration via settings method
    config.settings.serializers.json = 'circular'
    config.settings.mutations.action.query = :update
    config.settings.steps = nil

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq('circular')
    expect(config.settings.mutations.action.query).to eq(:update)
    expect(config.settings.steps).to eq(nil)

    # access via option index named as a setting key
    expect(config.settings[:serializers][:json]).to eq('circular')
    expect(config.settings[:mutations][:action][:query]).to eq(:update)
    expect(config.settings[:steps]).to eq(nil)

    # attempt to get an access to the unexistent setting
    expect { config.settings.deserialization }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings.mutations.global }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings[:deserialization] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings.mutations[:global] }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify 'hash representation' do
  end
end
