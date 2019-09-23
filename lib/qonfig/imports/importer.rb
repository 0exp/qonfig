# frozen_string_literal: true

# @api private
# @since 0.17.0
class Qonfig::Imports::Importer
  # @return [String]
  #
  # @api private
  # @since 0.17.0
  EMPTY_PREFIX = ''

  # @return [Hash]
  #
  # @api private
  # @since 0.17.0
  EMPTY_MAPPINGS = {}.freeze

  class << self
    # @param seeded_klass [Class]
    # @param imported_config [Qonfig::DataSet]
    # @param imported_keys [Array<String,Symbol>]
    # @option prefix [String, Symbol]
    # @option raw [Boolean]
    # @option mappings [Hash<String|Symbol,String|Symbol>]
    # @return [void]
    #
    # @api private
    # @since 0.17.0
    def import!(
      seeded_klass,
      imported_config,
      *imported_keys,
      prefix: EMPTY_PREFIX,
      raw: false,
      mappings: EMPTY_MAPPINGS
    )
      new(
        seeded_klass,
        imported_config,
        *imported_keys,
        prefix: prefix,
        raw: raw,
        mappings: mappings
      ).import!
    end
  end

  # @param seeded_klass [Class]
  # @param imported_config [Qonfig::DataSet]
  # @param imported_keys [Array<String,Symbol>]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @option mappings [Hash<String|Symbol,String|Symbol>]
  # @return [void]
  #
  # @api private
  # @since 0.17.0
  def initialize(
    seeded_klass,
    imported_config,
    *imported_keys,
    prefix: EMPTY_PREFIX,
    raw: false,
    mappings: EMPTY_MAPPINGS
  )
    prevent_incompatible_import_params!(imported_config, imported_keys, prefix, mappings)

    @raw             = !!raw
    @mappings        = mappings
    @prefix          = prefix.to_s
    @seeded_klass    = seeded_klass
    @imported_config = imported_config
    @imported_keys   = imported_keys
    @key_matchers    = imported_keys.map { |key| Qonfig::Settings::KeyMatcher.new(key) }
  end

  # @return [void]
  #
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.17.0
  def import!
    imported_settings_interface = Module.new

    key_matchers.each do |key_matcher|
      # NOTE: step one: check that exported key is exist
      raise(
        Qonfig::UnknownSettingError,
        "Setting with <#{key_matcher.scope_pattern}> key does not exist!"
      ) unless (imported_config.keys(all_variants: true).any? do |setting_key|
        key_matcher.match?(setting_key)
      end)

      # NOTE: step two: import matched keys
      imported_config.keys(all_variants: true).each do |setting_key|
        next unless key_matcher.match?(setting_key)

        setting_key_path_sequence = setting_key.split('.')
        access_method_name = setting_key_path_sequence.last
        access_method_name = "#{prefix}#{access_method_name}" unless prefix.empty?

        imported_settings_interface.module_exec(raw, imported_config) do |raw, imported_config|
          unless raw
            # NOTE: get setting value as a real value
            define_method(access_method_name) do
              imported_config.slice_value(*setting_key_path_sequence)
            end
          else
            # NOTE: get setting value (or Qonfig::Settings object)
            define_method(access_method_name) do
              imported_config.dig(*setting_key_path_sequence)
            end
          end
        end
      end
    end

    # NOTE:
    #   step three: include new interface
    #   (no prenend cuz we want to give a user an ability to define its own methods with the same
    #   names that provides our new generated interface)
    seeded_klass.include(imported_settings_interface)
  end

  private

  # @return seeded_klass [Class]
  #
  # @api private
  # @since 0.17.0
  attr_reader :seeded_klass

  # @return imported_config [Qonfig::DataSet]
  #
  # @api private
  # @since 0.17.0
  attr_reader :imported_config

  # @return imported_keys [Array<String,Symbol>]
  #
  # @api private
  # @since 0.17.0
  attr_reader :imported_keys

  # @return [Array<Qonfig::Setting::KeyMatcher>]
  #
  # @api private
  # @since 0.17.0
  attr_reader :key_matchers

  # @return [String]
  #
  # @api private
  # @since 0.17.0
  attr_reader :prefix

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  attr_reader :raw

  # @return [Hash<String|Symbol,String|Symbol>]
  #
  # @pai private
  # @since 0.17.0
  attr_reader :mappings

  # @param config [Qonfig::DataSet]
  # @param keys [Array<String,Symbol>]
  # @param prefix [String, Symbol]
  # @param mappings [Hash<String|Symbol,String|Symbol>]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleImportedConfigError]
  # @raise [Qonfig::IncompatbileImportKeyError]
  # @raise [Qonfig::IncompatibleImportPrefixError]
  # @raise [Qonfig::IncompatibleImportMappingsError]
  #
  # @api private
  # @since 0.17.0
  def prevent_incompatible_import_params!(config, keys, prefix, mappings)
    raise(
      Qonfig::IncompatibleImportedConfigError,
      'Imported config object should be an isntance of Qonfig::DataSet'
    ) unless config.is_a?(Qonfig::DataSet)

    raise(
      Qonfig::IncompatbileImportKeyError,
      'Imported config keys should be a type of string or symbol'
    ) unless keys.all? { |key| key.is_a?(String) || key.is_a?(Symbol) }

    raise(
      Qonfig::IncompatibleImportPrefixError,
      'Import method prefix should be a type of string or symbol'
    ) unless prefix.is_a?(String) || prefix.is_a?(Symbol)

    raise(
      Qonfig::IncompatibeImportMappingsError,
      'Import mappings should be a type of hash with String-or-Symbol keys and values'
    ) unless mappings.is_a?(Hash) && (mappings.each_pair.all? do |(mapping_key, mapping_value)|
      (mapping_key.is_a?(String) || mapping_key.is_a?(Symbol)) &&
      (mapping_value.is_a?(String) || mapping_value.is_a?(Symbol))
    end)
  end
end
