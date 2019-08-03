# frozen_string_literal: true

describe 'Iteration over setting keys (#each_setting / #deep_each_setting)' do
  let(:config) do
    Class.new(Qonfig::DataSet) do
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
          setting :data, test: false
        end
      end

      setting :telegraf_url, 'udp://localhost:8094'
      setting :telegraf_prefix, 'test'
    end.new
  end

  specify '#each_setting provides ("key" => value) format' do
    key_value_pairs = {}.tap do |pairs|
      config.each_setting do |setting_key, setting_value|
        pairs[setting_key] = setting_value
      end
    end

    expect(key_value_pairs).to match(
      'db' => config.settings.db,
      'telegraf_url' => 'udp://localhost:8094',
      'telegraf_prefix' => 'test'
    )
  end

  specify '#deep_each_setting provides ("key.sub_key.subkey" => value) format' do
    key_value_pairs = {}.tap do |pairs|
      config.deep_each_setting do |setting_key, setting_value|
        pairs[setting_key] = setting_value
      end
    end

    expect(key_value_pairs).to match(
      'db.creds.user' => 'D@iVeR',
      'db.creds.password' => 'test123',
      'db.creds.data' => { test: false },
      'telegraf_url' => 'udp://localhost:8094',
      'telegraf_prefix' => 'test'
    )
  end
end
