# frozen_string_literal: true

describe 'Compacted config' do
  specify 'has all settings keys as readers and writers at the root of object' do
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

    compacted_config = CompactCheckConfig.new.compacted

    # NOTE: check readers
    expect(compacted_config.db.creds.user).to eq('D@iVeR')
    expect(compacted_config.db.creds.password).to eq('test123')
    expect(compacted_config.db.creds.data).to eq({ test: false})
    expect(compacted_config.logger).to eq(nil)
    expect(compacted_config.graphql_endpoint).to eq('https://localhost:1234/graphql')

    # NOTE: check writers
    # ambigous write is inmpossible
    expect { compacted_config.db = :test }.to raise_error(Qonfig::AmbiguousSettingValueError)
    expect { compacted_config.db.creds = :test }.to raise_error(Qonfig::AmbiguousSettingValueError)
    # regular write is possible :)
    compacted_config.db.creds.user = '0exp'
    compacted_config.db.creds.password = '123test'
    compacted_config.db.creds.data = { no: :errors }
    compacted_config.logger = :logger
    compacted_config.graphql_endpoint = 'https://localhost:4321/graphql'
    # corresponding values was correctly assigned
    expect(compacted_config.db.creds.user).to eq('0exp')
    expect(compacted_config.db.creds.password).to eq('123test')
    expect(compacted_config.db.creds.data).to eq({ no: :errors })
    expect(compacted_config.logger).to eq(:logger)
    expect(compacted_config.graphql_endpoint).to eq('https://localhost:4321/graphql')
  end
end
