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

    # @param key [String, Symbol]
    # @param value [Object]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def []=(key, value)
      unless __options__.key?(key)
        raise Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!"
      end

      if __options__.frozen?
        raise Qonfig::FrozenSettingsError, 'Can not modify frozen Settings'
      end

      __options__[key] = value
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
      raise Qonfig::UnknownSettingError, "Setting with <#{method_name}> key doesnt exist!"
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

    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def __freeze__
      __options__.freeze

      __options__.each_value do |value|
        value.__freeze__ if value.is_a?(Qonfig::Settings)
      end
    end

    private

    # @param key [Symbol,String]
    # @return [void]
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

      define_singleton_method(key) { self.[](key) }
      define_singleton_method("#{key}=") do |value|
        self.[]=(key, value)
      end unless __options__[key].is_a?(Qonfig::Settings)
    end
  end
end
