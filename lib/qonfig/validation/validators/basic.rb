# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Validators::Basic
  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.20.0
  attr_reader :setting_key_matcher

  # @return [Boolean]
  #
  # @api private
  # @since 0.20.0
  attr_reader :strict

  # @return [NilClass, String, Proc]
  #
  # @api private
  # @since 0.20.0
  attr_reader :error_message

  # @param setting_key_matcher [Qonfig::Settings::KeyMatcher, NilClass]
  # @param strict [Boolean]
  # @param error_message [NilClass, String, Proc]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize(setting_key_matcher, strict, error_message = nil)
    @setting_key_matcher = setting_key_matcher
    @strict = strict
    @error_message = error_message
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.20.0
  def validate(data_set)
    setting_key_provided? ? validate_concrete(data_set) : validate_full(data_set)
  end

  private

  # @return [Boolean]
  #
  # @api private
  # @since 0.20.0
  def setting_key_provided?
    !setting_key_matcher.nil?
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Any]
  #
  # @api private
  # @since 0.20.0
  def validate_full(data_set); end

  # @param data_set [Qonfig::DataSet]
  # @return [Any]
  #
  # @api private
  # @since 0.20.0
  def validate_concrete(data_set); end

  # @param context [Object, NilClass]
  # @return [String]
  #
  # @api private
  # @since 0.26.0
  def default_error_message(context); end

  # @param context [Object, NilClass]
  # @return [String]
  #
  # @api private
  # @since 0.26.0
  def build_error_message(context = nil)
    return error_message.to_s if error_message.is_a?(String)
    return error_message.call(context).to_s if error_message.respond_to?(:call)
    default_error_message(context)
  end
end
