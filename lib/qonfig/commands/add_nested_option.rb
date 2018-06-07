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

      # @return [Class<Qonfig::DataSet>]
      #
      # @api private
      # @since 0.2.0
      attr_reader :nested_data_set_klass

      # @param key [Symbol, String]
      # @param nested_definitions [Proc]
      #
      # @raise [Qonfig::ArgumentError]
      # @raise [Qonfig::CoreMethodIntersectionError]
      #
      # @api private
      # @since 0.1.0
      def initialize(key, nested_definitions)
        Qonfig::Settings::KeyGuard.prevent_incomparabilities!(key)

        @key = key
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
        nested_settings = nested_data_set_klass.new.settings

        settings.__define_setting__(key, nested_settings)
      end
    end
  end
end
