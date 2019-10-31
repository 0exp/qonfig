# frozen_string_literal: true

describe 'Plugins(toml): .values_file / #load_from_self (with incorrect __END__ data)', :plugin do
  before do
    require 'toml-rb'
    Qonfig.plugin(:toml)
  end

  describe 'DSL macros' do
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        values_file :self, format: :toml
        setting :user, 'D@iVeR'
      end
    end

    specify 'fails with corresponding error' do
      expect { config_klass.new }.to raise_error(Qonfig::TOMLLoaderParseError)
    end
  end

  describe 'Instance method' do
    let(:config) do
      Qonfig::DataSet.build { setting :user, 'D@iVeR' }
    end

    specify 'fails with corresponding error' do
      expect { config.load_from_self(format: :toml) }.to raise_error(Qonfig::TOMLLoaderParseError)
      expect(config.settings.user).to eq('D@iVeR')
    end
  end
end

__END__

user = '0exp'
asdf|"ASD"
