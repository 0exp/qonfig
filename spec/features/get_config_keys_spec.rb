# frozen_string_literal: true

describe 'Get config keys' do
  let(:config) do
    Qonfig::DataSet.build do
      setting :credentials do
        setting :social do
          setting :service, 'instagram'
          setting :login, '0exp'
        end

        setting :admin do
          setting :enabled, true
        end
      end

      setting :server do
        setting :type, 'cloud'
        setting :options do
          setting :os, 'CentOS'
        end
      end
    end
  end

  specify '(#keys) existing keys' do
    expect(config.keys).to contain_exactly(
      'credentials.social.service',
      'credentials.social.login',
      'credentials.admin.enabled',
      'server.type',
      'server.options.os'
    )
  end

  specify '(#keys) all key variants' do
    expect(config.keys(all_variants: true)).to contain_exactly(
      'credentials',
      'credentials.social',
      'credentials.social.service',
      'credentials.social.login',
      'credentials.admin',
      'credentials.admin.enabled',
      'server',
      'server.type',
      'server.options',
      'server.options.os'
    )
  end

  specify '(#root_keys) only root keys' do
    expect(config.keys(only_root: true)).to contain_exactly(
      'credentials',
      'server'
    )

    expect(config.root_keys).to contain_exactly(
      'credentials',
      'server'
    )
  end
end
