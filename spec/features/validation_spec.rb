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

      validate 'telegraf_prefix' do |value|
        value.is_a?(String)
      end
    end.new
  end

  specify do
    binding.pry
    config.settings.db.creds.user = :hui
  end
end
