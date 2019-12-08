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
  # @option accessor [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  # @version 0.21.0
  def initialize(
    seeded_klass,
    imported_config,
    mappings: EMPTY_MAPPINGS,
    prefix: EMPTY_PREFIX,
    raw: DEFAULT_RAW_BEHAVIOR,
    accessor: AS_ACCESSOR
  )
    prevent_incompatible_import_params!(imported_config, prefix, mappings)
    super(seeded_klass, imported_config, prefix: prefix, raw: raw, accessor: accessor)
    @mappings = mappings
    @key_matchers = build_setting_key_matchers(mappings)
  end

  # @param settings_interface [Module]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  # @version 0.21.0
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
  def import!(settings_interface = Module.new) # rubocop:disable Metrics/AbcSize
    key_matchers.each_pair do |(mapped_method_name, key_matcher)|
      raise(
        Qonfig::UnknownSettingError,
        "Setting with <#{key_matcher.scope_pattern}> key does not exist!"
      ) unless (imported_config.keys(all_variants: true).any? do |setting_key|
        key_matcher.match?(setting_key)
      end || key_matcher.generic?)

      imported_config.keys(all_variants: true).each do |setting_key|
        next unless key_matcher.match?(setting_key)

        setting_key_path_sequence = setting_key.split('.')
        mapped_method_name = "#{prefix}#{mapped_method_name}" unless prefix.empty?

        settings_interface.module_exec(
          raw, imported_config, accessor
        ) do |raw, imported_config, accessor|
          unless raw
            # NOTE: get setting value via slice_value
            define_method(mapped_method_name) do
              imported_config.slice_value(*setting_key_path_sequence)
            end
          else
            # NOTE: get setting object (concrete value or Qonfig::Settings object)
            define_method(mapped_method_name) do
              imported_config.dig(*setting_key_path_sequence)
            end
          end

          if accessor
            define_method("#{mapped_method_name}=") do |value|
              imported_config[setting_key] = value
            end
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength

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
  # @raise [Qonfig::IncorrectImportPrefixError]
  # @raise [Qonfig::IncorrectImportMappingsError]
  #
  # @see Qonfig::Imports::Abstract#prevent_incompatible_import_params!
  #
  # @api private
  # @since 0.18.0
  def prevent_incompatible_import_params!(imported_config, prefix, mappings)
    super(imported_config, prefix)

    raise(
      Qonfig::IncorrectImportMappingsError,
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
    mappings.each_with_object({}) do |(mapped_method_name, required_setting_key), matchers|
      matchers[mapped_method_name] = Qonfig::Settings::KeyMatcher.new(required_setting_key)
    end
  end
end
