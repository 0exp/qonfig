# frozen_string_literal: true

describe 'Freeze state' do
  context 'instance' do
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

      expect { frozen_config.clear! }.not_to raise_error
      expect { frozen_config.reload! }.not_to raise_error

      frozen_config.freeze!

      # cannot modify config values
      frozen_config.configure do |conf|
        expect { conf.api_mode_enabled = false }.to raise_error(Qonfig::FrozenSettingsError)
        expect { conf.api.format = :xml }.to        raise_error(Qonfig::FrozenSettingsError)
        expect { conf.additionals = true }.to       raise_error(Qonfig::FrozenSettingsError)

        if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5.0')
          expect { conf.api_mode_enabled = false }.to raise_error(::FrozenError)
          expect { conf.api.format = :xml }.to        raise_error(::FrozenError)
          expect { conf.additionals = true }.to       raise_error(::FrozenError)
        else
          expect { conf.api_mode_enabled = false }.to raise_error(::RuntimeError)
          expect { conf.api.format = :xml }.to        raise_error(::RuntimeError)
          expect { conf.additionals = true }.to       raise_error(::RuntimeError)
        end
      end

      # cannot reload config object
      class FrozenableConfig
        setting :customizable, false
      end

      expect { frozen_config.reload! }.to raise_error(Qonfig::FrozenSettingsError)
      expect { frozen_config.clear! }.to raise_error(Qonfig::FrozenSettingsError)

      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5.0')
        expect { frozen_config.reload! }.to raise_error(::FrozenError)
        expect { frozen_config.clear! }.to raise_error(::FrozenError)
      else
        expect { frozen_config.reload! }.to raise_error(::RuntimeError)
        expect { frozen_config.clear! }.to raise_error(::RuntimeError)
      end

      expect(frozen_config.to_h).to match(
        'api_mode_enabled' => true,
        'api' => {
          'format' => :json
        },
        'additionals' => false
      )
    end
  end

  context 'definition' do
    specify 'created instance should be frozen' do
      config = Qonfig::DataSet.build do
        setting :test, true
        freeze_state!
      end

      expect(config.frozen?).to eq(true)
    end

    specify 'inherited classes should not be frozen' do
      base_config_klass = Class.new(Qonfig::DataSet) do
        setting :test, true
        freeze_state!
      end

      children_config_klass = Class.new(base_config_klass)
      children_config = children_config_klass.new

      expect(children_config.frozen?).to eq(false)
    end

    specify 'composed configurations should not be frozen' do
      class BaseWithFreezeConfig < Qonfig::DataSet
        setting :test, true
        freeze_state!
      end

      class CompositionOfFreezedConfigs < Qonfig::DataSet
        setting :nested do
          compose BaseWithFreezeConfig
        end
        compose BaseWithFreezeConfig
      end

      config = CompositionOfFreezedConfigs.new
      expect(config.frozen?).to eq(false)

      expect do
        config.settings.test = false
        config.settings.nested.test = false
      end.not_to raise_error

      expect(config.settings.test).to eq(false)
      expect(config.settings.nested.test).to eq(false)
    end
  end
end
