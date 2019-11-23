# frozen_string_literal: true

describe 'Run code with temporary settings' do
  specify 'temporary settings works as expected :)' do
    config = Qonfig::DataSet.build do
      setting :api do
        setting :token, 'test123'
        setting :login, 'D@iVeR'
      end
    end

    config.with(api: { token: '123test' }) do
      config.settings.api.login = '555'

      # NOTE: settings was changed
      expect(config.settings.api.token).to eq('123test')
      expect(config.settings.api.login).to eq('555')
    end

    # NOTE: original settings are still original :)
    expect(config.settings.api.token).to eq('test123')
    expect(config.settings.api.login).to eq('D@iVeR')
  end

  specify 'thread-safety' do
    config = Qonfig::DataSet.build do
      setting :api do
        setting :token, 'test123'
        setting :login, 'D@iVeR'
      end

      setting :credentials do
        setting :user, 'admin'
        setting :password, '1234asdf'
      end
    end

    ThreadGroup.new.tap do |thread_group|
      10.times do
        thread_group.add(Thread.new do
          # NOTE: change settings temporary
          config.with(api: { token: '777555' }, credentials: { password: 'test123' }) do
            config.settings.credentials.user = 'nimda'
          end
        end)

        thread_group.add(Thread.new do
          # NOTE: settings are not changed :)
          expect(config.settings.credentials.user).to eq('admin')
          expect(config.settings.credentials.password).to eq('1234asdf')
          expect(config.settings.api.token).to eq('test123')
          expect(config.settings.api.login).to eq('D@iVeR')
        end)

        thread_group.add(Thread.new do
          # NOTE: change settings temporary
          config.with do
            config.settings.api.login = 'provider'
            config.settings.api.token = 'super_puper_123'
          end
        end)

        thread_group.add(Thread.new do
          # NOTE: settings are not changed :)
          expect(config.settings.credentials.user).to eq('admin')
          expect(config.settings.credentials.password).to eq('1234asdf')
          expect(config.settings.api.token).to eq('test123')
          expect(config.settings.api.login).to eq('D@iVeR')
        end)

        thread_group.add(Thread.new do
          config.with(api: { login: '0exp' }, credentials: { user: 'D@iVeR' }) do
            config.settings.api.token = 'kekpek123'
            config.settings.credentials.password = 'admin'
          end
        end)

        thread_group.add(Thread.new do
          # NOTE: settings are not changed :)
          expect(config.settings.credentials.user).to eq('admin')
          expect(config.settings.credentials.password).to eq('1234asdf')
          expect(config.settings.api.token).to eq('test123')
          expect(config.settings.api.login).to eq('D@iVeR')
        end)

        thread_group.add(Thread.new do
          # NOTE: change settings temporary
          config.with(api: { login: 'mobile_legends' }, credentials: { user: 'dota2' }) do
            config.settings.api.token = 'league_of_legends'
            config.settings.credentials.password = 'overwatch'
          end
        end)

        thread_group.add(Thread.new do
          # NOTE: settings are not changed :)
          expect(config.settings.credentials.user).to eq('admin')
          expect(config.settings.credentials.password).to eq('1234asdf')
          expect(config.settings.api.token).to eq('test123')
          expect(config.settings.api.login).to eq('D@iVeR')
        end)
      end
    end.list.map(&:join)
  end
end
