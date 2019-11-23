# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
describe '(#slice/#slice_value)-functionality' do
  specify '#slice/#slice_value functionality works as expected :)' do
    class SlicingConfig < Qonfig::DataSet
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :data, test: false
        end
      end
    end

    config = SlicingConfig.new

    db_slice    = { 'db' => { 'creds' => { 'user' => 'D@iVeR', 'data' => { test: false } } } }
    creds_slice = { 'creds' => { 'user' => 'D@iVeR', 'data' => { test: false } } }
    user_slice  = { 'user' => 'D@iVeR' }
    data_slice  = { 'data' => { test: false } }

    # access to the slice (with indifferent keys type)
    expect(config.slice(:db)).to match(db_slice)
    expect(config.slice('db', :creds)).to match(creds_slice)
    expect(config.slice(:db, 'creds', :user)).to match(user_slice)
    expect(config.slice(:db, :creds, 'data')).to match(data_slice)

    # try to slice with with unexistent keys
    expect { config.slice(:db, :creds, :megazavr) }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice(:db, :test) }.to raise_error(Qonfig::UnknownSettingError)

    # you cant slice over setting values - you can do it only over the setting keys!
    expect { config.slice(:db, :creds, :data, :test) }.to raise_error(Qonfig::UnknownSettingError)

    # slice with empty key list
    # rubocop:disable Lint/RedundantSplatExpansion
    expect { config.slice(*[]) }.to raise_error(Qonfig::ArgumentError)
    expect { config.slice }.to raise_error(Qonfig::ArgumentError)
    # rubocop:enable Lint/RedundantSplatExpansion

    # slice over unexistent option
    expect { config.slice(:db, :creds, :session) }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice(:a, :b, :c, :d) }.to raise_error(Qonfig::UnknownSettingError)

    # access to the sliced value (with indifferent keys type)
    expect(config.slice_value(:db)).to match(db_slice['db'])
    expect(config.slice_value('db', :creds)).to match(creds_slice['creds'])
    expect(config.slice_value(:db, 'creds', :user)).to eq(user_slice['user'])
    expect(config.slice_value(:db, :creds, 'data')).to match(data_slice['data'])

    # try to slice value over with unexistent keys
    expect { config.slice_value(:db, :creds, :megazavr) }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value(:db, :test) }.to raise_error(Qonfig::UnknownSettingError)

    # you cant slice over setting values - you can do it only over the setting keys!
    expect { config.slice_value(:db, :creds, :data, :test) }.to raise_error(Qonfig::UnknownSettingError)

    # slice with empty key list
    # rubocop:disable Lint/RedundantSplatExpansion
    expect { config.slice_value(*[]) }.to raise_error(Qonfig::ArgumentError)
    expect { config.slice_value }.to raise_error(Qonfig::ArgumentError)
    # rubocop:enable Lint/RedundantSplatExpansion

    # slice over unexistent option
    expect { config.slice_value(:db, :creds, :session) }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value(:a, :b, :c, :d) }.to raise_error(Qonfig::UnknownSettingError)
  end
end
# rubocop:enable Metrics/LineLength
