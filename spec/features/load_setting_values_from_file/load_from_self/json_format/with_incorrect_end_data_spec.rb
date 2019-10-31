# frozen_string_literal: true

describe '.values_file / #load_from_self (with incorrect __END__ data) (JSON format)' do
  describe 'DSL macros' do
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        values_file :self, format: :json
        setting :user, 'D@iVeR'
      end
    end

    specify 'fails with corresponding error' do
      expect { config_klass.new }.to raise_error(Qonfig::JSONLoaderParseError)
    end
  end

  describe 'Instance method' do
    let(:config) do
      Qonfig::DataSet.build { setting :user, 'D@iVeR' }
    end

    specify 'fails with corresponding error' do
      expect { config.load_from_self(format: :json) }.to raise_error(Qonfig::JSONLoaderParseError)
      expect(config.settings.user).to eq('D@iVeR')
    end
  end
end

__END__

{
  "user": "0exp",
  "Asdf"|"ASDF"
}
