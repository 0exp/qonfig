# frozen_string_literal: true

module Qonfig
  # @api private
  # @since 0.2.0
  module Commands::LoadFromENV::ValueConverter
    # @return [Regexp]
    #
    # @api private
    # @since 0.2.0
    INTEGER_PATTERN = /\A\d+\z/

    # @return [Regexp]
    #
    # @api private
    # @since 0.2.0
    FLOAT_PATTERN = /\A\d+\.\d+\z/

    # @return [Regexp]
    #
    # @api private
    # @since 0.2.0
    TRUE_PATTERN = /\A(t|true)\z/i

    # @return [Regexp]
    #
    # @api private
    # @since 0.2.0
    FALSE_PATTERN = /\A(f|false)\z/i

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
