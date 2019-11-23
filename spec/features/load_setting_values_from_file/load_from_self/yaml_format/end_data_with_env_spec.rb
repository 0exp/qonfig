# frozen_string_literal: true

describe '.values_file / #load_from_self (__END__ data with env) (YAML format)' do
  describe 'DSL macros' do
    context '__END__ data has corresponding env key' do
      let(:config_klass) do
        Class.new(Qonfig::DataSet) do
          values_file :self, format: :yaml, expose: :production

          setting :user, 'D@iVeR'
          setting :queue do
            setting :adapter, 'que'
            setting :concurrency, 2
          end
        end
      end

      specify 'loads setting values of corresponding environment' do
        config = config_klass.new

        expect(config.settings.user).to eq('iAmDaiveR')
        expect(config.settings.queue.adapter).to eq('in_memory')
        expect(config.settings.queue.concurrency).to eq(50)
      end
    end

    context '__END__ data does not have correspodning env key' do
      let(:config_klass) do
        Class.new(Qonfig::DataSet) do
          values_file :self, format: :yaml, expose: :staging

          setting :user, 'D@iVeR'
          setting :queue do
            setting :adapter, 'que'
            setting :concurrency, 2
          end
        end
      end

      specify 'ignrores values from __END__ data' do
        config = config_klass.new

        expect(config.settings.user).to eq('D@iVeR')
        expect(config.settings.queue.adapter).to eq('que')
        expect(config.settings.queue.concurrency).to eq(2)
      end
    end
  end

  describe 'Instance method' do
    let(:config) do
      Qonfig::DataSet.build do
        setting :user, 'D@iVeR'
        setting :queue do
          setting :adapter, 'que'
          setting :concurrency, 2
        end
      end
    end

    context '__END__ data has corresponding env key' do
      specify 'loads setting values of corresponding environment' do
        config.load_from_self(format: :yaml, expose: :production)

        expect(config.settings.user).to eq('iAmDaiveR')
        expect(config.settings.queue.adapter).to eq('in_memory')
        expect(config.settings.queue.concurrency).to eq(50)
      end
    end

    context '__END__ data does not have correspodning env key' do
      specify 'ignrores values from __END__ data' do
        config.load_from_self(format: :yaml, expose: :staging)

        expect(config.settings.user).to eq('D@iVeR')
        expect(config.settings.queue.adapter).to eq('que')
        expect(config.settings.queue.concurrency).to eq(2)
      end
    end
  end
end

__END__

test:
  user: 0exp
  queue:
    adapter: sidekiq
    concurrency: 25
production:
  user: iAmDaiveR
  queue:
    adapter: in_memory
    concurrency: 50
