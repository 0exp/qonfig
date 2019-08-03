# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::ProcBased
  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :setting_key_pattern

  # @return [Proc]
  #
  # @api private
  # @since 0.13.0
  attr_reader :valdiation

  # @param setting_key_pattern [String, Symbol, NilClass]
  # @param vaidation [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(setting_key_pattern, validation)
    @setting_key_pattern = setting_key_pattern
    @validation = validation
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def validate(data_set)
  end
end
