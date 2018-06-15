# frozen_string_literal: true

module Qonfig
  module Plugins
    # @api private
    # @since 0.4.0
    class Registry
      # @return [void]
      #
      # @api private
      # @since 0.4.0
      def initialize
        @plugin_set = {}
        @access_lock = Mutex.new
      end

      # @param plugin_name [Symbol, String]
      # @return [Class, Module, Object]
      #
      # @api private
      # @since 0.4.0
      def [](plugin_name)
        thread_safe { fetch(plugin_name) }
      end

      # @param plugin_name [Symbol, String]
      # @param plugin_modle [Class, Module, Object]
      # @return [void]
      #
      # @api private
      # @since 0.4.0
      def register(plugin_name, plugin_module)
        thread_safe { apply(plugin_name, plugin_module) }
      end

      private

      # @return [Boolean]
      #
      # @api private
      # @since 0.4.0
      def key?
        plugin_set.key?(plugin_name)
      end

      # @param plugin_name [Symbol, String]
      # @param plugin_modle [Class, Module, Object]
      # @return [void]
      #
      # @api private
      # @since 0.4.0
      def apply(plugin_name, plugin_module)
        plugin_set[plugin_name] = plugin_module
      end

      # @param plugin_name [Symbol, String]
      # @return [Class, Module, Object]
      #
      # @raise [Qonfig::UnregisteredPluginError]
      #
      # @api private
      # @since 0.4.0
      def fetch(plugin_name)
        raise Qonfig::UnregisteredPluginError, '-' unless key?(plugin_name)
        plugin_set[plugin_name]
      end

      # @return [Hash]
      #
      # @api private
      # @since 0.4.0
      attr_reader :plugin_set

      # @return [Mutex]
      #
      # @api private
      # @since 0.4.0
      attr_reader :access_lock

      def thread_safe
        access_lock.synchronize { yield if block_given? }
      end
    end
  end
end
