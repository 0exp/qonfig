# frozen_string_literal: true

describe 'Instantiation without class definition' do
  specify '#build builds a config instance without a class' do
    config = Qonfig::DataSet.build do
      setting :credentials do
        setting :user, 'D@iVeR'
        setting :password, 'test123'
      end

      def custom_method(custom_param)
        custom_param
      end
    end

    expect(config).to be_a(Qonfig::DataSet)
    expect(config.settings.credentials.user).to eq('D@iVeR')
    expect(config.settings.credentials.password).to eq('test123')

    custom_param = rand(1..1000).to_s
    expect(config.custom_method(custom_param)).to eq(custom_param)
  end

  specify 'custom Qonfig::DataSet inheritance' do
    simple_config_klass = Class.new(Qonfig::DataSet) do
      setting :adapter do
        setting :engine, :sidekiq
        setting :options, {}
      end
    end

    config = Qonfig::DataSet.build(simple_config_klass) do
      setting :credentials do
        setting :user, '0exp'
        setting :password, '123test123'
      end

      setting :adapter do
        setting :enabled, false
      end
    end

    # NOTE: inherited configs
    expect(config.settings.adapter.engine).to eq(:sidekiq)
    expect(config.settings.adapter.options).to eq({})

    # NOTE: extended base config
    expect(config.settings.adapter.enabled).to eq(false)

    # NOTE: own configs
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.password).to eq('123test123')
  end

  specify 'custom inheritance fails on non-Qonfig::DataSet base classes' do
    expect { Qonfig::DataSet.build(Object) }.to raise_error(Qonfig::ArgumentError)
    expect { Qonfig::DataSet.build(Qonfig::DataSet) }.not_to raise_error
  end
end
