# frozen_string_literal: true

describe 'Get config values' do
  subject(:config) do
    Qonfig::DataSet.build do
      setting :some_nested_setting do
        setting :username, 'your_cool_name_here'
        setting :password, 'secure_password'
      end

      setting :role, 'cool guy'
    end.settings
  end

  describe '#[]' do
    it 'properly gets value by value' do
      expect(config[:some_nested_setting][:username]).to eq('your_cool_name_here')
      expect(config[:some_nested_setting][:password]).to eq('secure_password')
      expect(config[:role]).to eq('cool guy')
    end

    context 'with key path' do
      it 'properly gets value' do
        expect(config[:some_nested_setting, :username]).to eq('your_cool_name_here')
        expect(config[:some_nested_setting, :password]).to eq('secure_password')
      end
    end

    context "when setting doesn't exist" do
      it 'raises error' do
        expect { config[:some_nested_setting, :kek] }.to raise_error(Qonfig::UnknownSettingError)
      end
    end

    context 'when zero arguments passed' do
      it 'raises error' do
        expect { config[] }.to raise_error(Qonfig::ArgumentError)
      end
    end
  end
end
