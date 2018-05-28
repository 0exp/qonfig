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

  specify 'indifferently accessable options (directly via index; via string / via symbol)' do
    class IndifferentlyAccessableConfig < Qonfig::DataSet
      setting :project_id, 10
    end

    class AnotherIndifferentlyAccessableConfig < Qonfig::DataSet
      compose IndifferentlyAccessableConfig

      setting 'database' do
        setting :hostname, 'localhost'
      end
    end

    config = AnotherIndifferentlyAccessableConfig.new

    # indifferent access via string / via symbol
    expect(config.settings[:project_id]).to eq(10)
    expect(config.settings['project_id']).to eq(10)
    expect(config.settings[:database][:hostname]).to eq('localhost')
    expect(config.settings['database']['hostname']).to eq('localhost')
    expect(config.settings['database'][:hostname]).to eq('localhost')
    expect(config.settings[:database]['hostname']).to eq('localhost')

    # direct access via [] on the config object
    expect(config[:project_id]).to eq(10)
    expect(config['project_id']).to eq(10)
    expect(config[:database][:hostname]).to eq('localhost')
    expect(config['database']['hostname']).to eq('localhost')
    expect(config['database'][:hostname]).to eq('localhost')
    expect(config[:database]['hostname']).to eq('localhost')

    # instant configuration with indifferently accessable options
    config.configure do |conf|
      conf['project_id'] = 1
      conf[:database]['hostname'] = 'google.com'
    end

    # indifferent access via string / via symbol
    expect(config.settings[:project_id]).to eq(1)
    expect(config.settings['project_id']).to eq(1)
    expect(config.settings[:database][:hostname]).to eq('google.com')
    expect(config.settings['database']['hostname']).to eq('google.com')
    expect(config.settings['database'][:hostname]).to eq('google.com')
    expect(config.settings[:database]['hostname']).to eq('google.com')

    # direct access via [] on the config object
    expect(config[:project_id]).to eq(1)
    expect(config['project_id']).to eq(1)
    expect(config[:database][:hostname]).to eq('google.com')
    expect(config['database']['hostname']).to eq('google.com')
    expect(config['database'][:hostname]).to eq('google.com')
    expect(config[:database]['hostname']).to eq('google.com')
  end

  specify 'causes an error when assigning a setting value to an option with nested options' do
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
      config.configure { |conf| conf[:database][:hostname] = double}
    end.not_to raise_error

    expect do
      config.configure { |conf| conf.database.hostname = double }
    end.not_to raise_error
  end
end
