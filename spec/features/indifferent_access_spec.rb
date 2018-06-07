# frozen_string_literal: true

describe 'Indifferent Access' do
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
end
