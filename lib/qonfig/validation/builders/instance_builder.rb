# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Builders::InstanceBuilder
  # @return [NilClass]
  #
  # @api private
  # @since 0.20.0
  EMPTY_SETTING_KEY_PATTERN = nil

  # @return [NilClass]
  #
  # @api private
  # @since 0.20.0
  NO_RUNTIME_VALIDATION_METHOD = nil

  # @return [NilClass]
  #
  # @api private
  # @since 0.20.0
  NO_VALIDATION_LOGIC = nil

  # @return [NilClass]
  #
  # @api private
  # @since 0.20.0
  NO_PREDEFINED_VALIDATOR = nil

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  DEFAULT_STRICT_BEHAVIOUR = false

  class << self
    # @param data_set_klass [Class<Qonfig::DataSet>]
    # @option setting_key_pattern [String, Symbol, NilClass]
    # @option predefined_validator [String, Symbol, NilClass]
    # @option runtime_validation_method [String, Symbol, NilClass]
    # @option validation_logic [Proc, NilClass]
    # @option strict [Boolean]
    # @return [Qonfig::Validator::MethodBased, Qonfig::Validator::ProcBased]
    #
    # @api private
    # @since 0.20.0
    def build(
      data_set_klass,
      setting_key_pattern: EMPTY_SETTING_KEY_PATTERN,
      runtime_validation_method: NO_RUNTIME_VALIDATION_METHOD,
      validation_logic: NO_VALIDATION_LOGIC,
      strict: DEFAULT_STRICT_BEHAVIOUR,
      predefined_validator: NO_PREDEFINED_VALIDATOR
    )
      new(
        data_set_klass,
        setting_key_pattern,
        predefined_validator,
        runtime_validation_method,
        strict,
        validation_logic
      ).build
    end
  end

  # @param data_set_klass [Class<Qonfig::DataSet>]
  # @param setting_key_pattern [String, Symbol, NilClass]
  # @param predefined_validator_name [String, Symbol, NilClass]
  # @param runtime_validation_method [String, Symbol, NilClass]
  # @param strict [Boolean]
  # @param validation_logic [Proc, NilClass]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize(
    data_set_klass,
    setting_key_pattern,
    predefined_validator_name,
    runtime_validation_method,
    strict,
    validation_logic
  )
    @data_set_klass = data_set_klass
    @setting_key_pattern = setting_key_pattern
    @predefined_validator_name = predefined_validator_name
    @runtime_validation_method = runtime_validation_method
    @strict = strict
    @validation_logic = validation_logic
  end

  # @return [Qonfig::Validation::Validators::MethodBased]
  # @return [Qonfig::Validation::Validators::ProcBased]
  # @return [Qonfig::Validation::Validators::Predefined]
  #
  # @api private
  # @since 0.20.0
  def build
    validate_attributes!
    build_validator
  end

  private

  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.20.0
  attr_reader :data_set_klass

  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.20.0
  attr_reader :setting_key_pattern

  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.20.0
  attr_reader :predefined_validator_name

  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.20.0
  attr_reader :runtime_validation_method

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  attr_reader :strict

  # @return [Proc, NilClass]
  #
  # @api private
  # @since 0.20.0
  attr_reader :validation_logic

  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.20.0
  def validate_attributes!
    Qonfig::Validation::Builders::InstanceAttributesConsistency.check!(
      setting_key_pattern,
      predefined_validator_name,
      runtime_validation_method,
      strict,
      validation_logic
    )
  end

  # @return [Qonfig::Validation::Validators::MethodBased]
  # @return [Qonfig::Validation::Validators::ProcBased]
  # @return [Qonfig::Validation::Validators::Predefined]
  #
  # @api private
  # @since 0.20.0
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
  # @since 0.20.0
  def build_setting_key_matcher
    Qonfig::Settings::KeyMatcher.new(setting_key_pattern.to_s) if setting_key_pattern
  end

  # @return [Qonfig::Validation::Validators::MethodBased]
  #
  # @api private
  # @since 0.20.0
  def build_method_based_validator
    Qonfig::Validation::Validators::MethodBased.new(
      build_setting_key_matcher, strict, runtime_validation_method
    )
  end

  # @return [Qonfig::Validation::Validators::ProcBased]
  #
  # @api private
  # @since 0.20.0
  def build_proc_based_validator
    Qonfig::Validation::Validators::ProcBased.new(
      build_setting_key_matcher, strict, validation_logic
    )
  end

  # @return [Qonfig::Validation::Validators::Predefined]
  #
  # @see Qonfig::Validation::Collections::PredefinedRegistry
  #
  # @api private
  # @since 0.20.0
  def build_predefined_validator
    predefined_validation_logic =
      begin
        data_set_klass.predefined_validators.resolve(predefined_validator_name)
      rescue Qonfig::ValidatorNotFoundError
        Qonfig::DataSet.predefined_validators.resolve(predefined_validator_name)
      end

    Qonfig::Validation::Validators::Predefined.new(
      build_setting_key_matcher, strict, predefined_validation_logic
    )
  end
end
