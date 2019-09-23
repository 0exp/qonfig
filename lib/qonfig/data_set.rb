# frozen_string_literal: true

# @api public
# @since 0.1.0
class Qonfig::DataSet # rubocop:disable Metrics/ClassLength
  require_relative 'data_set/class_builder'
  require_relative 'data_set/lock'

  # @since 0.1.0
  extend Qonfig::DSL

  # @since 0.13.0
  extend Qonfig::Validator::DSL

  class << self
    # @param config_klass_definitions [Proc]
    # @return [Qonfig::DataSet]
    #
    # @api public
    # @since 0.16.0
    def build(&config_klass_definitions)
      Class.new(self, &config_klass_definitions).new
    end
  end

  # @return [Qonfig::Settings]
  #
  # @api private
  # @since 0.1.0
  attr_reader :settings

  # @param settings_map [Hash]
  # @param configurations [Proc]
  #
  # @api public
  # @since 0.1.0
  def initialize(settings_map = {}, &configurations)
    @__lock__ = Qonfig::DataSet::Lock.new
    thread_safe_definition { load!(settings_map, &configurations) }
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

  # @param settings_map [Hash]
  # @param configurations [Proc]
  # @return [void]
  #
  # @raise [Qonfig::FrozenSettingsError]
  #
  # @api public
  # @since 0.2.0
  def reload!(settings_map = {}, &configurations)
    thread_safe_definition do
      raise Qonfig::FrozenSettingsError, 'Frozen config can not be reloaded' if frozen?
      load!(settings_map, &configurations)
    end
  end

  # @param settings_map [Hash]
  # @return [void]
  #
  # @api public
  # @since 0.1.0
  def configure(settings_map = {}, &configurations)
    thread_safe_access do
      apply_settings(settings_map, &configurations)
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

  # @param keys [Array<String, Symbol, Array<String, Symbol>>]
  # @return [Hash]
  #
  # @api private
  # @since 0.16.0
  def subset(*keys)
    thread_safe_access { settings.__subset__(*keys) }
  end

  # @return [void]
  #
  # @api public
  # @since 0.2.0
  def clear!
    thread_safe_access { settings.__clear__ }
  end

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @yield [setting_key, setting_value]
  # @yieldparam setting_key [String]
  # @yieldparam setting_value [Object]
  #
  # @api public
  # @since 0.13.0
  def each_setting(&block)
    thread_safe_access { settings.__each_setting__(&block) }
  end

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @yield [setting_key, setting_value]
  # @yieldparam setting_key [String]
  # @yieldparam setting_value [Object]
  #
  # @api public
  # @since 0.13.0
  def deep_each_setting(&block)
    thread_safe_access { settings.__deep_each_setting__(&block) }
  end

  # @return [Boolean]
  #
  # @api public
  # @since 0.13.0
  def valid?
    thread_safe_access { validator.valid? }
  end

  # @return [void]
  #
  # @api public
  # @since 0.13.0
  def validate!
    thread_safe_access { validator.validate! }
  end

  # @option all_variants [Boolean]
  # @return [Array<String>]
  #
  # @api public
  # @since 0.17.0
  def keys(all_variants: false)
    thread_safe_access { settings.__keys__(all_variants: all_variants) }
  end

  # @return [Array<String>]
  #
  # @api public
  # @since 0.17.0
  def root_keys
    thread_safe_access { settings.__root_keys__ }
  end

  # @return [void]
  #
  # @api public
  # @since 0.17.0
  def export_settings(
    exportable_object,
    *exported_setting_keys,
    prefix: Qonfig::Imports::Importer::EMPTY_PREFIX,
    raw: false,
    mappings: Qonfig::Imports::Importer::EMPTY_MAPPINGS
  )
    thread_safe_access do
      unless exportable_object.is_a?(Module)
        exportable_object = exportable_object.singleton_class
      end

      Qonfig::Imports::Importer.import!(
        exportable_object,
        self,
        *exported_setting_keys,
        prefix: prefix,
        raw: raw,
        mappings: mappings
      )
    end
  end


  private

  # @return [Qonfig::Validator]
  #
  # @api private
  # @since 0.13.0
  attr_reader :validator

  # @return [void]
  #
  # @api private
  # @since 0.2.0
  def build_settings
    @settings = Qonfig::Settings::Builder.build(self)
    validator.validate!
  end

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def build_validator
    @validator = Qonfig::Validator.new(self)
  end

  # @param settings_map [Hash]
  # @param configurations [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def apply_settings(settings_map = {}, &configurations)
    settings.__apply_values__(settings_map)
    yield(settings) if block_given?
  end

  # @param settings_map [Hash]
  # @param configurations [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.2.0
  def load!(settings_map = {}, &configurations)
    build_validator
    build_settings
    apply_settings(settings_map, &configurations)
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_access(&instructions)
    @__lock__.thread_safe_access(&instructions)
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_definition(&instructions)
    @__lock__.thread_safe_definition(&instructions)
  end
end
