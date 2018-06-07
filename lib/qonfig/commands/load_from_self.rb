# frozen_string_literal: true

module Qonfig
  module Commands
    # @api private
    # @since 0.2.0
    class LoadFromSelf < Base
      # @return [String]
      #
      # @api private
      # @since 0.2.0
      attr_reader :caller_location

      # @param caller_location [String]
      #
      # @api private
      # @since 0.2.0
      def initialize(caller_location)
        @caller_location = caller_location
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
        yaml_data = load_self_placed_yaml_data

        yaml_based_settings = build_data_set_klass(yaml_data).new.settings

        settings.__append_settings__(yaml_based_settings)
      end

      private

      # @return [Hash]
      #
      # @raise [Qonfig::SelfDataNotFound]
      # @raise [Qonfig::IncompatibleYAMLStructureError]
      #
      # @api private
      # @since 0.2.0
      def load_self_placed_yaml_data
        caller_file = caller_location.split(':').first

        raise(
          Qonfig::SelfDataNotFoundError,
          "Caller file does not exist! (location: #{caller_location})"
        ) unless File.exist?(caller_file)

        data_match = IO.read(caller_file).match(/\n__END__\n(?<end_data>.*)/m)
        raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless data_match

        end_data = data_match[:end_data]
        raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless end_data

        yaml_data = Qonfig::Loaders::YAML.load(end_data)
        raise(
          Qonfig::IncompatibleYAMLStructureError,
          'YAML content should have a hash-like structure'
        ) unless yaml_data.is_a?(Hash)

        yaml_data
      end

      # @param self_placed_yaml_data [Hash]
      # @return [Class<Qonfig::DataSet>]
      #
      # @api private
      # @since 0.2.0
      def build_data_set_klass(self_placed_yaml_data)
        Qonfig::DataSet::ClassBuilder.build_from_hash(self_placed_yaml_data)
      end
    end
  end
end
