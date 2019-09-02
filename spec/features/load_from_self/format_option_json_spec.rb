# frozen_string_literal: true

describe '#load_from_self => format: :json' do
  specify ':json-format support' do
    class JsonEndDataConfig < Qonfig::DataSet
      load_from_self format: :json
    end

    config = JsonEndDataConfig.new

    expect(config.settings.credentials.user).to eq('admin')
    expect(config.settings.credentials.password).to eq('123')
    expect(config.settings.credentials.enabled).to eq(true)
    expect(config.settings.amount).to eq(123.456)
    expect(config.settings.data).to eq(nil)
    expect(config.settings.methods).to eq([1, 'test', nil, true, false, ['data']])
  end
end

__END__

{
  "credentials": {
    "user": "admin",
    "password": "123",
    "enabled": true
  },
  "amount": 123.456,
  "data": null,
  "methods": [1, "test", null, true, false, ["data"]]
}
