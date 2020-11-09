# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Validators::MethodBased < Qonfig::Validation::Validators::Basic
  # @return [Symbol, String]
  #
  # @api private
  # @since 0.20.0
  attr_reader :runtime_validation_method

  # @param setting_key_matcher [Qonfig::Settings::KeyMatcher, NilClass]
  # @param strict [Boolean]
  # @param runtime_validation_method [String, Symbol]
  # @param error_message [NilClass, String, Proc]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize(setting_key_matcher, strict, runtime_validation_method, error_message = nil)
    super(setting_key_matcher, strict, error_message)
    @runtime_validation_method = runtime_validation_method
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.20.0
  def validate_concrete(data_set)
    data_set.settings.__deep_each_setting__ do |setting_key, setting_value|
      next unless setting_key_matcher.match?(setting_key)
      next if !strict && setting_value.nil?

      raise(
        Qonfig::ValidationError,
        build_error_message(setting_key: setting_key, setting_value: setting_value)
      ) unless data_set.__send__(runtime_validation_method, setting_value)
    end
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.20.0
  def validate_full(data_set)
    unless data_set.__send__(runtime_validation_method)
      raise(Qonfig::ValidationError, build_error_message)
    end
  end

  # @param context [Object, NilClass]
  # @return [String]
  #
  # @api private
  # @since 0.26.0
  def default_error_message(context = nil)
    return 'Invalid config object' if context.nil?
    "Invalid value of setting <#{context[:setting_key]}> (#{context[:setting_value]})"
  end
end
