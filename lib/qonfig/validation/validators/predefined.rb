# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Validators::Predefined < Qonfig::Validation::Validators::Basic
  # @return [Proc]
  #
  # @api private
  # @since 0.20.0
  attr_reader :validation

  # @param setting_key_matcher [Qonfig::Settings::KeyMatcher]
  # @param strict [Boolean]
  # @param validation [Proc]
  # @param error_message [NilClass, String, Proc]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize(setting_key_matcher, strict, validation, error_message = nil)
    super(setting_key_matcher, strict, error_message)
    @validation = validation
  end

  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @raise [Qonfig::ValidationError]
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
      ) unless validation.call(setting_value)
    end
  end

  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @raise [Qonfig::ValidationError]
  #
  # @api private
  # @since 0.20.0
  def validate_full(data_set)
    # :nocov:
    raise Qonfig::Error, 'Predefined validator can be used with a setting key only'
    # :nocov:
  end

  # @param context [Object, NilClass]
  # @return [String]
  #
  # @api private
  # @since 0.26.0
  def default_error_message(context = nil)
    "Invalid value of setting <#{context[:setting_key]}> (#{context[:setting_value]})"
  end
end
