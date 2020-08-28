# frozen_string_literal: true

require 'set'
require 'yaml'
require 'json'
require 'erb'
require 'pathname'

# @api public
# @since 0.1.0
module Qonfig
  require_relative 'qonfig/errors'
  require_relative 'qonfig/loaders'
  require_relative 'qonfig/uploaders'
  require_relative 'qonfig/commands'
  require_relative 'qonfig/command_set'
  require_relative 'qonfig/validation'
  require_relative 'qonfig/settings'
  require_relative 'qonfig/dsl'
  require_relative 'qonfig/data_set'
  require_relative 'qonfig/configurable'
  require_relative 'qonfig/imports'
  require_relative 'qonfig/plugins'
  require_relative 'qonfig/compacted'

  # @api public
  # @since 0.4.0
  extend Plugins::AccessMixin

  # @api public
  # @since 0.20.0
  extend Validation::PredefinitionMixin

  # @since 0.20.0
  define_validator(:integer) { |value| value.is_a?(Integer) }
  # @since 0.20.0
  define_validator(:float) { |value| value.is_a?(Float) }
  # @since 0.20.0
  define_validator(:numeric) { |value| value.is_a?(Numeric) }
  # @since 0.20.0
  define_validator(:string) { |value| value.is_a?(String) }
  # @since 0.20.0
  define_validator(:symbol) { |value| value.is_a?(Symbol) }
  # @since 0.20.0
  define_validator(:text) { |value| value.is_a?(Symbol) || value.is_a?(String) }
  # @since 0.20.0
  define_validator(:array) { |value| value.is_a?(Array) }
  # @since 0.20.0
  define_validator(:hash) { |value| value.is_a?(Hash) }
  # @since 0.20.0
  define_validator(:big_decimal) { |value| value.is_a?(BigDecimal) }
  # @since 0.20.0
  define_validator(:boolean) { |value| value.is_a?(TrueClass) || value.is_a?(FalseClass) }
  # @since 0.20.0
  define_validator(:proc) { |value| value.is_a?(Proc) }
  # @since 0.20.0
  define_validator(:class) { |value| value.is_a?(Class) }
  # @since 0.20.0
  define_validator(:module) { |value| value.is_a?(Module) }
  # @since 0.20.0
  define_validator(:not_nil) { |value| !value.nil? }

  # @since 0.12.0
  register_plugin('toml', Qonfig::Plugins::TOML)
  # @since 0.19.0
  register_plugin('pretty_print', Qonfig::Plugins::PrettyPrint)
  # @since 0.21.0
  register_plugin('vault', Qonfig::Plugins::Vault)
end
