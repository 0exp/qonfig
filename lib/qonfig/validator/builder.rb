# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::Builder
  require_relative 'builder/attribute_consistency'

  # @return [NilClass]
  #
  # @api private
  # @since 0.13.0
  EMPTY_SETTING_KEY_PATTERN = nil

  # @return [NilClass]
  #
  # @api private
  # @since 0.13.0
  NO_RUNTIME_VALIDATION_METHOD = nil

  # @return [NilClass]
  #
  # @api private
  # @since 0.13.0
  NO_VALIDATION_LOGIC = nil

  # @return [NilClass]
  #
  # @api private
  # @since 0.13.0
  NO_PREDEFINED_VALIDATOR = nil

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  DEFAULT_STRICT_BEHAVIOUR = false

  class << self
    # @option setting_key_pattern [String, Symbol, NilClass]
    # @option predefined_validator [String, Symbol, NilClass]
    # @option runtime_validation_method [String, Symbol, NilClass]
    # @option validation_logic [Proc, NilClass]
    # @option strict [Boolean]
    # @return [Qonfig::Validator::MethodBased, Qonfig::Validator::ProcBased]
    #
    # @api private
    # @since 0.13.0
    def build(
      setting_key_pattern: EMPTY_SETTING_KEY_PATTERN,
      runtime_validation_method: NO_RUNTIME_VALIDATION_METHOD,
      validation_logic: NO_VALIDATION_LOGIC,
      strict: DEFAULT_STRICT_BEHAVIOUR,
      predefined_validator: NO_PREDEFINED_VALIDATOR
    )
      new(
        setting_key_pattern,
        predefined_validator,
        runtime_validation_method,
        strict,
        validation_logic
      ).build
    end
  end

  # @param setting_key_pattern [String, Symbol, NilClass]
  # @param predefined_validator_name [String, Symbol, NilClass]
  # @param runtime_validation_method [String, Symbol, NilClass]
  # @param strict [Boolean]
  # @param validation_logic [Proc, NilClass]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(
    setting_key_pattern,
    predefined_validator_name,
    runtime_validation_method,
    strict,
    validation_logic
  )
    @setting_key_pattern = setting_key_pattern
    @predefined_validator_name = predefined_validator_name
    @runtime_validation_method = runtime_validation_method
    @strict = strict
    @validation_logic = validation_logic
  end

  # @return [Qonfig::Validator::MethodBased, Qonfig::Validator::ProcBased]
  #
  # @api private
  # @since 0.13.0
  def build
    validate_attributes!
    build_validator
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
  attr_reader :predefined_validator_name

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
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.13.0
  def validate_attributes!
    AttributeConsistency.check!(
      setting_key_pattern,
      predefined_validator_name,
      runtime_validation_method,
      strict,
      validation_logic
    )
  end

  # @return [Qonfig::Validator::MethodBased, Qonfig::Validator::PorcBased]
  #
  # @api private
  # @since 0.13.0
  def build_validator
    case
    when predefined_validator_name then build_predefined_validator
    when runtime_validation_method then build_method_based_validator
    when validation_logic          then build_proc_based_validator
    end
  end

  # @return [Qonfig::Settings::KeyMatcher, NilClass]
  #
  # @api private
  # @since 0.13.0
  def build_setting_key_matcher
    Qonfig::Settings::KeyMatcher.new(setting_key_pattern.to_s) if setting_key_pattern
  end

  # @return [Qonfig::Validator::MethodBased]
  #
  # @api private
  # @since 0.13.0
  def build_method_based_validator
    Qonfig::Validator::MethodBased.new(
      build_setting_key_matcher, strict, runtime_validation_method
    )
  end

  # @return [Qonfig::Validator::ProcBased]
  #
  # @api private
  # @since 0.13.0
  def build_proc_based_validator
    Qonfig::Validator::ProcBased.new(
      build_setting_key_matcher, strict, validation_logic
    )
  end

  # @return [Qonfig::Settings::Predefined]
  #
  # @api private
  # @since 0.13.0
  def build_predefined_validator
    Qonfig::Validator::Predefined.build(
      predefined_validator_name, build_setting_key_matcher, strict
    )
  end
end
