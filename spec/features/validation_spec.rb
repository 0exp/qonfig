# frozen_string_literal: true

# TODO: refactor

describe 'Iteration over setting keys (#each_setting / #deep_each_setting)' do
  let(:config_klass) do
    Class.new(Qonfig::DataSet) do
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
          setting :data, test: false
        end
      end

      setting :telegraf_url, 'udp://localhost:8094'
      setting :telegraf_prefix, 1

      validate 'db.creds.user' do |value|
        value.is_a?(String)
      end
    end
  end

  specify do
    # валидация при инстанцирвоании (у уже сломанного конфига)
    config_klass = Class.new(Qonfig::DataSet) do
      setting :telegraf_url, 12345 # согласно валидации долна быть строка
      validate 'telegraf_url' do |value|
        value.is_a?(String)
      end
    end
    expect { config_klass.new }.to raise_error(Qonfig::ValidationError)

    # валидация на конфигурэйшн-опшнсы при инстанцировании
    config_klass = Class.new(Qonfig::DataSet) do
      setting :telegraf_url, 'test' # при инициализации все четко - валидируем на строку и все ок

      validate 'telegraf_url' do |value|
        value.is_a?(String)
      end
    end
    expect { config_klass.new(telegraf_url: 123) }.to raise_error(Qonfig::ValidationError)

    # валидация на конфигурейшн-блок
    expect do
      config_klass.new.configure do |config|
        config.telegraf_url = 123
      end
    end.to raise_error(Qonfig::ValidationError)

    # валидация на ручное изменение
    config = config_klass.new
    expect { config.settings.telegraf_url = 1234 }.to raise_error(Qonfig::ValidationError)
    expect { config.settings.telegraf_url = '55' }.not_to raise_error

    # валидацтя при релоаде (с хэш-мапом)
    config = config_klass.new
    expect { config.reload!(telegraf_url: 123) }.to raise_error(Qonfig::ValidationError)

    # валидация при релоаде (с конфигурэйшн блоком)
    config = config_klass.new
    expect do
      config.reload! do |conf|
        conf.telegraf_url = 123
      end
    end.to raise_error(Qonfig::ValidationError)

    # валидация при clear (все в nil проставится - надо провалидировать)
    config = config_klass.new
    expect { config.clear! }.to raise_error(Qonfig::ValidationError)

    # валидное-невалидное состояние после валидэйщн эксепшнов
    config = config_klass.new
    expect(config.valid?).to eq(true)
    begin
      config.clear!
    rescue Qonfig::ValidationError
    end
    expect(config.valid?).to eq(false)

    # валидация глубоко положенного ключа
    deep_config_klass = Class.new(Qonfig::DataSet) do
      setting :db do
        setting :user, 'D@iVeR'
        setting :password, 'test123'
      end

      validate 'db.user' do |value|
        value.is_a?(String)
      end
    end

    expect { deep_config_klass.new(db: { user: 123 }) }.to raise_error(Qonfig::ValidationError)
    expect { deep_config_klass.new.settings.db.user = 123 }.to raise_error(Qonfig::ValidationError)

    # сохранение валидаций при наследовании
    inherited_config_klass = Class.new(config_klass) do
      setting :enabled, false

      validate 'enabled' do |value|
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end

    expect { inherited_config_klass.new(telegraf_url: 123) }.to raise_error(Qonfig::ValidationError)
    expect do
      config = inherited_config_klass.new
      config.settings.telegraf_url = 123
    end.to raise_error(Qonfig::ValidationError)
    expect do
      inherited_config_klass.new do |conf|
        conf.telegraf_url = 123
      end
    end.to raise_error(Qonfig::ValidationError)
    expect { inherited_config_klass.new.reload!(telegraf_url: 123) }.to raise_error(
      Qonfig::ValidationError
    )
    expect { inherited_config_klass.new.clear! }.to raise_error(Qonfig::ValidationError)
    expect do
      config = inherited_config_klass.new
      expect(config.valid?).to eq(true)
      begin
        config.settings.telegraf_url = 123
      rescue Qonfig::ValidationError
      end
      expect(config.valid?).to eq(false)
    end
    expect { inherited_config_klass.new.settings.telegraf_url = 123 }.to raise_error(
      Qonfig::ValidationError
    )

    # сохранение валидаций при композиции
    composed_config_klass = Class.new(Qonfig::DataSet) do
      compose(config_klass)

      setting :nested do
        compose(config_klass)
      end
    end

    expect { composed_config_klass.new.settings.telegraf_url = 123 }.to raise_error(
      Qonfig::ValidationError
    )

    expect { composed_config_klass.new.settings.nested.telegraf_url = 123 }.to raise_error(
      Qonfig::ValidationError
    )

    expect do
      config = composed_config_klass.new
      config.settings.telegraf_url = '123'
      config.settings.nested.telegraf_url = '123'
    end.not_to raise_error

    # валидация набора ключей по шаблону
    pattern_config_klass = Class.new(Qonfig::DataSet) do
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
        end
      end

      setting :sidekiq do
        setting :admin do
          setting :user, 'D@iVeR'
          setting :password, '123test'
        end
      end

      setting :adapter, :resque

      # все ключию-зеры
      validate '#.user' do |value|
        value.is_a?(String)
      end

      # на один уровень внутроь И все пассворды
      validate 'db.*.password' do |value|
        value.is_a?(String)
      end

      # все ключи-адаптеры
      validate '#.adapter' do |value|
        value.is_a?(Symbol)
      end

      # все ключи внутри sidekiq
      validate 'sidekiq.#' do |value|
        value.is_a?(String)
      end
    end

    expect { pattern_config_klass.new.settings.db.creds.user = 123 }.to raise_error(Qonfig::ValidationError)
    expect { pattern_config_klass.new.settings.sidekiq.admin.user = 123 }.to raise_error(Qonfig::ValidationError)
    expect { pattern_config_klass.new.settings.sidekiq.admin.password = 123 }.to raise_error(Qonfig::ValidationError)
    expect { pattern_config_klass.new.settings.db.creds.password = 123 }.to raise_error(Qonfig::ValidationError)
    expect { pattern_config_klass.new.settings.adapter = 'que' }.to raise_error(Qonfig::ValidationError)

    expect { pattern_config_klass.new.settings.db.creds.user = '123' }.not_to raise_error
    expect { pattern_config_klass.new.settings.sidekiq.admin.user = '123' }.not_to raise_error
    expect { pattern_config_klass.new.settings.sidekiq.admin.password = '123' }.not_to raise_error
    expect { pattern_config_klass.new.settings.db.creds.password = '123' }.not_to raise_error
    expect { pattern_config_klass.new.settings.adapter = :que }.not_to raise_error

    # использование метода-валидатора с дата-сета
    data_set_method_config_klass = Class.new(Qonfig::DataSet) do
      setting :db do
        setting :creds, false
      end

      validate 'db.#', by: :check_credentials

      def check_credentials(value)
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end
    end

    expect { data_set_method_config_klass.new.settings.db.creds = 123 }.to raise_error(Qonfig::ValidationError)
    expect { data_set_method_config_klass.new.settings.db.creds = true }.not_to raise_error

    # валидация всего сеттингса скопом (синтаксис "validate { |settings| } / validate by:")
    full_check_config_klass = Class.new(Qonfig::DataSet) do
      setting :namespace do
        setting :enabled, :true
      end

      setting :go_for_cybersport, 'NO'

      validate do
        settings.namespace.enabled.is_a?(Symbol)
      end

      validate by: :check_all

      def check_all
        settings.go_for_cybersport == 'NO'
      end
    end

    expect { full_check_config_klass.new.settings.namespace.enabled = 123 }.to raise_error(Qonfig::ValidationError)
    expect { full_check_config_klass.new.settings.namespace.enabled = :false }.not_to raise_error
    expect { full_check_config_klass.new.settings.go_for_cybersport = 'YES' }.to raise_error(Qonfig::ValidationError)
    expect { full_check_config_klass.new.settings.go_for_cybersport = 'NO' }.not_to raise_error

    # если указано лишнего при написании класса - падаем
    expect do
      # no block, no dataset method
      Class.new(Qonfig::DataSet) { validate }
    end.to raise_error(Qonfig::ValidatorArgumentError)

    expect do
      # block and dataset method
      Class.new(Qonfig::DataSet) do
        validate '*', by: :test do
          true
        end
      end
    end.to raise_error(Qonfig::ValidatorArgumentError)

    expect do
      # incorrect method name
      Class.new(Qonfig::DataSet) { validate by: 123 }
    end.to raise_error(Qonfig::ValidatorArgumentError)

    expect do
      # you can set method that is not defined yet
      Class.new(Qonfig::DataSet) do
        validate by: :my_method
        validate by: 'another_method'
      end
    end.not_to raise_error

    # корректный тип сеттинг кей паттерна
    expect do
      Class.new(Qonfig::DataSet) do
        validate :db do
        end

        validate 'db.creds' do
        end

        validate :user, by: :my_method
        validate 'password', by: :my_method
      end
    end.not_to raise_error

    # некорректный тип сеттинг кей паттерна
    expect do
      Class.new(Qonfig::DataSet) do
        validate 123, by: :my_method
      end
    end.to raise_error(Qonfig::ValidatorArgumentError)
    expect do
      Class.new(Qonfig::DataSet) do
        validate 123 do
          true
        end
      end
    end.to raise_error(Qonfig::ValidatorArgumentError)
  end
end
