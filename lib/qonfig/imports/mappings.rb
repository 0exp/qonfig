# frozen_string_literal: true

# @api private
# @since 0.18.0
class Qonfig::Imports::Mappings < Qonfig::Imports::Abstract
  # @return [Hash]
  #
  # @api private
  # @since 0.18.0
  EMPTY_MAPPINGS = {}.freeze

  # @param seeded_klass [Class]
  # @param imported_config [Qonfig::DataSet]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @option mappings [Hash<Symbol|String,Symbol|String>]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  def initialize(
    seeded_klass,
    imported_config,
    mappings: EMPTY_MAPPINGS,
    prefix: EMPTY_PREFIX,
    raw: DEFAULT_RAW_BEHAVIOR
  )
    prevent_incompatible_import_params!(imported_config, prefix, mappings)
    super(seeded_klass, imported_config, prefix: prefix, raw: raw)
    @mappings = mappings
    @key_matchers = build_setting_key_matchers(mappings)
  end

  # @param settings_interface [Module]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  def import!(settings_interface = Module.new)
  end

  private

  # @return [Hash<Symbol|String,Symbol|String>]
  #
  # @api private
  # @since 0.18.0
  attr_reader :mappings

  # @return [Hash<String|Symbol,Qonfig::Settings::KeyMatcher>]
  #
  # @api private
  # @since 0.18.0
  attr_reader :key_matchers

  # @param imported_config [Qonfig::DataSet]
  # @param prefix [String, Symbol]
  # @param mappings [Hash<Symbol|String,Symbol|String>]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleImportedConfigError]
  # @raise [Qonfig::IncompatibleImportPrefixError]
  # @raise [Qonfig::IncompatibeImportMappingsError]
  #
  # @see Qonfig::Imports::AbstractImporter
  #
  # @api private
  # @since 0.18.0
  def prevent_incompatible_import_params!(imported_config, prefix, mappings)
    super(imported_config, prefix)

    raise(
      Qonfig::IncompatibeImportMappingsError,
      'Import mappings should be a type of hash with String-or-Symbol keys and values'
    ) unless mappings.is_a?(Hash) && (mappings.each_pair.all? do |(mapping_key, mapping_value)|
      (mapping_key.is_a?(String) || mapping_key.is_a?(Symbol)) &&
      (mapping_value.is_a?(String) || mapping_value.is_a?(Symbol))
    end)
  end

  # @param mappings [Hash<Symbol|String,Symbol|String>]
  # @return [Hash<String|Symbol,Qonfig::Settings::KeyMatcher>]
  #
  # @api private
  # @since 0.18.0
  def build_setting_key_matchers(mappings)
    mappings.each_with_object({}) do |(method_name, required_setting_key), matchers|
      matchers[method_name] = Qonfig::Settings::KeyMatcher.new(required_setting_key)
    end
  end
end
