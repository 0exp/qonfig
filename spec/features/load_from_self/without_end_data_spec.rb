# frozen_string_literal: true

describe 'Load from self (without __END__ data)' do
  specify 'fails when yaml data is not represented as a hash' do
    class MissingSelfDataConfig < Qonfig::DataSet
      load_from_self
    end

    expect { MissingSelfDataConfig.new }.to raise_error(Qonfig::SelfDataNotFoundError)
  end
end
