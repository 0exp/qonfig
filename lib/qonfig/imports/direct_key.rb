# frozen_string_literal: true

# @api private
# @since 0.18.0
class Qonfig::Imports::DirectKey < Qonfig::Imports::Abstract
  # @param seeded_klass [Class]
  # @param imported_config [Qonfig::DataSet]
  # @param keys [Array<String,Symbol>]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.18.8
  def initialize(
    seeded_klass,
    imported_config,
    *keys,
    prefix: EMPTY_PREFIX,
    raw: DEFAULT_RAW_BEHAVIOR
  )
    prevent_incompatible_import_params!(imported_config, prefix, keys)
    super(seeded_klass, imported_config, prefix: prefix, raw: raw)
    @keys = keys
    @key_matchers = build_setting_key_matchers(keys)
  end

  # @param settings_interfcae [Module]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  def import!(settings_interface = Module.new) # rubocop:disable Metrics/AbcSize
    # step one: iterate each key matcher (that contain importing key from #keys)
    key_matchers.each do |key_matcher|
      raise(
        Qonfig::UnknownSettingError,
        "Setting with <#{key_matcher.scope_pattern}> key does not exist!"
      ) unless (imported_config.keys(all_variants: true).any? do |setting_key|
        key_matcher.match?(setting_key)
      end)

      imported_config.keys(all_variants: true).each do |setting_key|
        next unless key_matcher.match?(setting_key)

        setting_key_path_sequence = setting_key.split('.')
        access_method_name = setting_key_path_sequence.last
        access_method_name = "#{prefix}#{access_method_name}" unless prefix.empty?

        settings_interface.module_exec(raw, imported_config) do |raw, imported_config|
          unless raw
            # NOTE: get setting value via slice_value
            define_method(access_method_name) do
              imported_config.slice_value(*setting_key_path_sequence)
            end
          else
            # NOTE: get setting object (concrete value or Qonfig::Settings object)
            define_method(access_method_name) do
              imported_config.dig(*setting_key_path_sequence)
            end
          end
        end
      end
    end
  end

  private

  # @return [Array<String,Symbol>]
  #
  # @api private
  # @since 0.18.8
  attr_reader :keys

  # @return [Array<Qonfig::Settings::KeyMatcher>]
  #
  # @api private
  # @since 0.18.0
  attr_reader :key_matchers

  # @param imported_config [Qonfig::DataSet]
  # @param prefix [String, Symbol]
  # @param keys [Array<String,Symbol>]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleImportedConfigError]
  # @raise [Qonfig::IncompatibleImportPrefixError]
  # @raise [Qonfig::IncompatbileImportKeyError]
  #
  # @see Qonfig::Imports::Abstract#prevent_incompatible_import_params
  #
  # @api private
  # @since 0.18.0
  def prevent_incompatible_import_params!(imported_config, prefix, keys)
    super(imported_config, prefix)

    raise(
      Qonfig::IncompatbileImportKeyError,
      'Imported config keys should be a type of string or symbol'
    ) unless keys.all? { |key| key.is_a?(String) || key.is_a?(Symbol) }
  end

  # @param keys [Array<String,Symbol>]
  # @return [Array<Qonfig::KeyMatcher>]
  #
  # @api private
  # @since 0.18.0
  def build_setting_key_matchers(keys)
    keys.map { |key| Qonfig::Settings::KeyMatcher.new(key) }
  end
end
