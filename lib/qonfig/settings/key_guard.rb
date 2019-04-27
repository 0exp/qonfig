# frozen_string_literal: true

# @api private
# @since 0.2.0
class Qonfig::Settings::KeyGuard
  class << self
    # @param key [String, Symbol, Object]
    # @return [void]
    #
    # @raise [Qonfig::ArgumentError]
    # @raise [Qonfig::CoreMethodIntersectionError]
    #
    # @api private
    # @since 0.2.0
    def prevent_incomparabilities!(key)
      new(key).prevent_incomparabilities!
    end
  end

  # @return [String, Symbol, Object]
  #
  # @api private
  # @sicne 0.2.0
  attr_reader :key

  # @param key [String, Symbol, Object]
  #
  # @api private
  # @since 0.2.0
  def initialize(key)
    @key = key
  end

  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::CoreMethodIntersectionError]
  #
  # @api private
  # @since 0.2.0
  def prevent_incomparabilities!
    prevent_incompatible_key_type!
    prevent_core_method_intersection!
  end

  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.2.0
  def prevent_incompatible_key_type!
    raise(
      Qonfig::ArgumentError,
      'Setting key should be a symbol or a string!'
    ) unless key.is_a?(Symbol) || key.is_a?(String)
  end

  # @return [void]
  #
  # @raise [Qonfig::CoreMethodIntersectionError]
  #
  # @api private
  # @since 0.2.0
  def prevent_core_method_intersection!
    raise(
      Qonfig::CoreMethodIntersectionError,
      "<#{key}> key can not be used since this is a private core method"
    ) if Qonfig::Settings::CORE_METHODS.include?(key.to_s)
  end
end
