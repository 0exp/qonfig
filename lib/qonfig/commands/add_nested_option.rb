# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.1.0
    class AddNestedOption < Base
      # @return [Symbol, String]
      #
      # @api private
      # @since 0.1.0
      attr_reader :key

      # @return [Proc]
      #
      # @api private
      # @since 0.1.0
      attr_reader :nested_definitions

      # @param key [Symbol, String]
      # @param nested_definitions [Proc]
      #
      # @raise [Qonfig::ArgumentError]
      # @raise [Qonfig::CoreMethodIntersectionError]
      #
      # @api private
      # @since 0.1.0
      def initialize(key, nested_definitions)
        raise(
          Qonfig::ArgumentError,
          'Setting key should be a symbol or a string!'
        ) unless key.is_a?(Symbol) || key.is_a?(String)

        raise(
          Qonfig::CoreMethodIntersectionError,
          "<#{key}> key can not be used since this is a private core method"
        ) if Qonfig::Settings.intersects_core_method?(key)

        @key = key
        @nested_definitions = nested_definitions

        @nested_data_set_klass = Class.new(Qonfig::DataSet).tap do |data_set|
          data_set.instance_eval(&nested_definitions)
        end
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def call(settings)
        nested_data_set = Class.new(Qonfig::DataSet).tap do |data_set|
          data_set.instance_eval(&nested_definitions)
        end

        nested_settings = nested_data_set.new.settings

        settings.__define_setting__(key, nested_settings)
      end
    end
  end
end
