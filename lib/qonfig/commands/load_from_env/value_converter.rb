# frozen_string_literal: true

module Qonfig
  # @api private
  # @since 0.2.0
  module Commands::LoadFromENV::ValueConverter
    INTEGER_PATTERN = /\A\d+\z/
    FLOAT_PATTERN   = /\A\d+\.\d+\z/
    TRUE_PATTERN    = /\A(t|true)\z/i
    FALSE_PATTERN   = /\A(f|false)\z/i

    class << self
      # @param env_data [Hash]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def convert_values!(env_data)
        env_data.each_pair do |key, value|
          env_data[key] = convert_value(value)
        end
      end

      private

      # @param value [Object]
      # @return [Object]
      #
      # @api private
      # @since 0.2.0
      def convert_value(value)
        return value unless value.is_a?(String)

        case value
        when INTEGER_PATTERN then Integer(value)
        when FLOAT_PATTERN   then Float(value)
        when TRUE_PATTERN    then true
        when FALSE_PATTERN   then false
        else
          value
        end
      end
    end
  end
end
