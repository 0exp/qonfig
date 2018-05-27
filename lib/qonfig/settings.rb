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

      @__definition_lock__ = Mutex.new
      @__access_lock__ = Mutex.new
      @__merge_lock__ = Mutex.new
    end

    # @param key [Symbol, String]
    # @param value [Object]
    # @raise [Qonfig::ArgumentError]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def __define_setting__(key, value)
      __thread_safe_definition__ do
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
    end

    # @param settings [Qonfig::Settings]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def __append_settings__(settings)
      __thread_safe_merge__ do
        settings.__options__.each_pair do |key, value|
          __define_setting__(key, value)
        end
      end
    end

    # @param key [Symbol, String]
    # @raise [Qonfig::UnknownSettingError]
    # @return [Object]
    #
    # @api public
    # @since 0.1.0
    def [](key)
      __thread_safe_access__ do
        unless __options__.key?(key)
          raise Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!"
        end

        __options__[key]
      end
    end

    # @param key [String, Symbol]
    # @param value [Object]
    # @raise [Qonfig::UnknownSettingError]
    # @raise [Qonfig::FrozenSettingsError]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def []=(key, value)
      __thread_safe_access__ do
        unless __options__.key?(key)
          raise Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!"
        end

        if __options__.frozen?
          raise Qonfig::FrozenSettingsError, 'Can not modify frozen settings'
        end

        __options__[key] = value
      end
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def __to_hash__
      __thread_safe_access__ { __build_hash_representation__ }
    end

    # @param method_name [String, Symbol]
    # @param arguments [Array<Object>]
    # @param block [Proc]
    # @raise [Qonfig::UnknownSettingError]
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
      __thread_safe_access__ do
        __options__.freeze

        __options__.each_value do |value|
          value.__freeze__ if value.is_a?(Qonfig::Settings)
        end
      end
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.2.0
    def __is_frozen__
      __thread_safe_access__ { __options__.frozen? }
    end

    private

    # @param options_part [Hash]
    # @return [Hash]
    #
    # @api private
    # @since 0.2.0
    def __build_hash_representation__(options_part = __options__)
      options_part.each_with_object({}) do |(key, value), hash|
        case
        when value.is_a?(Hash)
          hash[key] = __build_hash_representation__(value)
        when value.is_a?(Qonfig::Settings)
          hash[key] = value.__to_hash__
        else
          hash[key] = value
        end
      end
    end

    # @param key [Symbol, String]
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

    # @param __instructions__ [Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def __thread_safe_definition__(&__instructions__)
      @__definition_lock__.synchronize(&__instructions__)
    end

    # @param __instructions__ [Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def __thread_safe_access__(&__instructions__)
      @__access_lock__.synchronize(&__instructions__)
    end

    # @param __instructions__ [Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def __thread_safe_merge__(&__instructions__)
      @__merge_lock__.synchronize(&__instructions__)
    end
  end
end
