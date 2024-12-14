# frozen_string_literal: true

# @api private
# @since 0.2.0
# rubocop:disable Performance/MethodObjectAsBlock
module Qonfig::Commands::Definition::LoadFromENV::ValueConverter
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

  # @return [Regexp]
  #
  # @api private
  # @since 0.2.0
  ARRAY_PATTERN = /\A[^'"].*\s*,\s*.*[^'"]\z/

  # @return [Regexp]
  #
  # @api private
  # @since 0.2.0
  QUOTED_STRING_PATTERN = /\A['"].*['"]\z/

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
      when INTEGER_PATTERN
        Integer(value)
      when FLOAT_PATTERN
        Float(value)
      when TRUE_PATTERN
        true
      when FALSE_PATTERN
        false
      when ARRAY_PATTERN
        value.split(/\s*,\s*/).map(&method(:convert_value))
      when QUOTED_STRING_PATTERN
        value.gsub(/(\A['"]|['"]\z)/, '')
      else
        value
      end
    end
  end
end
# rubocop:enable Performance/MethodObjectAsBlock
