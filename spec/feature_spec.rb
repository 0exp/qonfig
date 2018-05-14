# frozen_string_literal: true

describe 'Initial implementation' do
  specify do
    class Config < Qonfig::DataSet
      setting :serializers do
        setting :json do
          setting :engine, :native
        end
      end

      setting :serializers do
        setting :json do
          setting :option, :test
        end
      end
    end

    class AnotherConfig < Config
      setting :serializers do
        setting :json do
          setting :pekakeka, :chukap
        end
      end
    end

    class ComposableConfig < Qonfig::DataSet
      compose Config
      compose AnotherConfig
    end
  end
end
