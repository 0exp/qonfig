# frozen_string_literal: true

describe '#dig-functionality (Hash#dig-like behaviour)' do
  specify '#dig functionality works as expected :)' do
    class DiggingConfig < Qonfig::DataSet
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
          setting :data, test: false
        end
      end
    end

    config = DiggingConfig.new

    # acces to a value
    expect(config.dig(:db, :creds, :user)).to eq('D@iVeR')
    expect(config.dig('db', :creds, 'password')).to eq('test123')
    expect(config.dig('db', 'creds', 'data')).to match(test: false)

    # access to the settings
    expect(config.dig(:db, :creds)).to be_a(Qonfig::Settings)
    expect(config.dig(:db)).to be_a(Qonfig::Settings)

    # try to dig into the hash value (setting with a hash value)
    expect { config.dig(:db, :creds, :user, :test) }.to raise_error(Qonfig::UnknownSettingError)

    # rubocop:disable Lint/RedundantSplatExpansion
    # dig with empty key lists
    expect { config.dig(*[]) }.to raise_error(Qonfig::ArgumentError)
    expect { config.dig }.to raise_error(Qonfig::ArgumentError)
    # rubocop:enable Lint/RedundantSplatExpansion

    # dig into unexistent option
    expect do
      config.dig(:db, :creds, :session)
    end.to raise_error(Qonfig::UnknownSettingError)

    # dig into unexistent option
    expect do
      config.dig(:a, :b, :c, :d)
    end.to raise_error(Qonfig::UnknownSettingError)
  end
end
