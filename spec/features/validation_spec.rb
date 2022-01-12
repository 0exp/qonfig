# frozen_string_literal: true

describe 'Validation' do
  describe 'DSL' do
    specify 'fails when validation method isnt chosen' do
      expect do
        # NOTE: no validation block, no dataset method
        Class.new(Qonfig::DataSet) { validate }
      end.to raise_error(Qonfig::ValidatorArgumentError)
    end

    specify 'fails when you try to use both block validation and method validation' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', by: :test do # NOTE: dataset mtehod
            true
          end # NOTE: block
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)
    end

    specify 'fails when you try to use both predefined validator and any validation method' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', :integer do
            true
          end
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)

      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', :integer, by: :check
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)

      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', :integer, by: :check do
            true
          end
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)
    end

    specify 'fails when required predefined validator does not exist' do
      # NOTE: incorrect name => error
      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', 1923923
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)

      # NOTE: nonexistent predefined validator => error
      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', :abracadabra
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)

      # NOTE: existent predefined validator => ok
      expect do
        Class.new(Qonfig::DataSet) do
          validate '*', :integer
          validate '*', :float
          validate '*', :string
          validate '*', :symbol
          validate '*', :numeric
          validate '*', :hash, strict: true
          validate '*', :array, strict: true
          validate '*', :big_decimal, strict: true
          validate '*', :boolean, strict: true
        end
      end.not_to raise_error
    end

    specify 'predefned validatiors can be selected by string and symbols' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate 'a', :integer
          validate 'b', 'integer', strict: true
        end
      end.not_to raise_error
    end

    specify 'dataset method validation (by:): fails on incorrect method name' do
      expect do
        # NOTE: only strings and symbols are supported
        Class.new(Qonfig::DataSet) { validate by: 123 }
      end.to raise_error(Qonfig::ValidatorArgumentError)

      expect do
        # NOTE: only strings and symbols are supported
        Class.new(Qonfig::DataSet) { validate by: '123' }
      end.not_to raise_error

      expect do
        # NOTE: only strings and symbols are supported
        Class.new(Qonfig::DataSet) { validate by: :my_method }
      end.not_to raise_error
    end

    specify 'you can set validation method that is not defined yet' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate by: :my_method # NOTE: not defined method
          validate by: 'another_method' # NOTE: not defined method
        end
      end.not_to raise_error
    end

    specify 'correct setting key patterns' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate :db do # NOTE: symbol => correct
          end

          validate 'db.creds' do # NOTE: string => correct
          end

          validate :user, by: :my_method # NOTE: symbol => correct
          validate 'password', by: :my_method # NOTE: string => correct
        end
      end.not_to raise_error
    end

    specify 'incorrect setting key patterns' do
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

    specify ':strict and non-strict both can be used' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate(:kek, strict: true) {}
          validate(:pek, strict: false) {}
        end
      end.not_to raise_error
    end

    specify 'fails with error on non-boolean values of :strict attribute' do
      expect do
        Class.new(Qonfig::DataSet) do
          validate(:check, strict: Object.new) {}
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)

      expect do
        Class.new(Qonfig::DataSet) do
          validate(:check, strict: nil) {}
        end
      end.to raise_error(Qonfig::ValidatorArgumentError)
    end
  end

  describe 'validations' do
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        setting :telegraf_url, 'test' # NOTE: all right

        # NOTE: check that telegraf_url is a string value
        validate('telegraf_url', strict: true) do |value|
          value.is_a?(String)
        end
      end
    end

    specify 'validates invalid settings on instnation' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :telegraf_url, 12345 # NOTE: should be a string
        validate 'telegraf_url' do |value|
          value.is_a?(String)
        end
      end

      expect { config_klass.new }.to raise_error(Qonfig::ValidationError)
    end

    specify 'validates settings defined by configuration options on instantiation' do
      expect { config_klass.new(telegraf_url: '123') }.not_to raise_error
      expect { config_klass.new(telegraf_url: 123) }.to raise_error(Qonfig::ValidationError)
    end

    specify 'validates settings defined by configuration block' do
      expect do
        config_klass.new.configure do |config|
          config.telegraf_url = 123 # NOTE: should be a string
        end
      end.to raise_error(Qonfig::ValidationError)
    end

    specify 'validates settings setted in runtime' do
      config = config_klass.new

      expect { config.settings.telegraf_url = 1234 }.to raise_error(Qonfig::ValidationError)
      expect { config.settings.telegraf_url = '55' }.not_to raise_error
    end

    specify 'invokes validations on config reload' do
      # reload with hash
      expect do
        config_klass.new.reload!(telegraf_url: 123) # NOTE: should be a string
      end.to raise_error(Qonfig::ValidationError)

      # reload with configuration block
      expect do
        config_klass.new.reload! do |conf|
          conf.telegraf_url = 123 # NOTE: should be a string
        end
      end.to raise_error(Qonfig::ValidationError)
    end

    specify 'invokes validations on config clearing' do
      # NOTE:
      #   before #clear!: telegraf_config => 'test' (correct value)
      #   after  #clear!: telegraf_config => nil (incorrect value)

      expect { config_klass.new.clear! }.to raise_error(Qonfig::ValidationError)
    end

    specify 'config state after exception interception (#valid? / #validate!)' do
      config = config_klass.new
      expect(config.valid?).to eq(true)

      begin
        config.clear! # NOTE: set telegraf_url to nil (to incorrect value)
      rescue Qonfig::ValidationError
        # NOOP
      end

      expect(config.valid?).to eq(false)
    end

    specify 'deeply nested settings validation' do
      deep_config_klass = Class.new(Qonfig::DataSet) do
        setting :db do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
        end

        # NOTE: setting key pattern :)
        validate('db.user') { |value| value.is_a?(String) }
      end

      # NOTE: all right (originally)
      expect { deep_config_klass.new }.not_to raise_error

      # NOTE: change validated setting to incorrect value
      # rubocop:disable Layout/LineLength
      expect { deep_config_klass.new(db: { user: 123 }) }.to raise_error(Qonfig::ValidationError)
      expect { deep_config_klass.new.settings.db.user = 123 }.to raise_error(Qonfig::ValidationError)
      # rubocop:enable Layout/LineLength

      # NOTE: change non-validated setting to any value
      expect { deep_config_klass.new(db: { password: 123 }) }.not_to raise_error
      expect { deep_config_klass.new.settings.db.password = 555 }.not_to raise_error
    end

    specify 'child class inherits the base class validations' do
      base_config_klass = Class.new(Qonfig::DataSet) do
        setting :adapter, 'sidekiq'
        validate(:adapter, strict: true) { |value| value.is_a?(String) }
      end

      child_config_klass = Class.new(base_config_klass) do
        setting :enabled, false
        validate('enabled') { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }

        # NOTE: should inherit :adapter valdations
      end

      # NOTE: all right (originally)
      expect { child_config_klass.new }.not_to raise_error
      expect do
        config = child_config_klass.new
        config.settings.adapter = 'resque'
        config.settings.enabled = true
      end.not_to raise_error

      # NOTE: inherited validations
      # rubocop:disable Layout/LineLength
      expect { child_config_klass.new(adapter: 123) }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new.settings.adapter = 123 }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new { |conf| conf.adapter = 123 } }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new.reload!(adapter: 123) }.to raise_error(Qonfig::ValidationError)
      # rubocop:enable Layout/LineLength

      config = child_config_klass.new
      expect(config.valid?).to eq(true)
      begin
        config.settings.adapter = 123
      rescue Qonfig::ValidationError
        # NOOP
      end
      expect(config.valid?).to eq(false)
      expect(config.settings.adapter).to eq(123)

      # NOTE: own validations
      # rubocop:disable Layout/LineLength
      expect { child_config_klass.new(enabled: '123') }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new.settings.enabled = '123' }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new { |conf| conf.enabled = '123' } }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new.reload!(enabled: '123') }.to raise_error(Qonfig::ValidationError)
      expect { child_config_klass.new.clear! }.to raise_error(Qonfig::ValidationError)
      # rubocop:enable Layout/LineLength

      config = child_config_klass.new
      expect(config.valid?).to eq(true)
      begin
        config.settings.enabled = '123'
      rescue Qonfig::ValidationError
        # NOOP
      end
      expect(config.valid?).to eq(false)
      expect(config.settings.enabled).to eq('123')
    end

    specify 'config composition inherits validators' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :telegraf_url, 'udp://localhost:9094'
        validate(:telegraf_url) { |value| value.is_a?(String) }
      end

      composed_config_klass = Class.new(Qonfig::DataSet) do
        # NOTE: root configs
        compose(config_klass)

        # NOTE: nested configs
        setting(:nested) { compose(config_klass) }
      end

      # NOTE: all right
      expect { composed_config_klass.new }.not_to raise_error
      expect do
        config = composed_config_klass.new
        config.settings.telegraf_url = '123'
        config.settings.nested.telegraf_url = '123'
      end.not_to raise_error

      expect do # NOTE: check root config validation
        composed_config_klass.new.settings.telegraf_url = 123 # NOTE: should be a string
      end.to raise_error(Qonfig::ValidationError)

      expect do # NOTE: check nested config validation
        composed_config_klass.new.settings.nested.telegraf_url = 123
      end.to raise_error(Qonfig::ValidationError)
    end

    specify 'setting patterns (validation of a set of configs chosen by setting pattern)' do
      config_klass = Class.new(Qonfig::DataSet) do
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

          setting :logger_level, 'info'
        end

        setting :adapter, :resque
        setting :port, 1019

        # only the root setting key
        # (port)
        validate('port', strict: true) do |value|
          value.is_a?(Numeric)
        end

        # all .user setting keys
        # (db.creds.user, sidekiq.admin.user)
        validate('#.user', strict: true) do |value|
          value.is_a?(String)
        end

        # one level inside db AND all password setting keys there
        # (db.creds.password)
        validate('db.*.password', strict: true) do |value|
          value.is_a?(String)
        end

        # all .adapter setting keys
        # (adapter)
        validate('#.adapter', strict: true) do |value|
          value.is_a?(Symbol)
        end

        # all keys inside sidekiq setting group
        # (sidekiq.admin.user, sidekiq.admin.password, sidekiq.logger_level)
        validate('sidekiq.#', strict: true) do |value|
          value.is_a?(String)
        end
      end

      # NOTE: all right (originally)
      expect { config_klass.new }.not_to raise_error

      # rubocop:disable Layout/LineLength
      expect { config_klass.new.settings.db.creds.user = 123 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.sidekiq.admin.user = 123 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.sidekiq.admin.password = 123 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.sidekiq.logger_level = nil }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.db.creds.password = 123 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.adapter = 'que' }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.port = '555' }.to raise_error(Qonfig::ValidationError)
      # rubocop:enable Layout/LineLength

      expect { config_klass.new.settings.db.creds.user = '123' }.not_to raise_error
      expect { config_klass.new.settings.sidekiq.admin.user = '123' }.not_to raise_error
      expect { config_klass.new.settings.sidekiq.admin.password = '123' }.not_to raise_error
      expect { config_klass.new.settings.sidekiq.logger_level = 'warn' }.not_to raise_error
      expect { config_klass.new.settings.db.creds.password = '123' }.not_to raise_error
      expect { config_klass.new.settings.adapter = :que }.not_to raise_error
      expect { config_klass.new.settings.port = 5599 }.not_to raise_error
    end

    specify 'proc-based validation wokrs inside dataset instance context' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :some_key, 555

        validate 'some_key' do |value|
          value > some_method
        end

        def some_method
          123
        end
      end

      # NOTE: all right (originally)
      expect { config_klass.new }.not_to raise_error

      # NOTE: invalid value
      expect { config_klass.new(some_key: 122) }.to raise_error(Qonfig::ValidationError)
      # NOTE: valid value
      expect { config_klass.new(some_key: 1234) }.not_to raise_error
    end

    specify 'setting key validation by custom method defined directly on dataset' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :db do
          setting :enabled, false
        end

        # NOTE: validate setting keys by custom dataset method
        validate 'db.#', by: :check_credentials

        def check_credentials(setting_key_value)
          setting_key_value.is_a?(TrueClass) || setting_key_value.is_a?(FalseClass)
        end
      end

      # NOTE: all right (orginally)
      expect { config_klass.new }.not_to raise_error

      # NOTE: invalid values
      expect { config_klass.new.settings.db.enabled = 123 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new(db: { enabled: 123 }) }.to raise_error(Qonfig::ValidationError)

      # NOTE: valid values
      expect { config_klass.new.settings.db.enabled = true }.not_to raise_error
      expect { config_klass.new(db: { enabled: true }) }.not_to raise_error
    end

    specify 'full data set object validation via #validate' do
      # валидация всего сеттингса скопом (синтаксис "validate { |settings| } / validate by:")
      config_klass = Class.new(Qonfig::DataSet) do
        setting :namespace do
          setting :enabled, :true
        end

        setting :go_for_cybersport, 'NO'

        # NOTE: no setting key pattern => full dataset object validation
        validate { settings.namespace.enabled.is_a?(Symbol) }

        # NOTE: no setting key pattern => full dataset object validation
        validate by: :check_all

        def check_all
          settings.go_for_cybersport == 'NO'
        end
      end

      # NOTE: all right (originally)
      expect { config_klass.new }.not_to raise_error

      # NOTE: invalid values
      # (namespace.enabled should be a symbol)
      expect do
        config_klass.new.settings.namespace.enabled = 123
      end.to raise_error(Qonfig::ValidationError)
      # (go_for_cybersport should have the 'NO' string value)
      expect do
        config_klass.new.settings.go_for_cybersport = 'YES'
      end.to raise_error(Qonfig::ValidationError)

      # NOTE: valid values
      expect { config_klass.new.settings.namespace.enabled = :false }.not_to raise_error
      expect { config_klass.new.settings.go_for_cybersport = 'NO' }.not_to raise_error
    end
  end

  describe 'strict behaviour' do
    specify 'non-strict by default (validation ignores nil values)' do
      config = Qonfig::DataSet.build do
        setting :login, 'D@iVeR'
        setting :password, 'atata123'
        setting :enabled, true

        validate :login, :string
        validate(:password) { |value| value.is_a?(String) }
        validate :enabled, by: :check_enabled_setting

        def check_enabled_setting(value)
          value.is_a?(FalseClass) || value.is_a?(TrueClass)
        end
      end

      expect(config.valid?).to eq(true)
      expect { config.settings.login = nil }.not_to raise_error
      expect { config.settings.password = nil }.not_to raise_error
      expect { config.settings.enabled = nil }.not_to raise_error
      expect(config.valid?).to eq(true)
    end

    specify 'strict validation does not ignore nil value' do
      config = Qonfig::DataSet.build do
        setting :login, '0exp'
        setting :password, 'test123'
        setting :enabled, false

        validate :login, :string, strict: true
        validate(:password, strict: true) { |value| value.is_a?(String) }
        validate :enabled, by: :check_enabled_setting, strict: true

        def check_enabled_setting(value)
          value.is_a?(FalseClass) || value.is_a?(TrueClass)
        end
      end

      expect(config.valid?).to eq(true)
      expect { config.settings.login = nil }.to raise_error(Qonfig::ValidationError)
      expect { config.settings.password = nil }.to raise_error(Qonfig::ValidationError)
      expect { config.settings.enabled = nil }.to raise_error(Qonfig::ValidationError)
      expect(config.valid?).to eq(false)
    end
  end

  describe 'predefined validators' do
    specify 'common behaviour (strict)' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :enabled, false
        setting :count, 123
        setting :amount, 23.55
        setting :adapter, 'sidekiq'
        setting :switcher, :on
        setting :data, [1, 2, 3]
        setting :mappings, a: 1, b: 2
        setting :age, 20

        validate :enabled, :boolean, strict: true
        validate :count, :integer, strict: true
        validate :amount, :float, strict: true
        validate :adapter, :string, strict: true
        validate :switcher, :symbol, strict: true
        validate :data, :array, strict: true
        validate :mappings, :hash, strict: true
        validate :age, :numeric, strict: true
      end

      # NOTE: all right (originally)
      expect { config_klass.new }.not_to raise_error

      # NOTE: invalid values
      expect { config_klass.new.settings.enabled = nil }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.count = '5' }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.amount = 22 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.adapter = :resque }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.switcher = 'off' }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.data = {} }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.mappings = [] }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.age = nil }.to raise_error(Qonfig::ValidationError)

      # NOTE: valid values
      expect { config_klass.new.settings.enabled = true }.not_to raise_error
      expect { config_klass.new.settings.count = 5 }.not_to raise_error
      expect { config_klass.new.settings.amount = 22.0 }.not_to raise_error
      expect { config_klass.new.settings.adapter = 'resque' }.not_to raise_error
      expect { config_klass.new.settings.switcher = :off }.not_to raise_error
      expect { config_klass.new.settings.data = [] }.not_to raise_error
      expect { config_klass.new.settings.mappings = {} }.not_to raise_error
      expect { config_klass.new.settings.age = 20.1 }.not_to raise_error
    end

    specify 'common behaviour (non-strict)' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :enabled, false
        setting :count, 123
        setting :amount, 23.55
        setting :adapter, 'sidekiq'
        setting :switcher, :on
        setting :data, [1, 2, 3]
        setting :mappings, a: 1, b: 2
        setting :age, 20

        validate :enabled, :boolean
        validate :count, :integer
        validate :amount, :float
        validate :adapter, :string
        validate :switcher, :symbol
        validate :data, :array
        validate :mappings, :hash
        validate :age, :numeric
      end

      # NOTE: all right (originally)
      expect { config_klass.new }.not_to raise_error

      # NOTE: invalid values
      expect { config_klass.new.settings.count = '5' }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.amount = 22 }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.adapter = :resque }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.switcher = 'off' }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.data = {} }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new.settings.mappings = [] }.to raise_error(Qonfig::ValidationError)

      # NOTE: non-strict values (validation ignores nil values)
      expect { config_klass.new.settings.age = nil }.not_to raise_error
      expect { config_klass.new.settings.enabled = nil }.not_to raise_error

      # NOTE: valid values
      expect { config_klass.new.settings.enabled = true }.not_to raise_error
      expect { config_klass.new.settings.count = 5 }.not_to raise_error
      expect { config_klass.new.settings.amount = 22.0 }.not_to raise_error
      expect { config_klass.new.settings.adapter = 'resque' }.not_to raise_error
      expect { config_klass.new.settings.switcher = :off }.not_to raise_error
      expect { config_klass.new.settings.data = [] }.not_to raise_error
      expect { config_klass.new.settings.mappings = {} }.not_to raise_error
      expect { config_klass.new.settings.age = 20.1 }.not_to raise_error
    end

    describe 'valid_with?' do
      specify '(#valid_with?): config object is valid or invalid with new potenital configs' do
        config = Qonfig::DataSet.build do
          setting :enabled, false
          setting :count, 123
          setting :amount, 23.55
          setting :level, 100_500
          setting :sound do
            setting :genre, 'death-metal'
          end

          validate :enabled, :boolean
          validate :count, :integer, strict: true

          validate by: :check_level
          validate 'sound.#' do |value|
            value.is_a?(String)
          end

          def check_level
            settings.level.is_a?(Numeric)
          end
        end

        expect(config.valid_with?(
          enabled: true,
          count: 444,
          amount: 66.21,
          level: 123.55,
          sound: { genre: 'melodic-death-metal' }
        )).to eq(true)

        expect(config.valid_with?(enabled: '123')).to eq(false)
        expect(config.valid_with?(sound: { genre: false })).to eq(false)
        expect(config.valid_with?(level: '2')).to eq(false)
        expect(config.valid_with?(count: nil)).to eq(false)
        expect(config.valid_with?(level: '7', count: nil, enabled: 123)).to eq(false)

        # NOTE: check that original config does not mutated after validation checking
        expect(config.settings.enabled).to eq(false)
        expect(config.settings.count).to eq(123)
        expect(config.settings.amount).to eq(23.55)
        expect(config.settings.level).to eq(100_500)
        expect(config.settings.sound.genre).to eq('death-metal')
      end
    end

    specify '(.valid_with?/#valid_with?) support for do-config notation :)' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :enabled, false
        setting(:db) { setting :user, 'D@iVeR' }
        validate :enabled, :boolean, strict: true
        validate 'db.#', :text, strict: true
      end

      config = config_klass.new

      # class-level checker
      expect(
        (config_klass.valid_with?(enabled: true) do |conf|
          conf.db.user = '0exp'
        end)
      ).to eq(true)
      expect(
        (config_klass.valid_with?(enabled: false) do |conf|
          conf.db.user = 123
        end)
      ).to eq(false)
      expect(
        (config_klass.valid_with?(enabled: nil) do |conf|
          conf.db.user = 'test'
        end)
      ).to eq(false)

      # instance-level checker
      expect(
        (config.valid_with?(enabled: true) do |conf|
          conf.db.user = '0exp'
        end)
      ).to eq(true)
      expect(
        (config.valid_with?(enabled: false) do |conf|
          conf.db.user = 123
        end)
      ).to eq(false)
      expect(
        (config.valid_with?(enabled: nil) do |conf|
          conf.db.user = 'test'
        end)
      ).to eq(false)

      # original instance is not changed
      expect(config.settings.enabled).to eq(false)
      expect(config.settings.db.user).to eq('D@iVeR')
    end

    specify '(.valid_with?) potential config instances will be valid or invalid with new configs' do
      config_klass = Class.new(Qonfig::DataSet) do
        setting :enabled, false
        setting :count, 123
        setting :amount, 23.55
        setting :level, 100_500
        setting :sound do
          setting :genre, 'death-metal'
        end

        validate :enabled, :boolean
        validate :count, :integer, strict: true

        validate by: :check_level
        validate 'sound.#' do |value|
          value.is_a?(String)
        end

        def check_level
          settings.level.is_a?(Numeric)
        end
      end

      expect(config_klass.valid_with?(
        enabled: true,
        count: 444,
        amount: 66.21,
        level: 123.55,
        sound: { genre: 'melodic-death-metal' }
      )).to eq(true)

      expect(config_klass.valid_with?(enabled: '123')).to eq(false)
      expect(config_klass.valid_with?(sound: { genre: false })).to eq(false)
      expect(config_klass.valid_with?(level: '2')).to eq(false)
      expect(config_klass.valid_with?(count: nil)).to eq(false)
      expect(config_klass.valid_with?(level: '7', count: nil, enabled: 123)).to eq(false)
    end
  end

  describe 'custom validators' do
    specify 'you can define your own global validators and concrete-class-related validators' do
      # custom global validator
      Qonfig::DataSet.define_validator(:globality) do |value|
        value == 'global'
      end

      config_klass = Class.new(Qonfig::DataSet) do
        # custom class-related validator
        define_validator(:int_or_sym) do |value|
          value.is_a?(Integer) || value.is_a?(Symbol)
        end

        # custom class-related validator
        define_validator(:queue_adapter) do |value|
          value == :que || value == :sidekiq
        end

        setting :some_value, 123
        setting :adapter, :sidekiq
        setting :global, 'global'

        validate :some_value, :int_or_sym # class-related validator
        validate :adapter, :queue_adapter # class-related validator
        validate :global, :globality, strict: true # global validator + srict cheker
      end

      expect { config_klass.new }.not_to raise_error

      # invalid :global setting values
      expect { config_klass.new(global: 123) }.to raise_error(Qonfig::ValidationError)
      expect { config_klass.new(global: nil) }.to raise_error(Qonfig::ValidationError)
      # invalid :some_value setting value
      expect { config_klass.new(some_value: 123.456) }.to raise_error(Qonfig::ValidationError)
      # invalid :adaper setting value
      expect { config_klass.new(adapter: :sneakers) }.to raise_error(Qonfig::ValidationError)
    end

    specify 'fails when validation logic is not provided at definition step' do
      config_klass = Class.new(Qonfig::DataSet)

      expect do
        config_klass.define_validator(:simple_validator)
      end.to raise_error(Qonfig::ValidatorArgumentError)

      expect do
        config_klass.define_validator(:simple_validator) {}
      end.not_to raise_error
    end

    specify 'inheritance works as expeced' do
      Qonfig::DataSet.define_validator(:global_inheritable) do |value|
        value == 0
      end

      first_klass = Class.new(Qonfig::DataSet) do
        define_validator(:first_validator) { |value| value == 1 }
        setting :a
      end

      second_klass = Class.new(first_klass) do
        define_validator(:second_validator) { |value| value == 2 }
        setting :b
      end

      third_klass = Class.new(second_klass) do
        define_validator(:third_validator) { |value| value == 3 }
        setting :c
        setting :d

        validate :a, :first_validator
        validate :b, :second_validator
        validate :c, :third_validator
        validate :d, :global_inheritable
      end

      expect { third_klass.new(a: 1, b: 2, c: 3, d: 0) }.not_to raise_error
      expect { third_klass.new }.not_to raise_error

      expect { third_klass.new(a: '1') }.to raise_error(Qonfig::ValidationError)
      expect { third_klass.new(b: '2') }.to raise_error(Qonfig::ValidationError)
      expect { third_klass.new(c: '3') }.to raise_error(Qonfig::ValidationError)
      expect { third_klass.new(d: '0') }.to raise_error(Qonfig::ValidationError)
    end

    specify 'predefined validators can be redefined' do
      # custom global predefined validator
      Qonfig::DataSet.define_validator(:global_predefined) do |value|
        value == :predefined
      end

      config_klass_with_redefinition = Class.new(Qonfig::DataSet) do
        define_validator(:global_predefined) do |value|
          value == :class_level_predefined
        end

        setting :some_option
        validate :some_option, :global_predefined
      end

      config_klass_without_redefinition = Class.new(Qonfig::DataSet) do
        setting :some_option
        validate :some_option, :global_predefined
      end

      # NOTE: config with redefined validator
      expect do
        # check that redefined validator is used
        config_klass_with_redefinition.new(some_option: :class_level_predefined)
      end.not_to raise_error
      expect do
        # check that global validator is not reached
        config_klass_with_redefinition.new(some_option: :predefined)
      end.to raise_error(Qonfig::ValidationError)

      # NOTE: config without redefined validator
      expect do
        config_klass_without_redefinition.new(some_option: :class_level_predefined)
      end.to raise_error(Qonfig::ValidationError)
      expect do
        config_klass_without_redefinition.new(some_option: :predefined)
      end.not_to raise_error
    end
  end
end
