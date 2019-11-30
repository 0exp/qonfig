# frozen_string_literal: true

describe 'Settings redefinition' do
  specify do
    class BaseRedefinableConfig < Qonfig::DataSet
      setting :nested do
        setting :some_key, 100_500
      end
    end

    class ChildRedefinitionConfig < BaseRedefinableConfig
      re_setting :nested, :some_value
    end

    class AnotherChildRedefinitionConfig < BaseRedefinableConfig
      re_setting :nested do
        setting :another_key, 'test'
      end
    end

    redefinable_config = BaseRedefinableConfig.new
    expect(redefinable_config[:nested][:some_key]).to eq(100_500)

    child_redefinition_config = ChildRedefinitionConfig.new
    expect(child_redefinition_config[:nested]).to eq(:some_value)

    another_child_redefinition_config = AnotherChildRedefinitionConfig.new
    expect(another_child_redefinition_config[:nested][:another_key]).to eq('test')
  end
end
