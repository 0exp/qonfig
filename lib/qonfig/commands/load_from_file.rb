# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.2.0
    class LoadFromFile < Base
      # @return [String]
      #
      # @api private
      # @since 0.2.0
      attr_reader :format

      # @return [String]
      #
      # @api private
      # @since 0.2.0
      attr_reader :file_path

      # @param file_path [String]
      #
      # @api private
      # @since 0.2.0
      def initialize(format, file_path)
        @format    = format
        @file_path = file_path
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
      end
    end
  end
end
