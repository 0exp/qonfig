# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::MethodBased
  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :setting_key_pattern

  # @return [Symbol, String]
  #
  # @api private
  # @since 0.13.0
  attr_reader :runtime_validation_method

  # @param setting_key_pattern [String, Symbol]
  # @param runtime_validation_method [String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(setting_key_pattern, runtime_validation_method)
    @setting_key_pattern = setting_key_pattern
    @runtime_validation_method = runtime_validation_method
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def validate(data_set)
  end
end
