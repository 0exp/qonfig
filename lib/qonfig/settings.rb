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
      @__lock__ = Lock.new
    end

    # @param key [Symbol, String]
    # @param value [Object]
    # @raise [Qonfig::ArgumentError]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def __define_setting__(key, value)
      __lock__.thread_safe_definition do
        key = __indifferently_accessable_option_key__(key)

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
      __lock__.thread_safe_merge do
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
      __lock__.thread_safe_access do
        key = __indifferently_accessable_option_key__(key)

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
      __lock__.thread_safe_access do
        key = __indifferently_accessable_option_key__(key)

        unless __options__.key?(key)
          raise Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!"
        end

        if __options__.frozen?
          raise Qonfig::FrozenSettingsError, 'Can not modify frozen settings'
        end

        if __options__[key].is_a?(Qonfig::Settings)
          raise Qonfig::AmbiguousSettingValueError, 'Can not redefine option with nested options'
        end

        __options__[key] = value
      end
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def __to_hash__
      __lock__.thread_safe_access { __build_hash_representation__ }
    end
    alias_method :__to_h__, :__to_hash__

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
      __lock__.thread_safe_access do
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
      __lock__.thread_safe_access { __options__.frozen? }
    end

    private

    # @return [Qonfig::Settings::Lock]
    #
    # @api private
    # @since 0.2.0
    attr_reader :__lock__

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
      define_singleton_method(key) do
        self.[](key)
      end

      define_singleton_method("#{key}=") do |value|
        self.[]=(key, value)
      end
    end

    # @param key [Symbol, String]
    # @return [String]
    #
    # @api private
    # @since 0.2.0
    def __indifferently_accessable_option_key__(key)
      # :nocov:
      unless key.is_a?(Symbol) || key.is_a?(String)
        raise Qonfig::ArgumentError, 'Setting key should be a symbol or a string'
      end
      # :nocov:

      key.to_s
    end
  end
end
