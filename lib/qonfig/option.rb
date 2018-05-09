# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Option
  # @return [Symbol]
  #
  # @api private
  # @since 0.1.0
  attr_reader :key

  # @return [Object]
  #
  # @api private
  # @since 0.1.0
  attr_reader :value

  # @param key [Symbol] Option name
  # @param value [Object] Option value
  #
  # @api private
  # @since 0.1.0
  def initialize(key, value)
    @key   = key
    @value = value
  end
end
