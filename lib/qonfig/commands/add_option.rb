# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.1.0
    class AddOption < Base
      # @return [Symbol, String]
      #
      # @api private
      # @since 0.1.0
      attr_reader :key

      # @return [Object]
      #
      # @api private
      # @since 0.1.0
      attr_reader :value

      # @param key [Symbol, String]
      # @param value [Object]
      #
      # @api private
      # @since 0.1.0
      def initialize(key, value)
        unless key.is_a?(Symbol) || key.is_a?(String)
          raise Qonfig::ArgumentError, 'Setting key should be a symbol or a string!'
        end

        @key   = key
        @value = value
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def call(settings)
        settings.__define_setting__(key, value)
      end
    end
  end
end
