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
      # @sicne 0.2.0
      def initialize(caller_location)
        @caller_location = caller_location
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
        caller_file = caller_location.split(':').first
        data_match = IO.read(caller_file).match(/\n__END__\n(?<end_data>.*)/m)
        raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless data_match
        file_data = data_match[:end_data]
        raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless file_data
        yaml_data = Psych.load(file_data)
        unless yaml_data.is_a?(Hash)
          raise Qonfig::IncompatibleYAMLError, 'YAML data should have a hash-like structure'
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
