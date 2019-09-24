# frozen_string_literal: true
 # rubocop:disable Metrics/ClassLength, Layout/ClassStructure
class Qonfig::Settings # NOTE: Layout/ClassStructure is disabled only for CORE_METHODS constant
  require_relative 'settings/callbacks'
  require_relative 'settings/lock'
  require_relative 'settings/builder'
  require_relative 'settings/key_guard'
  require_relative 'settings/key_matcher'

  # @return [Proc]
  #
  # @api private
  # @since 0.11.0
  BASIC_SETTING_KEY_TRANSFORMER = (proc { |value| value }).freeze

  # @return [Proc]
  #
  # @api private
  # @since 0.11.0
  BASIC_SETTING_VALUE_TRANSFORMER = (proc { |value| value }).freeze

  # @return [Hash]
  #
  # @api private
  # @since 0.1.0
  attr_reader :__options__

  # @return [Qonfig::Settings::Callbacks]
  #
  # @api private
  # @since 0.13.0
  attr_reader :__mutation_callbacks__

  # @api private
  # @since 0.1.0
  def initialize(__mutation_callbacks__)
    @__options__ = {}
    @__lock__ = Lock.new
    @__mutation_callbacks__ = __mutation_callbacks__
  end

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @yield [key, value]
  # @yieldparam key [String]
  # @yieldparam value [Object]
  #
  # @api private
  # @since 0.13.0
  def __each_setting__(&block)
    __lock__.thread_safe_access do
      __each_key_value_pair__(&block)
    end
  end

  # @param initial_setting_key [String, NilClass]
  # @param block [Proc]
  # @return [Enumerable]
  #
  # @yield [key, value]
  # @yieldparam key [String]
  # @yieldparam value [Object]
  #
  # @api private
  # @since 0.13.0
  def __deep_each_setting__(initial_setting_key = nil, &block)
    __lock__.thread_safe_access do
      __deep_each_key_value_pair__(initial_setting_key, &block)
    end
  end

  # @param key [Symbol, String]
  # @param value [Object]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def __define_setting__(key, value) # rubocop:disable Metrics/AbcSize
    __lock__.thread_safe_definition do
      key = __indifferently_accessable_option_key__(key)

      __prevent_core_method_intersection__(key)

      case
      when !__options__.key?(key)
        __options__[key] = value
      when __is_a_setting__(__options__[key]) && __is_a_setting__(value)
        __options__[key].__append_settings__(value)
      else
        __options__[key] = value
      end

      __define_option_reader__(key)
      __define_option_writer__(key)
      __define_option_predicate__(key)
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

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def __invoke_mutation_callbacks__
    __mutation_callbacks__.call
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

  # @param settings_map [Hash]
  # @return [void]
  #
  # @api private
  # @since 0.3.0
  def __apply_values__(settings_map)
    __lock__.thread_safe_access { __set_values_from_map__(settings_map) }
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

  # @param keys [Array<String, Symbol, Array<String, Symbol>>]
  # @return [Hash]
  #
  # @api private
  # @since 0.16.0
  def __subset__(*keys)
    __lock__.thread_safe_access { __deep_subset__(*keys) }
  end

  # @option transform_key [Proc]
  # @option transform_value [Proc]
  # @return [Hash]
  #
  # @api private
  # @since 0.1.0
  # rubocop:disable Metrics/LineLength
  def __to_hash__(transform_key: BASIC_SETTING_KEY_TRANSFORMER, transform_value: BASIC_SETTING_VALUE_TRANSFORMER)
    unless transform_key.is_a?(Proc)
      ::Kernel.raise(Qonfig::IncorrectKeyTransformerError, 'Key transformer should be a type of proc')
    end

    unless transform_value.is_a?(Proc)
      ::Kernel.raise(Qonfig::IncorrectValueTransformerError, 'Value transformer should be a type of proc')
    end

    __lock__.thread_safe_access do
      __build_hash_representation__(transform_key: transform_key, transform_value: transform_value)
    end
  end
  # rubocop:enable Metrics/LineLength
  alias_method :__to_h__, :__to_hash__

  # @option all_variants [Boolean]
  # @return [Array<String>]
  #
  # @api private
  # @since 0.17.0
  def __keys__(all_variants: false)
    __lock__.thread_safe_access { __setting_keys__(all_variants: all_variants) }
  end

  # @return [Array<String>]
  #
  # @api private
  # @since 0.17.0
  def __root_keys__
    __lock__.thread_safe_access { __root_setting_keys__ }
  end

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
        value.__freeze__ if __is_a_setting__(value)
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

  # @param value [Any]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def __is_a_setting__(value)
    value.is_a?(Qonfig::Settings)
  end

  private

  # @return [Qonfig::Settings::Lock]
  #
  # @api private
  # @since 0.2.0
  attr_reader :__lock__

  # @option all_variants [Boolean]
  # @return [Array<String>]
  #
  # @api private
  # @since 0.17.0
  def __setting_keys__(all_variants: false)
    # NOTE: generate a set of keys return simple 'a.b.c.d'
    setting_keys_set = Set.new.tap do |setting_keys|
      __deep_each_key_value_pair__ do |setting_key, _setting_value|
        setting_keys << setting_key
      end
    end

    if all_variants
      # NOTE:
      #   We have { a: { b: { c: { d : 1 } } } }
      #   Its mean that we have these keys:
      #     - 'a' # => returns { b: { c: { d: 1 } } }
      #     - 'a.b' # => returns { c: { d: 1 } }
      #     - 'a.b.c' # => returns { d: 1 }
      #     - 'a.b.c.d' # => returns 1
      #   So, get them all :)

      setting_keys_set.each_with_object(Set.new) do |setting_key, varianted_setting_keys|
        setting_key_paths = setting_key.split('.')
        combination_size  = setting_key_paths.size

        combination_size.times do |merged_key_patterns_count|
          sub_setting_key = setting_key_paths.slice(0..merged_key_patterns_count).join('.')
          varianted_setting_keys << sub_setting_key
        end
      end
    else
      setting_keys_set
    end
  end

  # @return [Array<String>]
  #
  # @api private
  # @since 0.17.0
  def __root_setting_keys__
    __options__.keys
  end

  # @param block [Proc]
  # @return [Enumerator]
  #
  # @yield [setting_key, setting_value]
  # @yieldparam key [String]
  # @yieldparam value [Object]
  #
  # @api private
  # @since 0.13.0
  def __each_key_value_pair__(&block)
    __options__.each_pair(&block)
  end

  # @param initial_setting_key [String, NilClass]
  # @param block [Proc]
  # @return [Enumerator]
  #
  # @yield [setting_key, setting_value]
  # @yieldparam setting_key [String]
  # @yieldparam setting_value [Object]
  #
  # @api private
  # @since 0.13.0
  def __deep_each_key_value_pair__(initial_setting_key = nil, &block)
    enumerator = Enumerator.new do |yielder|
      __each_key_value_pair__ do |setting_key, setting_value|
        final_setting_key =
          initial_setting_key ? "#{initial_setting_key}.#{setting_key}" : setting_key

        if __is_a_setting__(setting_value)
          setting_value.__deep_each_setting__(final_setting_key, &block)
        else
          yielder.yield(final_setting_key, setting_value)
        end
      end
    end

    block_given? ? enumerator.each(&block) : enumerator
  end

  # @param settings_map [Hash]
  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::AmbiguousSettingValueError]
  #
  # @api private
  # @since 0.3.0
  def __set_values_from_map__(settings_map)
    ::Kernel.raise(
      Qonfig::ArgumentError, 'Options map should be represented as a hash'
    ) unless settings_map.is_a?(Hash)

    settings_map.each_pair do |key, value|
      current_value = __get_value__(key)

      # NOTE: some duplications here was made only for the better code readability
      case
      when !__is_a_setting__(current_value)
        __set_value__(key, value)
      when __is_a_setting__(current_value) && value.is_a?(Hash)
        current_value.__apply_values__(value)
      when __is_a_setting__(current_value) && !value.is_a?(Hash)
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
      __is_a_setting__(value) ? value.__clear__ : __options__[key] = nil
    end

    __invoke_mutation_callbacks__
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

    if __is_a_setting__(__options__[key])
      ::Kernel.raise(
        Qonfig::AmbiguousSettingValueError,
        "Can not redefine option <#{key}> that contains nested options"
      )
    end

    (__options__[key] = value)

    __invoke_mutation_callbacks__
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
    when !__is_a_setting__(result)
      ::Kernel.raise(
        Qonfig::UnknownSettingError,
        'Setting with required digging sequence does not exist!'
      )
    when __is_a_setting__(result)
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
        result[required_key] = __is_a_setting__(setting) ? setting.__to_h__ : setting
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

  # @param keys [Array<String, Symbol, Array<String, Symbol>>]
  # @return [Hash]
  #
  # @api private
  # @since 0.16.0
  def __deep_subset__(*keys)
    {}.tap do |result|
      keys.each do |key_set|
        required_keys =
          case key_set
          when String, Symbol
            # TODO: support for patterns
            __indifferently_accessable_option_key__(key_set)
          when Array
            key_set.map(&method(:__indifferently_accessable_option_key__))
          else
            raise(
              Qonfig::ArgumentError,
              'All setting keys should be a symbol/string or an array of symbols/strings!'
            )
          end

        required_options = __deep_slice__(*required_keys)
        result.merge!(required_options)
      end
    end
  end

  # @param options_part [Hash]
  # @option transform_key [Proc]
  # @option transform_value [Proc]
  # @return [Hash]
  #
  # @api private
  # @since 0.2.0
  def __build_hash_representation__(options_part = __options__, transform_key:, transform_value:)
    options_part.each_with_object({}) do |(key, value), hash|
      final_key = transform_key.call(key)

      case
      when value.is_a?(Hash)
        hash[final_key] = __build_hash_representation__(
          value,
          transform_key: transform_key,
          transform_value: transform_value
        )
      when __is_a_setting__(value)
        hash[final_key] = value.__to_hash__(
          transform_key: transform_key,
          transform_value: transform_value
        )
      else
        final_value = transform_value.call(value)
        hash[final_key] = final_value
      end
    end
  end

  # @param key [Symbol, String]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def __define_option_reader__(key)
    define_singleton_method(key) do
      self.[](key)
    end
  end

  # @param key [Symbol, String]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def __define_option_writer__(key)
    define_singleton_method("#{key}=") do |value|
      self.[]=(key, value)
    end
  end

  # @param key [Symbol, String]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def __define_option_predicate__(key)
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

  # @return [Array<String>]
  #
  # @api private
  # @since 0.2.0
  CORE_METHODS = Array(
    instance_methods(false) |
    private_instance_methods(false) |
    %i[super define_singleton_method self]
  ).map(&:to_s).freeze
end
# rubocop:enable Metrics/ClassLength, Layout/ClassStructure
