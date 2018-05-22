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
      # @raise [Qonfig::IncompatibleYAMLError]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
        yaml_data = Psych.load_file(file_path)

        unless yaml_data.is_a?(Hash)
          raise Qonfig::IncompatibleYAMLError, 'YAML file should have a hash-like structure'
        end

        yaml_based_settings = build_data_set_klass(yaml_data).new.settings
        settings.__append_settings__(yaml_based_settings)
      end

      private

      # @param [Hash]
      # @return [Class<Qonfig::DataSet>]
      #
      # @api private
      # @since 0.2.0
      def build_data_set_klass(hash)
        Class.new(Qonfig::DataSet).tap do |data_set_klass|
          hash.each_pair do |key, value|
            if value.is_a?(Hash)
              sub_data_set_klass = build_data_set_klass(hash[key])

              data_set_klass.setting(key) { compose sub_data_set_klass }
            else
              data_set_klass.setting key, value
            end
          end
        end
      end
    end
  end
end
