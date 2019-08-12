# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::MethodBased < Qonfig::Validator::Basic
  # @return [Symbol, String]
  #
  # @api private
  # @since 0.13.0
  attr_reader :runtime_validation_method

  # @param setting_key_matcher [Qonfig::Settings::KeyMatcher, NilClass]
  # @param runtime_validation_method [String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(setting_key_matcher, runtime_validation_method)
    super(setting_key_matcher)
    @runtime_validation_method = runtime_validation_method
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def validate_concrete(data_set)
    data_set.settings.__deep_each_setting__ do |setting_key, setting_value|
      next unless setting_key_matcher.match?(setting_key)

      raise(
        Qonfig::ValidationError,
        "Invalid value of setting <#{setting_key}> (#{setting_value})"
      ) unless data_set.__send__(runtime_validation_method, setting_value)
    end
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def validate_full(data_set)
    unless data_set.__send__(runtime_validation_method)
      raise(Qonfig::ValidationError, 'Invalid config object')
    end
  end
end
