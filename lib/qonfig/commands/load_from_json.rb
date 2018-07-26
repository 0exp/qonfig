# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.5.0
    class LoadFromJSON < Base
      # @return [String]
      #
      # @api private
      # @since 0.5.0
      attr_reader :file_path

      # @return [Boolean]
      #
      # @api private
      # @sicne 0.5.0
      attr_reader :strict

      # @param file_path [String]
      # @option strict [Boolean]
      #
      # @api private
      # @since 0.5.0
      def initialize(file_path, strict: true)
        @file_path = file_path
        @strict = strict
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def call(settings)
        json_data = Qonfig::Loaders::JSON.load_file(file_path, fail_on_unexist: strict)

        raise(
          Qonfig::IncompatibleJSONStructureError,
          'JSON object should have a hash-like structure'
        ) unless json_data.is_a?(Hash)

        json_based_settings = build_data_set_class(json_data).new.settings

        settings.__append_settings__(json_based_settings)
      end

      private

      # @param json_data [Hash]
      # @return [Class<Qonfig::DataSet>]
      #
      # @api private
      # @since 0.5.0
      def build_data_set_class(json_data)
        Qonfig::DataSet::ClassBuilder.build_from_hash(json_data)
      end
    end
  end
end
