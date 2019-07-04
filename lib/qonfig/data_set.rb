# frozen_string_literal: true

# @api public
# @since 0.1.0
class Qonfig::DataSet
  require_relative 'data_set/class_builder'
  require_relative 'data_set/validator'

  # @since 0.1.0
  extend Qonfig::DSL

  # @return [Qonfig::Settings]
  #
  # @api private
  # @since 0.1.0
  attr_reader :settings

  # @param options_map [Hash]
  # @param configurations [Proc]
  #
  # @api public
  # @since 0.1.0
  def initialize(options_map = {}, &configurations)
    @__access_lock__ = Mutex.new
    @__definition_lock__ = Mutex.new

    thread_safe_definition { load!(options_map, &configurations) }
  end

  # @return [void]
  #
  # @api public
  # @since 0.1.0
  def freeze!
    thread_safe_access { settings.__freeze__ }
  end

  # @return [void]
  #
  # @api public
  # @since 0.2.0
  def frozen?
    thread_safe_access { settings.__is_frozen__ }
  end

  # @param options_map [Hash]
  # @param configurations [Proc]
  # @return [void]
  #
  # @raise [Qonfig::FrozenSettingsError]
  #
  # @api public
  # @since 0.2.0
  def reload!(options_map = {}, &configurations)
    thread_safe_definition do
      raise Qonfig::FrozenSettingsError, 'Frozen config can not be reloaded' if frozen?
      load!(options_map, &configurations)
    end
  end

  # @param options_map [Hash]
  # @return [void]
  #
  # @api public
  # @since 0.1.0
  def configure(options_map = {})
    thread_safe_access do
      settings.__apply_values__(options_map)
      yield(settings) if block_given?
    end
  end

  # @option key_transformer [Proc]
  # @option value_transformer [Proc]
  # @return [Hash]
  #
  # @api public
  # @since 0.1.0
  def to_h(
    key_transformer: Qonfig::Settings::BASIC_SETTING_KEY_TRANSFORMER,
    value_transformer: Qonfig::Settings::BASIC_SETTING_VALUE_TRANSFORMER
  )
    thread_safe_access do
      settings.__to_hash__(
        transform_key: key_transformer,
        transform_value: value_transformer
      )
    end
  end
  alias_method :to_hash, :to_h

  # @option path [String]
  # @option options [Hash<Symbol|String,Any>] Native (ruby-stdlib) ::JSON#generate attributes
  # @param value_processor [Block]
  # @return [void]
  #
  # @api public
  # @since 0.11.0
  def save_to_json(path:, options: Qonfig::Uploaders::JSON::DEFAULT_OPTIONS, &value_processor)
    thread_safe_access do
      Qonfig::Uploaders::JSON.upload(settings, path: path, options: options, &value_processor)
    end
  end
  alias_method :dump_to_json, :save_to_json

  # @option path [String]
  # @option symbolize_keys [Boolean]
  # @option options [Hash<Symbol|String,Any>] Native (ruby-stdlib) ::YAML#dump attributes
  # @param value_processor [Block]
  # @return [void]
  #
  # @api public
  # @since 0.11.0
  def save_to_yaml(
    path:,
    symbolize_keys: false,
    options: Qonfig::Uploaders::YAML::DEFAULT_OPTIONS,
    &value_processor
  )
    thread_safe_access do
      Qonfig::Uploaders::YAML.upload(
        settings,
        path: path,
        options: options.merge(symbolize_keys: symbolize_keys),
        &value_processor
      )
    end
  end
  alias_method :dump_to_yaml, :save_to_yaml

  # @option path [String]
  # @option options [Hash<Symbol,Any>] Nothing, just for compatability and consistency
  # @param value_processor [Block]
  # @return [void]
  #
  # @api public
  # @since 0.12.0
  def save_to_toml(path:, options: Qonfig::Uploaders::TOML::DEFAULT_OPTIONS, &value_processor)
    thread_safe_access do
      Qonfig::Uploaders::TOML.upload(settings, path: path, options: options, &value_processor)
    end
  end
  alias_method :dump_to_toml, :save_to_toml

  # @param key [String, Symbol]
  # @return [Object]
  #
  # @api public
  # @since 0.2.0
  def [](key)
    thread_safe_access { settings[key] }
  end

  # @param keys [Array<String, Symbol>]
  # @return [Object]
  #
  # @api public
  # @since 0.2.0
  def dig(*keys)
    thread_safe_access { settings.__dig__(*keys) }
  end

  # @param keys [Array<String, Symbol>]
  # @return [Hash]
  #
  # @api public
  # @since 0.9.0
  def slice(*keys)
    thread_safe_access { settings.__slice__(*keys) }
  end

  # @param keys [Array<String, Symbol>]
  # @return [Hash,Any]
  #
  # @api public
  # @since 0.10.0
  def slice_value(*keys)
    thread_safe_access { settings.__slice_value__(*keys) }
  end

  # @return [void]
  #
  # @api public
  # @since 0.2.0
  def clear!
    thread_safe_access { settings.__clear__ }
  end

  private

  # @return [Qonfig::Settings]
  #
  # @api private
  # @since 0.2.0
  def build_settings
    Qonfig::Settings::Builder.build(self.class.commands.dup)
  end

  # @param options_map [Hash]
  # @param configurations [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.2.0
  def load!(options_map = {}, &configurations)
    @settings = build_settings
    configure(options_map, &configurations)
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_access(&instructions)
    @__access_lock__.synchronize(&instructions)
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_definition(&instructions)
    @__definition_lock__.synchronize(&instructions)
  end
end
