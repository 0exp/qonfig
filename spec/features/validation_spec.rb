# frozen_string_literal: true

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
  end
end
