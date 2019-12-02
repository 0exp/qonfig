# frozen_string_literal: true

describe 'Compact config' do
  specify do
    Qonfig.plugin(:pretty_print)

    class CompactCheckConfig < Qonfig::DataSet
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
          setting :data, test: false
        end
      end

      setting :logger, nil
      setting :graphql_endpoint, 'https://localhost:1234/graphql'
    end

    c = CompactCheckConfig.new.compacted
  end
end
