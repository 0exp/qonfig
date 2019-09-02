# frozen_string_literal: true

describe '#load_from_self => format: :yaml' do
  specify ":yaml/:yml-format support" do
    class YamlEndDataConfig < Qonfig::DataSet
      setting :by_yml do
        load_from_self format: :yml # the same as :yaml
      end

      setting :by_yaml do
        load_from_self format: :yaml # the same as :yml
      end
    end

    config = YamlEndDataConfig.new

    # NOTE: format: :yml
    expect(config.settings.by_yml.credentials.user).to eq('admin')
    expect(config.settings.by_yml.credentials.password).to eq('123')
    expect(config.settings.by_yml.credentials.enabled).to eq(true)
    expect(config.settings.by_yml.amount).to eq(123.456)
    expect(config.settings.by_yml.data).to eq(nil)
    expect(config.settings.by_yml.methods).to eq([1, 'test', nil, true, false, ['data']])

    # NOTE: format: :yaml
    expect(config.settings.by_yaml.credentials.user).to eq('admin')
    expect(config.settings.by_yaml.credentials.password).to eq('123')
    expect(config.settings.by_yaml.credentials.enabled).to eq(true)
    expect(config.settings.by_yaml.amount).to eq(123.456)
    expect(config.settings.by_yaml.data).to eq(nil)
    expect(config.settings.by_yaml.methods).to eq([1, 'test', nil, true, false, ['data']])
  end
end

__END__

credentials:
  user: 'admin'
  password: '123'
  enabled: true
amount: 123.456
data: ~
methods:
  - 1
  - 'test'
  - ~
  - true
  - false
  - ['data']
