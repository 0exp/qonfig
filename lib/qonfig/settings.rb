# frozen_string_literal: true

# @api private
# @since 0.1.0
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
  BASIC_SETTING_KEY_TRANSFORMER = proc { |value| value }.freeze

  # @return [Proc]
  #
  # @api private
  # @since 0.11.0
  BASIC_SETTING_VALUE_TRANSFORMER = proc { |value| value }.freeze

  # @return [Boolean]
  #
  # @api private
  # @since 0.25.0
  REPRESENT_HASH_IN_DOT_STYLE = false

  # @return [String]
  #
  # @api private
  # @since 0.19.0
  DOT_NOTATION_SEPARATOR = '.'

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
  # @version 0.31.0
  def initialize(__mutation_callbacks__)
    @__options__ = {}
    @__lock__ = Lock.new
    @__mutation_callbacks__ = __mutation_callbacks__
    @__deep_access_cache__ = {}

    # NOTE:
    #   Register a cache invalidator inside our own mutation callbacks.
    #   Nested settings add their parent's callbacks object to their own callbacks
    #   (see #__store_setting_value__), so a mutation of any nested config propagates
    #   upwards through the chain and drops the cached digging results on EACH config
    #   instance along the way ("matryoshka" cache invalidation).
    #
    #   It is prepended so that it runs BEFORE the validation callback — full
    #   data-set validators read setting values back through #__dig__, so the
    #   cache must already be dropped by the time they run.
    @__mutation_callbacks__.prepend(method(:__invalidate_deep_access_cache__))
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
  # @option yield_all [Boolean]
  # @return [Enumerable]
  #
  # @yield [key, value]
  # @yieldparam key [String]
  # @yieldparam value [Object]
  #
  # @api private
  # @since 0.13.0
  def __deep_each_setting__(initial_setting_key = nil, yield_all: false, &block)
    __lock__.thread_safe_access do
      __deep_each_key_value_pair__(initial_setting_key, yield_all: yield_all, &block)
    end
  end

  # @param key [Symbol, String]
  # @param value [Object]
  # @option with_redefinition [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.31.0
  def __define_setting__(key, value, with_redefinition: false) # rubocop:disable Metrics/AbcSize
    __lock__.thread_safe_definition do
      key = __indifferently_accessable_option_key__(key)

      __prevent_core_method_intersection__(key)

      case
      when with_redefinition || !__options__.key?(key)
        __store_setting_value__(key, value)
      when __is_a_setting__(__options__[key]) && __is_a_setting__(value)
        __options__[key].__append_settings__(value)
      else
        __store_setting_value__(key, value)
      end

      __define_option_reader__(key)
      __define_option_writer__(key)
      __define_option_predicate__(key)
    end
  end

  # @param settings [Qonfig::Settings]
  # @option with_redefinition [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  # @version 0.29.0
  def __append_settings__(settings, with_redefinition: false)
    __lock__.thread_safe_merge do
      settings.__options__.each_pair do |key, value|
        __define_setting__(key, value, with_redefinition: with_redefinition)
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
  # @raise [Qonfig::ArgumentError]
  #
  # @api public
  # @since 0.1.0
  # @version 0.25.0
  def [](*keys)
    __dig__(*keys)
  end

  # @param key [String, Symbol]
  # @param value [Object]
  # @return [void]
  #
  # @api public
  # @since 0.1.0
  # @version 0.21.0
  def []=(key, value)
    __lock__.thread_safe_access { __assign_value__(key, value) }
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
  # @version 0.31.0
  def __dig__(*keys)
    __lock__.thread_safe_access do
      # NOTE:
      #   Resolving a dot-notated/nested key (config['a.b.c.d']) is expensive:
      #   it splits and re-joins string fragments and digs through every nested
      #   config instance on each access. We memoize the resolved value per key
      #   set; the cache is dropped on any mutation (see __invalidate...).
      cache = @__deep_access_cache__
      cache_key = __deep_access_cache_key__(keys)

      if cache.key?(cache_key)
        cache[cache_key]
      else
        __resolve_deep_access__(*keys).tap { |value| cache[cache_key] = value }
      end
    end
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

  # @option dot_notation [Boolean]
  # @option transform_key [Proc]
  # @option transform_value [Proc]
  # @return [Hash]
  #
  # @api private
  # @since 0.1.0
  # @version 0.25.0
  def __to_hash__(
    dot_notation: REPRESENT_HASH_IN_DOT_STYLE,
    transform_key: BASIC_SETTING_KEY_TRANSFORMER,
    transform_value: BASIC_SETTING_VALUE_TRANSFORMER
  )
    unless transform_key.is_a?(Proc)
      ::Kernel.raise(
        Qonfig::IncorrectKeyTransformerError,
        'Key transformer should be a type of proc'
      )
    end

    unless transform_value.is_a?(Proc)
      ::Kernel.raise(
        Qonfig::IncorrectValueTransformerError,
        'Value transformer should be a type of proc'
      )
    end

    __lock__.thread_safe_access do
      if dot_notation
        __build_dot_notated_hash_representation__(
          transform_key: transform_key,
          transform_value: transform_value
        )
      else
        __build_basic_hash_representation__(
          transform_key: transform_key,
          transform_value: transform_value
        )
      end
    end
  end
  alias_method :__to_h__, :__to_hash__

  # @option all_variants [Boolean]
  # @return [Array<String>]
  #
  # @api private
  # @since 0.18.0
  def __keys__(all_variants: false)
    __lock__.thread_safe_access { __setting_keys__(all_variants: all_variants) }
  end

  # @return [Array<String>]
  #
  # @api private
  # @since 0.18.0
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

  # @param key_path [Array<Symbol, String>]
  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  def __has_key__(*key_path)
    __lock__.thread_safe_access { __is_key_exists__(*key_path) }
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
  # @since 0.18.0
  def __setting_keys__(all_variants: false)
    # NOTE: (if all_variants == true)
    #   We have { a: { b: { c: { d : 1 } } } }
    #   Its mean that we have these keys:
    #     - 'a' # => returns { b: { c: { d: 1 } } }
    #     - 'a.b' # => returns { c: { d: 1 } }
    #     - 'a.b.c' # => returns { d: 1 }
    #     - 'a.b.c.d' # => returns 1

    Set.new.tap do |setting_keys|
      __deep_each_key_value_pair__(yield_all: all_variants) do |setting_key, _setting_value|
        setting_keys << setting_key
      end
    end.to_a
  end

  # @return [Array<String>]
  #
  # @api private
  # @since 0.18.0
  def __root_setting_keys__
    __options__.keys
  end

  # @param key_path [Array<String, Symbol>]
  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  def __is_key_exists__(*key_path)
    begin
      __deep_access__(*key_path)
    rescue Qonfig::UnknownSettingError
      if key_path.size == 1
        __deep_access__(*__parse_dot_notated_key__(key_path.first))
      else
        raise
      end
    end

    true
  rescue Qonfig::UnknownSettingError
    false
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
  # @option yield_all [Boolean]
  # @return [Enumerator]
  #
  # @yield [setting_key, setting_value]
  # @yieldparam setting_key [String]
  # @yieldparam setting_value [Object]
  #
  # @api private
  # @since 0.13.0
  def __deep_each_key_value_pair__(initial_setting_key = nil, yield_all: false, &block)
    enumerator = Enumerator.new do |yielder|
      __each_key_value_pair__ do |setting_key, setting_value|
        final_setting_key =
          initial_setting_key ? "#{initial_setting_key}.#{setting_key}" : setting_key

        if __is_a_setting__(setting_value)
          yielder.yield(final_setting_key, setting_value) if yield_all
          setting_value.__deep_each_setting__(final_setting_key, yield_all: yield_all, &block)
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
  # @param value [Any]
  # @return [void]
  #
  # @api private
  # @since 0.21.0
  # rubocop:disable Naming/RescuedExceptionsVariableName, Style/SlicingWithRange
  def __assign_value__(key, value)
    key = __indifferently_accessable_option_key__(key)
    __set_value__(key, value)
  rescue Qonfig::UnknownSettingError => initial_error
    key_set = __parse_dot_notated_key__(key)

    # NOTE: key is not dot-notaed and original key does not exist
    raise(initial_error) if key_set.size == 1

    begin
      # TODO: rewrite with __deep_access__-like key resolving functionality
      setting_value = __get_value__(key_set.first)
      required_key = key_set[1..-1].join(DOT_NOTATION_SEPARATOR)
      setting_value[required_key] = value # NOTE: pseudo-recoursive assignment
    rescue Qonfig::UnknownSettingError
      raise(initial_error)
    end
  end
  # rubocop:enable Naming/RescuedExceptionsVariableName, Style/SlicingWithRange

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

  # @param key [String]
  # @param value [Object]
  # @return [void]
  #
  # @api private
  # @since 0.31.0
  def __store_setting_value__(key, value)
    __options__[key] = value

    # NOTE:
    #   A nested settings instance can arrive here "foreign" — built under another
    #   data set and merged into us by reference (compose / load_from_* / expose_* /
    #   option re-definition). Its mutation callbacks would then still point only at
    #   the discarded foreign parent, so a mutation of the nested config would never
    #   invalidate OUR deep-access cache (=> stale reads). Wire the nested instance
    #   into our callback chain on assignment so invalidation always cascades upwards
    #   ("matryoshka"), regardless of how the nested settings instance got here.
    value.__mutation_callbacks__.add(__mutation_callbacks__) if __is_a_setting__(value)
  end

  # @param keys [Array<String, Symbol>]
  # @return [Object]
  #
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.31.0
  def __resolve_deep_access__(*keys)
    __deep_access__(*keys)
  rescue Qonfig::UnknownSettingError
    if keys.size == 1
      __deep_access__(*__parse_dot_notated_key__(keys.first))
    else
      raise
    end
  end

  # @param keys [Array<String, Symbol>]
  # @return [String, Array<String>]
  #
  # @api private
  # @since 0.31.0
  def __deep_access_cache_key__(keys)
    # NOTE:
    #   Stringify keys so that symbol/string variants share a single cache slot
    #   (indifferent access), while preserving key boundaries — ['a.b', 'c'] and
    #   ['a', 'b', 'c'] resolve differently and must not collide. The single-key
    #   case (the dominant config['a.b.c'] form) avoids an extra array allocation.
    (keys.size == 1) ? keys.first.to_s : keys.map(&:to_s)
  end

  # @return [void]
  #
  # @api private
  # @since 0.31.0
  def __invalidate_deep_access_cache__
    # NOTE:
    #   Reassign (instead of #clear) so concurrent readers never observe a
    #   half-cleared hash — invalidation can propagate upwards from a nested
    #   mutation WITHOUT holding our access lock.
    #
    #   The reassignment must be UNCONDITIONAL. A `unless empty?` guard would skip
    #   the swap during the window where a concurrent reader has already resolved a
    #   now-stale value but has not yet written it into the (still-empty) cache —
    #   the stale write would then survive and be served forever. Rebinding the ivar
    #   to a fresh hash makes such a late write land in an orphaned hash instead.
    @__deep_access_cache__ = {}
  end

  # @param keys [Array<Symbol, String>]
  # @return [Object]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.2.0
  # rubocop:disable Metrics/AbcSize, Style/SlicingWithRange
  def __deep_access__(*keys)
    ::Kernel.raise(Qonfig::ArgumentError, 'Key list can not be empty') if keys.empty?

    result = nil
    rest_keys = nil
    key_parts_boundary = keys.size - 1

    0.upto(key_parts_boundary) do |key_parts_slice_boundary|
      begin
        setting_key = keys[0..key_parts_slice_boundary].join(DOT_NOTATION_SEPARATOR)
        result = __get_value__(setting_key)
        rest_keys = Array(keys[(key_parts_slice_boundary + 1)..-1])
        break
      rescue Qonfig::UnknownSettingError => error
        (key_parts_boundary == key_parts_slice_boundary) ? raise(error) : next
      end
    end

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
  # rubocop:enable Metrics/AbcSize, Style/SlicingWithRange

  # @param keys [Array<Symbol, String>]
  # @return [Hash]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.9.0
  # rubocop:disable Metrics/AbcSize
  def __deep_slice__(*keys)
    {}.tap do |result|
      begin
        __deep_access__(*keys).tap do |setting|
          required_key = __indifferently_accessable_option_key__(keys.last)
          result[required_key] = __is_a_setting__(setting) ? setting.__to_h__ : setting
        end
      rescue Qonfig::UnknownSettingError
        if keys.size == 1
          key_set = __parse_dot_notated_key__(keys.first)
          __deep_access__(*key_set).tap do |setting|
            required_key = __indifferently_accessable_option_key__(key_set.last)
            result[required_key] = __is_a_setting__(setting) ? setting.__to_h__ : setting
          end
        else
          raise
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

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
    sliced_data = __deep_slice__(*keys)

    case
    when sliced_data.key?(required_key)
      sliced_data[required_key]
    when keys.size == 1
      required_key = __parse_dot_notated_key__(required_key).last
      sliced_data[required_key]
    else # NOTE: possibly unreachable code
      # :nocov:
      raise(
        Qonfig::StrangeThingsError,
        "Strange things happpens with #{keys} keyset and value slicing"
      )
      # :nocov:
    end
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
            key_set.map { |key| __indifferently_accessable_option_key__(key) }
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
  # @since 0.25.0
  # rubocop:disable Layout/LineLength
  def __build_basic_hash_representation__(options_part = __options__, transform_key:, transform_value:)
    options_part.each_with_object({}) do |(key, value), hash|
      final_key = transform_key.call(key)

      case
      when value.is_a?(Hash)
        hash[final_key] = __build_basic_hash_representation__(
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
  # rubocop:enable Layout/LineLength

  # @option transform_key [Proc]
  # @option transform_value [Proc]
  # @return [Hash]
  #
  # @api private
  # @since 0.25.0
  def __build_dot_notated_hash_representation__(transform_key:, transform_value:)
    {}.tap do |hash|
      __deep_each_key_value_pair__ do |setting_key, setting_value|
        final_key = transform_key.call(setting_key)
        final_value = transform_value.call(setting_value)

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
    define_singleton_method(:"#{key}=") do |value|
      self.[]=(key, value)
    end
  end

  # @param key [Symbol, String]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def __define_option_predicate__(key)
    define_singleton_method(:"#{key}?") do
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

  # @param key [String, Symbol]
  # @return [Array<String>]
  #
  # @api private
  # @since 0.19.0
  def __parse_dot_notated_key__(key)
    __indifferently_accessable_option_key__(key).split(DOT_NOTATION_SEPARATOR)
  end

  # @return [Array<String>]
  #
  # @api private
  # @since 0.2.0
  CORE_METHODS = Array(
    instance_methods(false) |
    private_instance_methods(false) |
    %i[super define_singleton_method self is_a?]
  ).map(&:to_s).freeze
end
# rubocop:enable Metrics/ClassLength, Layout/ClassStructure
