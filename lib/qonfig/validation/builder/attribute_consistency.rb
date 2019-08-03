# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validation::Builder::AttributeConsistency
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
  # @raise [Qonfig::ArgumentError]
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
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_method_choice!
    unless runtime_validation_method || validation_logic
      raise(Qonfig::ArgumentError,"METHOD INST CHOSEN (you should provide method or proc")
    end

    if runtime_validation_method && validation_logic
      raise(Qonfig::ArgumetnError, "INCONSISTENT METHOD CHOICE (you should provde method or proc")
    end
  end

  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.13.0
  def cosnistent_runtime_validation_method!
    return if runtime_validation_method.nil?
    return if runtime_validation_method.is_a?(Symbol)
    return if runtime_validation_method.is_a?(String)

    raise(
      Qonfig::ArgumentError,
      "INCOMPATIBLE RUNTIME VALIDTION METHOD NAME (should be a string or a symbol)"
    )
  end

  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_validation_logic!
    return if validation_logic.nil?
    return if validation_logic.is_a?(Proc)

    raise(
      Qonfig::ArgumentError,
      "INCOMPATIBLE VALIDATION BLOCK (should be a proc)"
    )
  end

  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.13.0
  def consistent_setting_key_pattern!
    return if setting_key_pattern.nil?
    return if setting_key_pattern.is_a?(Symbol)
    return if setting_key_pattern.is_a?(String)

    raise(Qonfig::ArgumentError, "INCOMPATIBLE KEY PATTERN (should be a string or a symbol)")
  end
end