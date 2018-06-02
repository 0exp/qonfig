# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.2.0
    class LoadFromENV < Base
      # @return [Boolean]
      #
      # @api private
      # @since 0.2.0
      attr_reader :convert_values

      # @return [Regexp]
      #
      # @api private
      # @since 0.2.0
      attr_reader :prefix_pattern

      # @option convert_values [Boolean]
      # @opion prefix [NilClass, String, Regexp]
      #
      # @api private
      # @since 0.2.0
      def initialize(convert_values: false, prefix: nil)
        unless convert_values.is_a?(FalseClass) || convert_values.is_a?(TrueClass)
          raise Qonfig::ArgumentError, ':convert_values option should be a boolean'
        end

        unless prefix.is_a?(NilClass) || prefix.is_a?(String) || prefix.is_a?(Regexp)
          raise Qonfig::ArgumentError, ':prefix option should be a nil / string / regexp'
        end

        @convert_values = convert_values
        @prefix_pattern = prefix.is_a?(Regexp) ? prefix : /\A#{Regexp.escape(prefix.to_s)}.*\z/m
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
        env_data = extract_env_data

        env_based_settings = build_data_set_class(env_data).new.settings

        settings.__append_settings__(env_based_settings)
      end

      private

      # @return [Hash]
      #
      # @api private
      # @since 0.2.0
      def extract_env_data
        ENV.each_with_object({}) do |(key, value), env_data|
          env_data[key] = value if key.match(prefix_pattern)
        end.tap do |env_data|
          ValueConverter.convert_values!(env_data) if convert_values
        end
      end

      # @param env_data [Hash]
      # @return [Class<Qonfig::DataSet>]
      #
      # @api private
      # @since 0.2.0
      def build_data_set_class(env_data)
        Qonfig::DataSet::ClassBuilder.build_from_hash(env_data)
      end
    end
  end
end
