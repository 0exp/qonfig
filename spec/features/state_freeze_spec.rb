# frozen_string_literal: true

describe 'State freeze' do
  specify 'freezing' do
    class FrozenableConfig < Qonfig::DataSet
      setting :api_mode_enabled, true

      setting :api do
        setting :format, :json
      end
    end

    frozen_config = FrozenableConfig.new

    # can modify config values
    frozen_config.configure do |conf|
      expect { conf.api_mode_enabled = nil }.not_to raise_error
      expect { conf.api.format = :plain_text }.not_to raise_error
    end

    # can reload config object
    class FrozenableConfig
      setting :additionals, false
    end

    expect { frozen_config.reload! }.not_to raise_error

    frozen_config.freeze!

    # cannot modify config values
    frozen_config.configure do |conf|
      expect { conf.api_mode_enabled = false }.to raise_error(Qonfig::FrozenSettingsError)
      expect { conf.api.format = :xml }.to        raise_error(Qonfig::FrozenSettingsError)
      expect { conf.additionals = true }.to       raise_error(Qonfig::FrozenSettingsError)

      expect { conf.api_mode_enabled = false }.to raise_error(FrozenError)
      expect { conf.api.format = :xml }.to        raise_error(FrozenError)
      expect { conf.additionals = true }.to       raise_error(FrozenError)
    end

    # cannot reload config object
    class FrozenableConfig
      setting :customizable, false
    end

    expect { frozen_config.reload! }.to raise_error(Qonfig::FrozenSettingsError)
    expect { frozen_config.reload! }.to raise_error(FrozenError)

    expect(frozen_config.to_h).to match(
      {
        api_mode_enabled: true,
        api: { format: :json },
        additionals: false
      }
    )
  end
end
