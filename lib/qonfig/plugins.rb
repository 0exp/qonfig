# frozen_string_literal: true

module Qonfig
  # @api public
  # @since 0.4.0
  module Plugins
    @plugin_registry = Registry.new
    @access_lock = Mutex.new

    class << self
      # @param plugin_name [Symbol, String]
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
      def plugins
        thread_safe { plugin_registry.names }
      end

      # @param plugin_name [Symbol, String]
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

      # @api private
      # @since 0.4.0
      def thread_safe
        access_lock.synchronize { yield if block_given? }
      end
    end
  end
end
