# frozen_string_literal: true

describe 'Instantiation without class definition' do
  specify '#build builds a config instance without a class' do
    config = Qonfig::DataSet.build do
      setting :credentials do
        setting :user, 'D@iVeR'
        setting :password, 'test123'
      end

      def custom_method(custom_param)
        custom_param
      end
    end

    expect(config).to be_a(Qonfig::DataSet)
    expect(config.settings.credentials.user).to eq('D@iVeR')
    expect(config.settings.credentials.password).to eq('test123')

    custom_param = rand(1..1000).to_s
    expect(config.custom_method(custom_param)).to eq(custom_param)
  end
end
