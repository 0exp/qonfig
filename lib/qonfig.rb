# frozen_string_literal: true

require 'yaml'
require 'json'
require 'erb'

module Qonfig
  require_relative 'qonfig/error'
  require_relative 'qonfig/loaders'
  require_relative 'qonfig/commands'
  require_relative 'qonfig/command_set'
  require_relative 'qonfig/settings'
  require_relative 'qonfig/dsl'
  require_relative 'qonfig/data_set'
  require_relative 'qonfig/configurable'
  require_relative 'qonfig/plugins'

  # @api public
  # @since 0.4.0
  extend Plugins::AccessMixin
end
