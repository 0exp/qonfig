# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::Builder::AttributeConsistency
  class << self
    # @param setting_key_pattern [String, Symbol, NilClass]
    # @param runtime_validation_method [String, Symbol, NilClass]
    # @param validation_logic [Proc, NilClass]
    # @return [void]
    #
    # @api private
    # @since 0.13.0
    def check!(setting_key_pattern, runtime_validation_method, validation_logic)
      new(setting_key_pattern, runtime_validation_method, validation_logic).check!
    end
  end

  # @param setting_key_pattern [String, Symbol, NilClass]
  # @param runtime_validation_method [String, Symbol, NilClass]
  # @param validation_logic [Proc, NilClass]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(setting_key_pattern, runtime_validation_method, validation_logic)
    @setting_key_pattern = setting_key_pattern
    @runtime_validation_method = runtime_validation_method
    @validation_logic = validation_logic
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def check!
    consistent_method_choice!
    cosnistent_runtime_validation_method!
    consistent_validation_logic!
    consistent_setting_key_pattern!
  end

  private

  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :setting_key_pattern

  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :runtime_validation_method

  # @return [Proc, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :validation_logic

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_method_choice!
    unless runtime_validation_method || validation_logic
      raise(
        Qonfig::ValidatorArgumentError,
        'Empty validation (you should provide a method name or a proc)'
      )
    end

    if runtime_validation_method && validation_logic
      raise(
        Qonfig::ValidatorArgumentError,
        'Incosistent validation (you should provide either a method or a proc)'
      )
    end
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def cosnistent_runtime_validation_method!
    return if runtime_validation_method.nil?
    return if runtime_validation_method.is_a?(Symbol)
    return if runtime_validation_method.is_a?(String)

    raise(
      Qonfig::ValidatorArgumentError,
      'Incompatible validation method name (should be a symbol or a string)'
    )
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_validation_logic!
    return if validation_logic.nil?
    return if validation_logic.is_a?(Proc)

    # :nocov:
    raise(
      Qonfig::ValidatorArgumentError,
      'Incompatible validation object (should be a proc)'
    )
    # :nocov:
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_setting_key_pattern!
    return if setting_key_pattern.nil?
    return if setting_key_pattern.is_a?(Symbol)
    return if setting_key_pattern.is_a?(String)

    raise(
      Qonfig::ValidatorArgumentError,
      'Incompatible setting key pattern (should be a string or a symbol)'
    )
  end
end
