# frozen_string_literal: true

# @api public
# @since 0.4.0
module Qonfig::Plugins
  require_relative 'plugins/registry'
  require_relative 'plugins/access_mixin'
  require_relative 'plugins/abstract'
  require_relative 'plugins/toml_format'

  # @since 0.4.0
  @plugin_registry = Registry.new
  # @since 0.4.0
  @access_lock = Mutex.new

  class << self
    # @param plugin_name [Symbol, String]
    # @return [void]
    #
    # @api public
    # @since 0.4.0
    def load(plugin_name)
      thread_safe { plugin_registry[plugin_name].load! }
    end

    # @return [Array<String>]
    #
    # @api public
    # @since 0.4.0
    def names
      thread_safe { plugin_registry.names }
    end

    # @param plugin_name [Symbol, String]
    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def register_plugin(plugin_name, plugin_module)
      thread_safe { plugin_registry[plugin_name] = plugin_module }
    end

    private

    # @return [Qonfig::Plugins::Registry]
    #
    # @api private
    # @since 0.4.0
    attr_reader :plugin_registry

    # @return [Mutex]
    #
    # @api private
    # @since 0.4.0
    attr_reader :access_lock

    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def thread_safe
      access_lock.synchronize { yield if block_given? }
    end
  end
end
