# frozen_string_literal: true

# @api private
# @since 0.18.0
class Qonfig::Imports::General
  def initialize(
    seeded_klass,
    imported_config,
    *imported_keys,
    mappings: EMPTY_MAPPINGS,
    prefix: EMPTY_PREFIX,
    raw: false
  )
    @direct_key_importer = Qonfig::Imports::DirectKey.new(
      seeded_klass, imported_config, *imported_keys, prefix: prefix, raw: raw
    )

    @mappings_importer = Qonifg::Imports::Mappings.new(
      seeded_klass, imported_config, mappings: mappings, prefix: prefix, raw: raw
    )
  end

  # @return [void]
  #
  # @raise [Qonfig::UnknownSettingError]
  #
  # @api private
  # @since 0.18.0
  def import!(settings_interface = Module.new)
    direct_key_importer.import!(settings_interface)
    mappings_importer.import!(settings_interface)

    seeded_klass.include(settings_interface)
  end

  private

  # @return [Qonfig::Imports::DirectKey]
  #
  # @api private
  # @since 0.18.0
  attr_reader :direct_key_importer

  # @return [Qonfig::Imports::Mappings]
  #
  # @api private
  # @since 0.18.0
  attr_reader :mappings_importer
end
