# frozen_string_literal: true

describe 'Definition order' do
  specify 'config definitions dependes on the order' do
    class FirstConfig < Qonfig::DataSet
      setting :default, 100_500
      setting :default do
        setting :options, defined: true
      end
    end

    FirstConfig.new.settings.tap do |config|
      # { default: { options: { defined: true } } } is the last
      expect(config.default.options).to match(defined: true)
    end

    class SecondConfig < Qonfig::DataSet
      setting :default do
        setting :options, defined: true
      end
      setting :default, 100_500
    end

    SecondConfig.new.settings.tap do |config|
      # { default: 100_500 } is the last
      expect(config.default).to eq(100_500)
    end

    class FirstComposedConfig < Qonfig::DataSet
      compose FirstConfig
      compose SecondConfig
    end

    FirstComposedConfig.new.settings.tap do |config|
      # setting from SecondConfig (SecondConfig is the last)
      expect(config.default).to eq(100_500)
    end

    class SecondComposedConfig < Qonfig::DataSet
      compose SecondConfig
      compose FirstConfig
    end

    SecondComposedConfig.new.settings.tap do |config|
      # setting from FirstConfig (FirstConfig is the last)
      expect(config.default.options).to match(defined: true)
    end

    class FirstAllInConfig < Qonfig::DataSet
      setting :default, 123
      compose FirstConfig
    end

    FirstAllInConfig.new.settings.tap do |config|
      # setting from FirstConfig (FirstConfig is the last)
      expect(config.default.options).to match(defined: true)
    end

    class SecondAllInConfig < Qonfig::DataSet
      compose FirstConfig
      setting :default, 123
    end

    SecondAllInConfig.new.settings.tap do |config|
      # own setting (own setting is the last)
      expect(config.default).to eq(123)
    end
  end
end
