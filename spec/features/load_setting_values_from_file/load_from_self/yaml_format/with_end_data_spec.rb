# frozen_string_literal: true

describe '.values_file / #load_from_self (with __END__ data) (YAML format)' do
  describe 'DSL macros' do
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        values_file :self, format: :yaml

        setting :user, 'D@iVeR'
        setting :queue do
          setting :adapter, 'que'
          setting :concurrency, 2
        end
      end
    end

    specify 'loads setting values from __END__ defined as YAML instructions' do
      config = config_klass.new

      expect(config.settings.user).to eq('0exp')
      expect(config.settings.queue.adapter).to eq('sidekiq')
      expect(config.settings.queue.concurrency).to eq(25)
    end

    specify 'foramt of __END__ data can be inferred automatically' do
      config = Qonfig::DataSet.build do
        values_file :self

        setting :user
        setting :queue do
          setting :adapter
          setting :concurrency
        end
      end

      expect(config.settings.user).to eq('0exp')
      expect(config.settings.queue.adapter).to eq('sidekiq')
      expect(config.settings.queue.concurrency).to eq(25)
    end

    specify 'fails when __END__ data has extra keys' do
      expect do
        Qonfig::DataSet.build { values_file :self }
      end.to raise_error(Qonfig::UnknownSettingError)

      expect do
        Qonfig::DataSet.build do
          values_file :self

          setting :user
          setting :queue do
            setting :adapter
            setting :concurrency
          end
        end
      end.not_to raise_error
    end
  end

  describe 'Instance method' do
    let(:config_klass) do
      Class.new(Qonfig::DataSet) do
        setting :user, 'D@iVeR'
        setting :queue do
          setting :adapter, 'que'
          setting :concurrency, 2
        end
      end
    end

    specify 'loads setting values from __END__ defined as YAML instructions' do
      config = config_klass.new

      expect(config.settings.user).to eq('D@iVeR')
      expect(config.settings.queue.adapter).to eq('que')
      expect(config.settings.queue.concurrency).to eq(2)

      config.load_from_self(format: :yaml)

      expect(config.settings.user).to eq('0exp')
      expect(config.settings.queue.adapter).to eq('sidekiq')
      expect(config.settings.queue.concurrency).to eq(25)
    end

    specify 'format of __END__ data can be inferred automatically' do
      config = config_klass.new
      config.load_from_self

      expect(config.settings.user).to eq('0exp')
      expect(config.settings.queue.adapter).to eq('sidekiq')
      expect(config.settings.queue.concurrency).to eq(25)
    end

    specify 'reloading process returns original values' do
      config = config_klass.new
      config.load_from_self
      config.reload!

      expect(config.settings.user).to eq('D@iVeR')
      expect(config.settings.queue.adapter).to eq('que')
      expect(config.settings.queue.concurrency).to eq(2)
    end

    specify 'fails when __END__ data has extra keys' do
      config = Qonfig::DataSet.build {}
      expect { config.load_from_self }.to raise_error(Qonfig::UnknownSettingError)

      config = Qonfig::DataSet.build do
        setting :user
        setting :queue do
          setting :adapter
          setting :concurrency
        end
      end

      expect { config.load_from_self }.not_to raise_error
    end
  end
end

__END__

user: 0exp
queue:
  adapter: sidekiq
  concurrency: 25
