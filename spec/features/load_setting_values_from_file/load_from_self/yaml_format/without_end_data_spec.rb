# frozen_string_literal: true

describe '.values_file / #load_from_self (without __END__ data) (YAML format)' do
  describe 'DSL macros' do
    context 'strict behavior' do
      let(:config_klass) do
        Class.new(Qonfig::DataSet) do
          values_file :self, format: :yaml, strict: true
          setting :user, 'D@iVeR'
        end
      end

      specify 'fails with Qonfig::SelfDataNotFoundError' do
        expect { config_klass.new }.to raise_error(Qonfig::SelfDataNotFoundError)
      end
    end

    context 'non-strict behavior (default)' do
      let(:config_klass) do
        Class.new(Qonfig::DataSet) do
          values_file :self, format: :yaml
          setting :user, 'D@iVeR'
        end
      end

      specify 'config instantiation works well :)' do
        config = nil
        expect { config = config_klass.new }.not_to raise_error
        expect(config.settings.user).to eq('D@iVeR')
      end
    end
  end

  describe 'Instance method' do
    context 'strict behavior (default)' do
      let(:config_klass) do
        Class.new(Qonfig::DataSet) { setting :user, 'D@iVeR' }
      end

      specify 'fails with Qonfig::SelfDataNotFoundError' do
        config = config_klass.new

        expect do
          config.load_from_self(format: :yaml, strict: true)
        end.to raise_error(Qonfig::SelfDataNotFoundError)
      end
    end

    context 'non-strict behavior' do
      let(:config_klass) do
        Class.new(Qonfig::DataSet) { setting :user, 'D@iVeR' }
      end

      specify 'no errors :)' do
        config = config_klass.new

        expect do
          config.load_from_self(format: :yaml, strict: false)
        end.not_to raise_error

        expect(config.settings.user).to eq('D@iVeR')
      end
    end
  end
end
