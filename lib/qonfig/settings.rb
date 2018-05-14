# frozen_string_literal: true

module Qonfig
  # @api private
  # @since 0.1.0
  class Settings
    # @return [Hash]
    #
    # @api private
    # @since 0.1.0
    attr_reader :__options__

    # @api private
    # @since 0.1.0
    def initialize
      @__options__ = {}
    end

    # @param key [Symbol,String]
    # @param value [Object]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def __define_setting__(key, value)
      unless key.is_a?(Symbol) || key.is_a?(String)
        raise Qonfig::ArgumentError, 'Setting key should be a symbol or a string'
      end

      case
      when !__options__.key?(key)
        __options__[key] = value
      when __options__[key].is_a?(Qonfig::Settings) && value.is_a?(Qonfig::Settings)
        __options__[key].__append_settings__(value)
      else
        __options__[key] = value
      end

      __define_accessor__(key)
    end

    # @param settings [Qonfig::Settings]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def __append_settings__(settings)
      settings.__options__.each_pair do |key, value|
        __define_setting__(key, value)
      end
    end

    # @param key [Symbol,String]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def [](key)
      unless __options_.key?(key)
        raise Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!"
      end

      __options__[key]
    end

    def __to_hash__
      __options__.dup.tap do |hash|
        __options__.each_pair do |key, value|
          hash[key] = value.is_a?(Qonfig::Settings) ? value.__to_hash__ : value
        end
      end
    end

    private

    # @param key [Symbol,String]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def __define_accessor__(key)
      singleton_class.send(:undef_method, key)       rescue NameError
      singleton_class.send(:undef_method, "#{key}=") rescue NameError

      define_singleton_method(key) { __options__[key] }
      define_singleton_method("#{key}=") do |value|
        __options__[key] = value
      end unless __options__[key].is_a?(Qonfig::Settings)
    end
  end
end
