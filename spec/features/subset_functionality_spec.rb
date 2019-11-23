# frozen_string_literal: true

describe '(#subset)-functionality' do
  specify '#subset functionality works as expected :)' do
    class SubsetableConfig < Qonfig::DataSet
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :data, test: false
        end
      end

      setting :adapter, :sidekiq
    end

    config = SubsetableConfig.new

    # access to the subset (with indifferent keys type)
    expect(config.subset(:db, ['db', :creds], ['db', 'creds', :user], 'adapter')).to match(
      'db' => { 'creds' => { 'user' => 'D@iVeR', 'data' => { test: false } } }, # :db
      'creds' => { 'user' => 'D@iVeR', 'data' => { test: false } }, # ['db', :creds]
      'user' => 'D@iVeR', # ['db', 'creds', :user]
      'adapter' => :sidekiq # 'adepter'
    )

    # try to use subset with with unexistent keys
    # NOTE: :megazavr key does not exist
    expect { config.subset(%i[db creds megazavr]) }.to raise_error(Qonfig::UnknownSettingError)
    # NOTE: :test key does not exist
    expect { config.subset(:db, :test) }.to raise_error(Qonfig::UnknownSettingError)

    # you cant use subset operation over setting values - you can do it only over the setting keys!
    expect { config.subset(%i[db creds data test]) }.to raise_error(Qonfig::UnknownSettingError)

    # subset invokation with empty key list
    # rubocop:disable Lint/RedundantSplatExpansion
    expect(config.subset(*[])).to eq({})
    expect(config.subset).to eq({})
    # rubocop:enable Lint/RedundantSplatExpansion

    # subset invokation over unexistent option
    expect { config.subset(%i[db creds session]) }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.subset(%i[a b c d]) }.to raise_error(Qonfig::UnknownSettingError)

    # invokation with incorret subset key attributes
    expect { config.subset([:db, :creds, Object.new]) }.to raise_error(Qonfig::ArgumentError)
    expect { config.subset(:db, 123) }.to raise_error(Qonfig::ArgumentError)
  end
end
