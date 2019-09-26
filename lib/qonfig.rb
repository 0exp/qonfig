# frozen_string_literal: true

require 'yaml'
require 'json'
require 'erb'

module Qonfig
  require_relative 'qonfig/errors'
  require_relative 'qonfig/loaders'
  require_relative 'qonfig/uploaders'
  require_relative 'qonfig/commands'
  require_relative 'qonfig/command_set'
  require_relative 'qonfig/validator'
  require_relative 'qonfig/settings'
  require_relative 'qonfig/dsl'
  require_relative 'qonfig/data_set'
  require_relative 'qonfig/configurable'
  require_relative 'qonfig/plugins'

  # @api public
  # @since 0.4.0
  extend Plugins::AccessMixin

  # @since 0.12.0
  register_plugin('toml', Qonfig::Plugins::TOML)
  # @since 0.17.0
  register_plugin('pretty_print', Qonfig::Plugins::PrettyPrint)
end
