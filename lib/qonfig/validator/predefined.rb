# frozen_string_literal: true

# @api private
# @since 0.13.0
module Qonfig::Validator::Predefined
  require_relative 'predefined/common'
  require_relative 'predefined/registry'
  require_relative 'predefined/registry_control_mixin'

  # @since 0.13.0
  extend Qonfig::Validator::Predefined::RegistryControlMixin

  # @since 0.13.0
  predefine(:integer) { |value| value.is_a?(Integer) }
  # @since 0.13.0
  predefine(:float) { |value| value.is_a?(Float) }
  # @since 0.13.0
  predefine(:numeric) { |value| value.is_a?(Numeric) }
  # @since 0.13.0
  predefine(:string) { |value| value.is_a?(String) }
  # @since 0.13.0
  predefine(:symbol) { |value| value.is_a?(Symbol) }
  # @since 0.13.0
  predefine(:text) { |value| value.is_a?(Symbol) || value.is_a?(String) }
  # @since 0.13.0
  predefine(:array) { |value| value.is_a?(Array) }
  # @since 0.13.0
  predefine(:hash) { |value| value.is_a?(Hash) }
  # @since 0.13.0
  predefine(:big_decimal) { |value| value.is_a?(BigDecimal) }
  # @since 0.13.0
  predefine(:boolean) { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }
  # @since 0.13.0
  predefine(:proc) { |value| value.is_a?(Proc) }
  # @since 0.13.0
  predefine(:class) { |value| value.is_a?(Class) }
  # @since 0.13.0
  predefine(:module) { |value| value.is_a?(Module) }
  # @since 0.13.0
  predefine(:not_nil) { |value| !value.nil? }
end
