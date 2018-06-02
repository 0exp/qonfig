# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.2.0
    class LoadFromYAML < Base
      # @return [String]
      #
      # @api private
      # @since 0.2.0
      attr_reader :file_path

      # @param file_path [String]
      #
      # @api private
      # @since 0.2.0
      def initialize(file_path)
        @file_path = file_path
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @raise [Qonfig::IncompatibleYAMLError]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
        yaml_data = Qonfig::Loaders::YAML.load_file(file_path)

        unless yaml_data.is_a?(Hash)
          raise Qonfig::IncompatibleYAMLError, 'YAML file should have a hash-like structure'
        end

        yaml_based_settings = build_data_set_class(yaml_data).new.settings

        settings.__append_settings__(yaml_based_settings)
      end

      private

      # @param yaml_data [Hash]
      # @return [Class<Qonfig::DataSet>]
      #
      # @api private
      # @since 0.2.0
      def build_data_set_class(yaml_data)
        Qonfig::DataSet::ClassBuilder.build_from_hash(yaml_data)
      end
    end
  end
end
