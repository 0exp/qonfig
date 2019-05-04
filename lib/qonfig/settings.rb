# frozen_string_literal: true

# @api private
# @since 0.1.0
# rubocop:disable Metrics/ClassLength
class Qonfig::Settings
  require_relative 'settings/lock'
  require_relative 'settings/builder'
  require_relative 'settings/key_guard'

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
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def __define_setting__(key, value)
    __lock__.thread_safe_definition do
      key = __indifferently_accessable_option_key__(key)

      __prevent_core_method_intersection__(key)

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
  # @return [Object]
  #
  # @api public
  # @since 0.1.0
  def [](key)
    __lock__.thread_safe_access { __get_value__(key) }
  end

  # @param key [String, Symbol]
  # @param value [Object]
  # @return [void]
  #
  # @api public
  # @since 0.1.0
  def []=(key, value)
    __lock__.thread_safe_access { __set_value__(key, value) }
  end

  # @param options_map [Hash]
  # @return [void]
  #
  # @api private
  # @since 0.3.0
  def __apply_values__(options_map)
    __lock__.thread_safe_access { __set_values_from_map__(options_map) }
  end

  # @param keys [Array<String, Symbol>]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def __dig__(*keys)
    __lock__.thread_safe_access { __deep_access__(*keys) }
  end

  # @param keys [Array<String, Symbol>]
  # @return [Hash]
  #
  # @api private
  # @since 0.9.0
  def __slice__(*keys)
    __lock__.thread_safe_access { __deep_slice__(*keys) }
  end

  # @param keys [Array<String, Symbol>]
  # @return [Hash, Any]
  #
  # @api private
  # @since 0.10.0
  def __slice_value__(*keys)
    __lock__.thread_safe_access { __deep_slice_value__(*keys) }
  end

  # @param value_processor [Block]
  # @return [Hash]
  #
  # @api private
  # @since 0.1.0
  def __to_hash__(&value_processor)
    __lock__.thread_safe_access { __build_hash_representation__(&value_processor) }
  end
  alias_method :__to_h__, :__to_hash__

  # @return [void]
  #
  # @api private
  # @since 0.2.0
  def __clear__
    __lock__.thread_safe_access { __clear_option_values__ }
  end

  # @param method_name [String, Symbol]
  # @param arguments [Array<Object>]
  # @param block [Proc]
  # @return [void]
  #
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.1.0
  def method_missing(method_name, *arguments, &block)
    super
  rescue NoMethodError
    ::Kernel.raise(Qonfig::UnknownSettingError, "Setting with <#{method_name}> key doesnt exist!")
  end

  # @return [Boolean]
  #
  # @api private
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

  # @param options_map [Hash]
  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::AmbiguousSettingValueError]
  #
  # @api private
  # @since 0.3.0
  def __set_values_from_map__(options_map)
    ::Kernel.raise(
      Qonfig::ArgumentError, 'Options map should be represented as a hash'
    ) unless options_map.is_a?(Hash)

    options_map.each_pair do |key, value|
      current_value = __get_value__(key)

      # NOTE: some duplications here was made only for the better code readability
      case
      when !current_value.is_a?(Qonfig::Settings)
        __set_value__(key, value)
      when current_value.is_a?(Qonfig::Settings) && value.is_a?(Hash)
        current_value.__apply_values__(value)
      when current_value.is_a?(Qonfig::Settings) && !value.is_a?(Hash)
        ::Kernel.raise(
          Qonfig::AmbiguousSettingValueError,
          "Can not redefine option <#{key}> that contains nested options"
        )
      end
    end
  end

  # @return [void]
  #
  # @raise [Qonfig::FrozenSettingsError]
  #
  # @api private
  # @since 0.2.0
  def __clear_option_values__
    ::Kernel.raise(
      Qonfig::FrozenSettingsError, 'Can not modify frozen settings'
    ) if __options__.frozen?

    __options__.each_pair do |key, value|
      if value.is_a?(Qonfig::Settings)
        value.__clear__
      else
        __options__[key] = nil
      end
    end
  end

  # @param key [String, Symbol]
  # @return [Object]
  #
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.2.0
  def __get_value__(key)
    key = __indifferently_accessable_option_key__(key)

    unless __options__.key?(key)
      ::Kernel.raise(Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!")
    end

    __options__[key]
  end

  # @param key [String, Symbol]
  # @param value [Object]
  # @return [void]
  #
  # @raise [Qonfig::UnknownSettingError]
  # @raise [Qonfig::FrozenSettingsError]
  # @raise [Qonfig::AmbiguousSettingValueError]
  #
  # @api private
  # @since 0.2.0
  def __set_value__(key, value)
    key = __indifferently_accessable_option_key__(key)

    unless __options__.key?(key)
      ::Kernel.raise(Qonfig::UnknownSettingError, "Setting with <#{key}> key does not exist!")
    end

    if __options__.frozen?
      ::Kernel.raise(Qonfig::FrozenSettingsError, 'Can not modify frozen settings')
    end

    if __options__[key].is_a?(Qonfig::Settings)
      ::Kernel.raise(
        Qonfig::AmbiguousSettingValueError,
        "Can not redefine option <#{key}> that contains nested options"
      )
    end

    __options__[key] = value
  end

  # @param keys [Array<Symbol, String>]
  # @return [Object]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.2.0
  def __deep_access__(*keys)
    ::Kernel.raise(Qonfig::ArgumentError, 'Key list can not be empty') if keys.empty?

    result = __get_value__(keys.first)
    rest_keys = Array(keys[1..-1])

    case
    when rest_keys.empty?
      result
    when !result.is_a?(Qonfig::Settings)
      ::Kernel.raise(
        Qonfig::UnknownSettingError,
        'Setting with required digging sequence does not exist!'
      )
    when result.is_a?(Qonfig::Settings)
      result.__dig__(*rest_keys)
    end
  end

  # @param keys [Array<Symbol, String>]
  # @return [Hash]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.9.0
  def __deep_slice__(*keys)
    {}.tap do |result|
      __deep_access__(*keys).tap do |setting|
        required_key = __indifferently_accessable_option_key__(keys.last)
        result[required_key] = setting.is_a?(Qonfig::Settings) ? setting.__to_h__ : setting
      end
    end
  end

  # @param keys [Array<Symbol, String>]
  # @return [Hash]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.1.0
  def __deep_slice_value__(*keys)
    required_key = __indifferently_accessable_option_key__(keys.last)
    __deep_slice__(*keys)[required_key]
  end

  # @param value_processor [Block]
  # @param options_part [Hash]
  # @return [Hash]
  #
  # @api private
  # @since 0.2.0
  def __build_hash_representation__(options_part = __options__, &value_processor)
    options_part.each_with_object({}) do |(key, value), hash|
      case
      when value.is_a?(Hash)
        hash[key] = __build_hash_representation__(value, &value_processor)
      when value.is_a?(Qonfig::Settings)
        hash[key] = value.__to_hash__(&value_processor)
      else
        hash[key] = block_given? ? yield(value) : value
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

    define_singleton_method("#{key}?") do
      !!self.[](key)
    end
  end

  # @param key [Symbol, String]
  # @return [String]
  #
  # @raise [Qonfig::ArgumentError]
  # @see Qonfig::Settings::KeyGuard
  #
  # @api private
  # @since 0.2.0
  def __indifferently_accessable_option_key__(key)
    KeyGuard.new(key).prevent_incompatible_key_type!
    key.to_s
  end

  # @param key [Symbol, String]
  # @return [void]
  #
  # @raise [Qonfig::CoreMethodIntersectionError]
  # @see Qonfig::Settings::KeyGuard
  #
  # @api private
  # @since 0.2.0
  def __prevent_core_method_intersection__(key)
    KeyGuard.new(key).prevent_core_method_intersection!
  end

  # rubocop:disable Layout/ClassStructure
  # @return [Array<String>]
  #
  # @api private
  # @since 0.2.0
  CORE_METHODS = Array(
    instance_methods(false) |
    private_instance_methods(false) |
    %i[super define_singleton_method self]
  ).map(&:to_s).freeze
  # rubocop:enable Layout/ClassStructure
end
# rubocop:enable Metrics/ClassLength
