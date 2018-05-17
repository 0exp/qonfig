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
      # :nocov:
      unless key.is_a?(Symbol) || key.is_a?(String)
        raise Qonfig::ArgumentError, 'Setting key should be a symbol or a string'
      end
      # :nocov:

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
    # @api public
    # @since 0.1.0
    def [](key)
      unless __options__.key?(key)
        raise Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!"
      end

      __options__[key]
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def __to_hash__
      __options__.dup.tap do |hash|
        __options__.each_pair do |key, value|
          hash[key] = value.is_a?(Qonfig::Settings) ? value.__to_hash__ : value
        end
      end
    end

    # @param method_name [String, Symbol]
    # @param arguments [Array<Object>]
    # @param block [Proc]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def method_missing(method_name, *arguments, &block)
      super
    rescue NoMethodError
      raise Qonfig::UnknownSettingError, "Setting with <#{method_name}> ley doesnt exist!"
    end

    # @return [Boolean]
    #
    # @api public
    # @since 0.1.0
    def respond_to_missing?(method_name, include_private = false)
      # :nocov:
      __options__.key?(method_name.to_s) || __options__.key?(method_name.to_sym) || super
      # :nocov:
    end

    private

    # @param key [Symbol,String]
    # @return [Object]
    #
    # @api private
    # @since 0.1.0
    def __define_accessor__(key)
      begin
        singleton_class.send(:undef_method, key)
      rescue NameError
      end

      begin
        singleton_class.send(:undef_method, "#{key}=")
      rescue NameError
      end

      define_singleton_method(key) { __options__[key] }
      define_singleton_method("#{key}=") do |value|
        __options__[key] = value
      end unless __options__[key].is_a?(Qonfig::Settings)
    end
  end
end
