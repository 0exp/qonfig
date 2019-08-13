# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::Basic
  # @return [String, Symbol, NilClass]
  #
  # @api private
  # @since 0.13.0
  attr_reader :setting_key_matcher

  # @param setting_key_matcher [Qonfig::Settings::KeyMatcher, NilClass]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(setting_key_matcher)
    @setting_key_matcher = setting_key_matcher
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def validate(data_set)
    setting_key_provided? ? validate_concrete(data_set) : validate_full(data_set)
  end

  private

  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def setting_key_provided?
    !setting_key_matcher.nil?
  end

  # @param data_set [Qonfig::DataSet]
  # @return [Any]
  #
  # @api private
  # @since 0.13.0
  def validate_full(data_set); end

  # @param data_set [Qonfig::DataSet]
  # @return [Any]
  #
  # @api private
  # @since 0.13.0
  def validate_concrete(data_set); end
end
