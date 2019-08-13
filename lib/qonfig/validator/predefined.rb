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
  register(:integer) { |value| value.is_a?(Integer) }
  # @since 0.13.0
  register(:float) { |value| value.is_a?(Float) }
  # @since 0.13.0
  register(:numeric) { |value| value.is_a?(Numeric) }
  # @since 0.13.0
  register(:string) { |value| value.is_a?(String) }
  # @since 0.13.0
  register(:symbol) { |value| value.is_a?(Symbol) }
  # @since 0.13.0
  register(:array) { |value| value.is_a?(Array) }
  # @since 0.13.0
  register(:hash) { |value| value.is_a?(Hash) }
  # @since 0.13.0
  register(:big_decimal) { |value| value.is_a?(BigDecimal) }
  # @since 0.13.0
  register(:boolean) { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }
end
