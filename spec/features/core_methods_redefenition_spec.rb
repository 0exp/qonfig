# frozen_string_literal: true

describe 'Core methods redefinition' do
  specify 'fails when setting key intersects with any internal Qonfig::Settings core method' do
    core_methods = (
      Qonfig::Settings.instance_methods(false) |
      Qonfig::Settings.private_instance_methods(false)
    )

    expect(core_methods).not_to include(:super_test_key)

    core_methods.each do |core_method|
      expect do
        Class.new(Qonfig::DataSet) do
          setting core_method
        end
      end.to raise_error(Qonfig::CoreMethodIntersectionError)

      expect do
        Class.new(Qonfig::DataSet) do
          setting :super_test_key do
            setting core_method
          end
        end
      end.to raise_error(Qonfig::CoreMethodIntersectionError)
    end
  end
end
