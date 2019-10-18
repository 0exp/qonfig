# frozen_string_literal: true

# TODO: review
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
    end

    expect(config.settings.api.token).to eq('test123')
    expect(config.settings.api.login).to eq('D@iVeR')
  end
end
