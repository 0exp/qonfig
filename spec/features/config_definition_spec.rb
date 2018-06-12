# frozen_string_literal: true

describe 'Config definition' do
  specify 'config object definition, instantiation, settings access and mutation' do
    class SimpleConfig < Qonfig::DataSet
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
    config = SimpleConfig.new

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq(:native)
    expect(config.settings.serializers.xml).to eq(:native)
    expect(config.settings.mutations.action.query).to eq(nil)
    expect(config.settings.steps).to eq(22)
    expect(config.settings.defaults).to eq(nil)
    expect(config.settings.shared.convert).to eq(false)

    # access via index named as a setting key
    expect(config.settings[:serializers][:json]).to eq(:native)
    expect(config.settings[:serializers][:xml]).to eq(:native)
    expect(config.settings[:mutations][:action][:query]).to eq(nil)
    expect(config.settings[:steps]).to eq(22)

    # hash representation
    expect(config.to_h).to match(
      'serializers' => {
        'json' => :native,
        'xml' => :native
      },
      'defaults' => nil,
      'shared' => {
        'convert' => false
      },
      'mutations' => {
        'action' => {
          'query' => nil
        }
      },
      'steps' => 22
    )

    # configuration via block (classic style)
    config.configure do |conf|
      conf.serializers.json = :oj
      conf.serializers.xml = :ox
      conf.mutations.action.query = 'select'
      conf.steps = 31
    end

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq(:oj)
    expect(config.settings.serializers.xml).to eq(:ox)
    expect(config.settings.mutations.action.query).to eq('select')
    expect(config.settings.steps).to eq(31)

    # access via option index named as a setting key
    expect(config.settings[:serializers][:json]).to eq(:oj)
    expect(config.settings[:serializers][:xml]).to eq(:ox)
    expect(config.settings[:mutations][:action][:query]).to eq('select')
    expect(config.settings[:steps]).to eq(31)

    # configuration via settings method
    config.settings.serializers.json = 'circular'
    config.settings.serializers.xml = 'angular'
    config.settings.mutations.action.query = :update
    config.settings.steps = nil

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq('circular')
    expect(config.settings.serializers.xml).to eq('angular')
    expect(config.settings.mutations.action.query).to eq(:update)
    expect(config.settings.steps).to eq(nil)

    # access via option index named as a setting key
    expect(config.settings[:serializers][:json]).to eq('circular')
    expect(config.settings[:serializers][:xml]).to eq('angular')
    expect(config.settings[:mutations][:action][:query]).to eq(:update)
    expect(config.settings[:steps]).to eq(nil)

    # configuration via index accessing
    config.settings[:serializers][:json] = 'pararam'
    config.settings[:serializers][:xml] = 'tratata'
    config.settings[:mutations][:action][:query] = :upsert
    config.settings[:steps] = 1234

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq('pararam')
    expect(config.settings.serializers.xml).to eq('tratata')
    expect(config.settings.mutations.action.query).to eq(:upsert)
    expect(config.settings.steps).to eq(1234)

    # access via option index named as a setting key
    expect(config.settings[:serializers][:json]).to eq('pararam')
    expect(config.settings[:serializers][:xml]).to eq('tratata')
    expect(config.settings[:mutations][:action][:query]).to eq(:upsert)
    expect(config.settings[:steps]).to eq(1234)

    # instant configuration via proc
    config = SimpleConfig.new do |conf|
      conf.serializers.json = :native
      conf.serializers.xml = :native
      conf.mutations.action.query = 'delete'
      conf.steps = 0
    end

    # access via method named as a setting key
    expect(config.settings.serializers.json).to eq(:native)
    expect(config.settings.serializers.xml).to eq(:native)
    expect(config.settings.mutations.action.query).to eq('delete')
    expect(config.settings.steps).to eq(0)

    # access via option index named as a setting key
    expect(config.settings[:serializers][:json]).to eq(:native)
    expect(config.settings[:serializers][:xml]).to eq(:native)
    expect(config.settings[:mutations][:action][:query]).to eq('delete')
    expect(config.settings[:steps]).to eq(0)

    # attempt to get an access to the unexistent setting
    expect { config.settings.deserialization }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings.mutations.global }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings[:deserialization] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings.mutations[:global] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.settings.mutations[:global] = 1 }.to raise_error(Qonfig::UnknownSettingError)

    # hash representation
    expect(config.to_h).to match(
      'serializers' => {
        'json' => :native,
        'xml' => :native
      },
      'defaults' => nil,
      'shared' => {
        'convert' => false
      },
      'mutations' => {
        'action' => {
          'query' => 'delete'
        }
      },
      'steps' => 0
    )
  end

  specify 'configuration via hash / hash + proc (instant and not)' do
    class HashConfigurableConfig < Qonfig::DataSet
      setting :a do
        setting :b
        setting :c
      end

      setting :d
      setting :e
    end

    # configure by hash (via .new)
    config = HashConfigurableConfig.new(
      a: {
        b: { g: 33 },
        c: 2
      },
      d: 33,
      e: { f: 49 }
    )
    expect(config.to_h).to match(
      'a' => {
        'b' => { g: 33 },
        'c' => 2
      },
      'd' => 33,
      'e' => { f: 49 }
    )

    # configure by hash (via #configure)
    config = HashConfigurableConfig.new
    config.configure(
      a: {
        b: 'test',
        c: 'no_test'
      },
      d: 100_500,
      e: false
    )
    expect(config.to_h).to match(
      'a' => {
        'b' => 'test',
        'c' => 'no_test'
      },
      'd' => 100_500,
      'e' => false
    )

    # mixed: configure by hash + proc (via .new)
    config = HashConfigurableConfig.new(d: false, e: true) do |conf|
      conf.a.b = 123
      conf.a.c = 456
    end
    expect(config.to_h).to match(
      'a' => {
        'b' => 123,
        'c' => 456
      },
      'd' => false,
      'e' => true
    )

    # mixed: configure by hash + proc (via #configure)
    config = HashConfigurableConfig.new
    config.configure(a: { b: { c: 49 }, c: 55 }) do |conf|
      conf.d = 0.55
      conf.e = false
    end
    expect(config.to_h).to match(
      'a' => {
        'b' => { c: 49 },
        'c' => 55
      },
      'd' => 0.55,
      'e' => false
    )

    # proc has higher priority
    config = HashConfigurableConfig.new(a: { b: 1, c: 2 }, d: 3, e: 4) do |conf|
      conf.a.b = 5
      conf.a.c = 6
      conf.d = 7
      conf.e = 8
    end
    expect(config.to_h).to match(
      'a' => {
        'b' => 5,
        'c' => 6
      },
      'd' => 7,
      'e' => 8
    )

    expect do
      # nonexistent nested key
      HashConfigurableConfig.new(a: { e: 55 })
    end.to raise_error(Qonfig::UnknownSettingError)
    expect do
      # nonexistend nested key + proc
      HashConfigurableConfig.new(a: { e: 55 }) { |conf| conf.d = 'test' }
    end.to raise_error(Qonfig::UnknownSettingError)

    expect do
      # nonexistent root key
      HashConfigurableConfig.new(g: 'test')
    end.to raise_error(Qonfig::UnknownSettingError)
    expect do
      # nonexistent root key + proc
      HashConfigurableConfig.new(g: 'test') { |conf| conf.e = false }
    end.to raise_error(Qonfig::UnknownSettingError)

    expect do
      # attempt to override nested settings
      HashConfigurableConfig.new(a: 100)
    end.to raise_error(Qonfig::AmbiguousSettingValueError)
    expect do
      # attempt to override nested settings (+ proc)
      HashConfigurableConfig.new(a: 100) { |conf| conf.a.b = :none }
    end.to raise_error(Qonfig::AmbiguousSettingValueError)

    # attempt to use non-hash object
    [1, 1.0, Object.new, true, false, Class.new, Module.new, (proc {}), (-> {})].each do |non_hash|
      expect do
        # without proc
        HashConfigurableConfig.new(non_hash)
      end.to raise_error(Qonfig::ArgumentError)

      expect do
        # with valid proc
        HashConfigurableConfig.new(non_hash) { |conf| conf.d = 55 }
      end.to raise_error(Qonfig::ArgumentError)
    end
  end

  specify 'only string and symbol keys are supported' do
    [1, 1.0, Object.new, true, false, Class.new, Module.new, (proc {}), (-> {})].each do |key|
      expect do
        Class.new(Qonfig::DataSet) { setting(key) }
      end.to raise_error(Qonfig::ArgumentError)
    end

    expect do
      Class.new(Qonfig::DataSet) do
        setting :a
        setting 'b'
      end
    end.not_to raise_error
  end

  specify 'causes an error when tries to assign a setting value to an option ' \
          'which already have another nested options' do
    class WithNestedOptionsConfig < Qonfig::DataSet
      setting :database do
        setting :hostname, 'localhost'
      end
    end

    config = WithNestedOptionsConfig.new

    expect do
      config.configure { |conf| conf.database = double }
    end.to raise_error(Qonfig::AmbiguousSettingValueError)

    expect do
      config.configure { |conf| conf[:database] = double }
    end.to raise_error(Qonfig::AmbiguousSettingValueError)

    expect do
      config.configure { |conf| conf[:database][:hostname] = double }
    end.not_to raise_error

    expect do
      config.configure { |conf| conf.database.hostname = double }
    end.not_to raise_error
  end

  specify 'fails when tries to use a non-string/non-symbol value as a setting key' do
    incorrect_key_values = [123, Object.new, 15.1, (proc {}), Class.new, true, false]
    correct_key_values   = ['test', :test]

    incorrect_key_values.each do |incorrect_key|
      # check root
      expect do
        Class.new(Qonfig::DataSet) { setting incorrect_key }
      end.to raise_error(Qonfig::ArgumentError)

      # check nested
      expect do
        Class.new(Qonfig::DataSet) do
          setting incorrect_key do
            setting :any
          end
        end
      end.to raise_error(Qonfig::ArgumentError)

      # check nested
      expect do
        Class.new(Qonfig::DataSet) do
          setting :any do
            setting incorrect_key
          end
        end
      end.to raise_error(Qonfig::ArgumentError)
    end

    correct_key_values.each do |correct_key|
      # check root
      expect do
        Class.new(Qonfig::DataSet) do
          setting correct_key
        end
      end.not_to raise_error

      # check nested
      expect do
        Class.new(Qonfig::DataSet) do
          setting correct_key do
            setting :any
          end
        end
      end.not_to raise_error

      # check nested do
      expect do
        Class.new(Qonfig::DataSet) do
          setting :any do
            setting correct_key
          end
        end
      end.not_to raise_error
    end
  end
end
