# frozen_string_literal: true

describe 'Plugins(toml): #load_from_self => format: :toml', :plugin do
  before do
    require 'toml-rb'
    Qonfig.plugin(:toml)
  end

  specify ':toml-format support' do
    class TomlEndDataConfig < Qonfig::DataSet
      load_from_self format: :toml
    end

    config = TomlEndDataConfig.new

    expect(config.settings.amount).to eq(123.456)
    expect(config.settings.methods).to eq([['test'], [true, false], [1, 2, 3]])
    expect(config.settings.credentials.user).to eq('admin')
    expect(config.settings.credentials.password).to eq('123')
    expect(config.settings.credentials.enabled).to eq(true)
  end
end

__END__

amount = 123.456
methods = [ [ "test" ], [ true, false ], [ 1, 2, 3 ] ]

[credentials]
user = "admin"
password = "123"
enabled = true
