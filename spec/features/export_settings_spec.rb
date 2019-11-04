# frozen_string_literal: true

describe 'Export settings as instance-level access methods' do
  let(:config) do
    Qonfig::DataSet.build do
      setting :credentials do
        setting :login, '0exp'
        setting :password, 'test123'
      end

      setting :queue do
        setting :adapter, :sidekiq
        setting :threads, 10
      end
    end
  end

  specify '<non-raw export> (concrete keys as values and keys with nestings as a hash)' do
    my_simple_object = Object.new

    config.export_settings(
      my_simple_object,
      'credentials',
      mappings: { adapter: 'queue.adapter' },
      prefix: 'config_'
    )

    expect(my_simple_object).to respond_to(:config_credentials) # NOTE: hash
    expect(my_simple_object).to respond_to(:config_adapter) # NOTE: value
    expect(my_simple_object.config_credentials).to be_a(Hash)

    expect(my_simple_object.config_credentials).to match('login' => '0exp', 'password' => 'test123')
    expect(my_simple_object.config_adapter).to eq(:sidekiq)
  end

  specify '<raw export> (concrete keys as values and keys with nestings as Qonfig::Settings)' do
    my_simple_object = Object.new

    config.export_settings(
      my_simple_object,
      'credentials',
      mappings: { adapter: 'queue.adapter' },
      prefix: 'kek_',
      raw: true
    )

    expect(my_simple_object).to respond_to(:kek_credentials) # NOTE: Qonfig::Settings
    expect(my_simple_object).to respond_to(:kek_adapter) # NOTE: value
    expect(my_simple_object.kek_credentials).to be_a(Qonfig::Settings)

    expect(my_simple_object.kek_credentials.login).to eq('0exp')
    expect(my_simple_object.kek_credentials.password).to eq('test123')
    expect(my_simple_object.kek_adapter).to eq(:sidekiq)
  end
end
