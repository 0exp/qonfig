# frozen_string_literal: true

# @api private
# @since 0.13.0
module Qonfig::Validator::DSL
  class << self
    # @param child_klass [Qonfig::DataSet]
    # @return [void]
    #
    # @api private
    # @since 0.13.0
    def extended(child_klass)
      child_klass.instance_variable_set(:@validators, Qonfig::Validator::Collection.new)

      child_klass.singleton_class.prepend(Module.new do
        def inherited(child_klass)
          child_klass.instance_variable_set(:@validators, Qonfig::Validator::Collection.new)
          child_klass.validators.concat(validators)
          super
        end
      end)
    end
  end

  # @return [Qonfig::Validator::Collection]
  #
  # @api private
  # @since 0.13.0
  def validators
    @validators
  end

  # @param setting_key_pattern [String, Symbol, NilClass]
  # @option predefined [String, Symbol]
  # @option by [String, Symbol, NilClass]
  # @param custom_validation [Proc]
  # @return [void]
  #
  # @see Qonfig::Validator::Builder
  #
  # @api private
  # @since 0.13.0
  def validate(setting_key_pattern = nil, predefined = nil, by: nil, &custom_validation)
    validators << Qonfig::Validator::Builder.build(
      setting_key_pattern: setting_key_pattern,
      predefined_validator: predefined,
      runtime_validation_method: by,
      validation_logic: custom_validation
    )
  end
end
