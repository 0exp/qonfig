# frozen_string_literal: true

require 'yaml'
require 'json'
require 'erb'

module Qonfig
  require_relative 'qonfig/error'
  require_relative 'qonfig/loaders/basic'
  require_relative 'qonfig/loaders/json'
  require_relative 'qonfig/loaders/yaml'
  require_relative 'qonfig/commands/base'
  require_relative 'qonfig/commands/add_option'
  require_relative 'qonfig/commands/add_nested_option'
  require_relative 'qonfig/commands/compose'
  require_relative 'qonfig/commands/load_from_yaml'
  require_relative 'qonfig/commands/load_from_json'
  require_relative 'qonfig/commands/load_from_self'
  require_relative 'qonfig/commands/load_from_env'
  require_relative 'qonfig/commands/load_from_env/value_converter'
  require_relative 'qonfig/commands/expose_yaml'
  require_relative 'qonfig/command_set'
  require_relative 'qonfig/settings'
  require_relative 'qonfig/settings/lock'
  require_relative 'qonfig/settings/builder'
  require_relative 'qonfig/settings/key_guard'
  require_relative 'qonfig/dsl'
  require_relative 'qonfig/data_set'
  require_relative 'qonfig/data_set/class_builder'
  require_relative 'qonfig/configurable'
  require_relative 'qonfig/plugins/registry'
  require_relative 'qonfig/plugins'
  require_relative 'qonfig/plugins/access_mixin'
  require_relative 'qonfig/plugins/abstract'

  # @api public
  # @since 0.4.0
  extend Plugins::AccessMixin
end
