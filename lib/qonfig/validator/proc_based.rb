# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::ProcBased < Qonfig::Validator::Basic
  # @return [Proc]
  #
  # @api private
  # @since 0.13.0
  attr_reader :validation

  # @param setting_key_matcher [Qonfig::Settings::KeyMatcher, NilClass]
  # @param vaidation [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(setting_key_matcher, validation)
    super(setting_key_matcher)
    @validation = validation
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @raise [Qonfig::ValidationError]
  #
  # @api private
  # @since 0.13.0
  def validate_concrete(data_set)
    data_set.settings.__deep_each_setting__ do |setting_key, setting_value|
      next unless setting_key_matcher.match?(setting_key)

      raise(
        Qonfig::ValidationError,
        "Invalid value of setting <#{setting_key}> (#{setting_value})"
      ) unless data_set.instance_exec(setting_value, &validation)
    end
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @raise [Qonfig::ValidationError]
  #
  # @api private
  # @since 0.13.0
  def validate_full(data_set)
    unless data_set.instance_eval(&validation)
      raise(Qonfig::ValidationError, 'Invalid config object')
    end
  end
end
