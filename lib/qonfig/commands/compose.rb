# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.1.0
    class Compose < Base
      # @return [Qonfig::DataSet]
      #
      # @api private
      # @since 0.1.0
      attr_reader :data_set_klass

      # @param data_set_klass [Qonfig::DataSet]
      #
      # @api private
      # @since 0.1.0
      def initialize(data_set_klass)
        unless data_set_klass.is_a?(Class) && data_set_klass < Qonfig::DataSet
          raise(
            Qonfig::ArgumentError,
            'Composed config class should be a subtype of Qonfig::DataSet'
          )
        end

        @data_set_klass = data_set_klass
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def call(settings)
        composite_settings = data_set_klass.new.settings

        settings.__append_settings__(composite_settings)
      end
    end
  end
end
