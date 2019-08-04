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

  class << self
    # @option setting_key_pattern [String, Symbol, NilClass]
    # @option runtime_validation_method [String, Symbol, NilClass]
    # @option validation_logic [Proc, NilClass]
    # @return [Qonfig::Validator::MethodBased, Qonfig::Validator::ProcBased]
    #
    # @api private
    # @since 0.13.0
    def build(
      setting_key_pattern: EMPTY_SETTING_KEY_PATTERN,
      runtime_validation_method: NO_RUNTIME_VALIDATION_METHOD,
      validation_logic: NO_VALIDATION_LOGIC
    )
      new(setting_key_pattern, runtime_validation_method, validation_logic).build
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
  def validate_attributes!
    AttributeConsistency.check!(
      setting_key_pattern,
      runtime_validation_method,
      validation_logic
    )
  end

  # @return [Qonfig::Validator::MethodBased, Qonfig::Validator::PorcBased]
  #
  # @api private
  # @since 0.13.0
  def build_validator
    case
    when runtime_validation_method then build_method_based
    when validation_logic          then build_proc_based
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
  def build_method_based
    Qonfig::Validator::MethodBased.new(build_setting_key_matcher, runtime_validation_method)
  end

  # @return [Qonfig::Validator::ProcBased]
  #
  # @api private
  # @since 0.13.0
  def build_proc_based
    Qonfig::Validator::ProcBased.new(build_setting_key_matcher, validation_logic)
  end
end
