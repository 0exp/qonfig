# frozen_string_literal: true

# @api private
# @since 0.13.0
# rubocop:disable Metrics/ClassLength
class Qonfig::Validator::Builder::AttributeConsistency
  class << self
    # @param setting_key_pattern [String, Symbol, NilClass]
    # @param predefined_validator [String, Symbol, NilClass]
    # @param runtime_validation_method [String, Symbol, NilClass]
    # @param strict [Boolean]
    # @param validation_logic [Proc, NilClass]
    # @return [void]
    #
    # @api private
    # @since 0.13.0
    def check!(
      setting_key_pattern,
      predefined_validator,
      runtime_validation_method,
      strict,
      validation_logic
    )
      new(
        setting_key_pattern,
        predefined_validator,
        runtime_validation_method,
        strict,
        validation_logic
      ).check!
    end
  end

  # @param setting_key_pattern [String, Symbol, NilClass]
  # @param predefined_validator [String, Symbol, NilClass]
  # @param runtime_validation_method [String, Symbol, NilClass]
  # @param validation_logic [Proc, NilClass]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(
    setting_key_pattern,
    predefined_validator,
    runtime_validation_method,
    strict,
    validation_logic
  )
    @setting_key_pattern = setting_key_pattern
    @predefined_validator = predefined_validator
    @runtime_validation_method = runtime_validation_method
    @strict = strict
    @validation_logic = validation_logic
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def check!
    consistent_strict_behaviour!
    consistent_method_choice!
    consistent_predefined_validator!
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
  attr_reader :predefined_validator

  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :runtime_validation_method

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  attr_reader :strict

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
    unless runtime_validation_method || validation_logic || predefined_validator
      raise(
        Qonfig::ValidatorArgumentError,
        'Empty validation (you should provide: dataset method OR proc OR predefined validator)'
      )
    end

    if ((runtime_validation_method && validation_logic) ||
       (predefined_validator && (runtime_validation_method || validation_logic)))
      raise(
        Qonfig::ValidatorArgumentError,
        'Incosistent validation (you should use: dataset method OR proc OR predefined validator)'
      )
    end
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.17.0
  def consistent_strict_behaviour!
    unless strict.is_a?(TrueClass) || strict.is_a?(FalseClass)
      raise(
        Qonfig::ValidatorArgumentError,
        ':strict should be a boolean'
      )
    end
  end

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_predefined_validator!
    return if predefined_validator.nil?
    return if predefined_validator.is_a?(Symbol)
    return if predefined_validator.is_a?(String)

    raise(
      Qonfig::ValidatorArgumentError,
      'Incorrect name of predefined validator (should be a symbol or a string)'
    )
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
# rubocop:enable Metrics/ClassLength
