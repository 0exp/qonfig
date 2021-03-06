# frozen_string_literal: true

# @api private
# @since 0.18.0
class Qonfig::Imports::General
  class << self
    # @param seeded_klass [Class, Object]
    # @param imported_config [Qonfig::DataSet]
    # @param imported_keys [Array<String, Symbol>]
    # @option mappings [Hash<String|Symbol,String|Symbol>]
    # @option prefix [String, Symbol]
    # @option raw [Boolean]
    # @option accessor [Boolean]
    # @return void]
    #
    # @api private
    # @since 0.18.0
    # @version 0.21.0
    def import!(
      seeded_klass,
      imported_config,
      *imported_keys,
      mappings: Qonfig::Imports::Mappings::EMPTY_MAPPINGS,
      prefix: Qonfig::Imports::Abstract::EMPTY_PREFIX,
      raw: Qonfig::Imports::Abstract::DEFAULT_RAW_BEHAVIOR,
      accessor: Qonfig::Imports::Abstract::AS_ACCESSOR
    )
      new(
        seeded_klass,
        imported_config,
        *imported_keys,
        mappings: mappings,
        prefix: prefix,
        raw: raw,
        accessor: accessor
      ).import!
    end
  end

  # @param seeded_klass [Class, Object]
  # @param imported_config [Qonfig::DataSet]
  # @param imported_keys [Array<String, Symbol>]
  # @option mappings [Hash<String|Symbol,String|Symbol>]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @option accessor [Boolean]
  # @return void]
  #
  # @api private
  # @since 0.18.0
  # @version 0.21.0
  def initialize(
    seeded_klass,
    imported_config,
    *imported_keys,
    mappings: Qonfig::Imports::Mappings::EMPTY_MAPPINGS,
    prefix: Qonfig::Imports::Abstract::EMPTY_PREFIX,
    raw: Qonfig::Imports::Abstract::DEFAULT_RAW_BEHAVIOR,
    accessor: Qonfig::Imports::Abstract::AS_ACCESSOR
  )
    @seeded_klass = seeded_klass

    @direct_key_importer = build_direct_key_importer(
      seeded_klass,
      imported_config,
      *imported_keys,
      prefix: prefix,
      raw: raw,
      accessor: accessor
    )

    @mappings_importer = build_mappings_importer(
      seeded_klass,
      imported_config,
      mappings: mappings,
      prefix: prefix,
      raw: raw,
      accessor: accessor
    )
  end

  # @param settings_interface [Module]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  def import!(settings_interface = Module.new)
    direct_key_importer.import!(settings_interface)
    mappings_importer.import!(settings_interface)
    seeded_klass.include(settings_interface)
  end

  private

  # @return [Class]
  #
  # @api private
  # @since 0.18.0
  attr_reader :seeded_klass

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

  # @param seeded_klass [Class]
  # @param imported_config [Qonfig::DataSet]
  # @param imported_keys [Array<String,Symbol>]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @option accessor [Boolean]
  # @return [Qonfig::Imports::DirectKey]
  #
  # @api private
  # @since 0.18.0
  # @version 0.21.0
  def build_direct_key_importer(
    seeded_klass,
    imported_config,
    *imported_keys,
    prefix:,
    raw:,
    accessor:
  )
    Qonfig::Imports::DirectKey.new(
      seeded_klass,
      imported_config,
      *imported_keys,
      prefix: prefix,
      raw: raw,
      accessor: accessor
    )
  end

  # @param seeded_klass [Class]
  # @param imported_config [Qonfig::DataSet]
  # @option mappings [Hash<Symbol|String,Symbol|String>]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @option accessor [Boolean]
  # @return [Qonfig::Imports::Mappings]
  #
  # @api private
  # @since 0.18.0
  # @version 0.21.0
  def build_mappings_importer(
    seeded_klass,
    imported_config,
    mappings:,
    prefix:,
    raw:,
    accessor:
  )
    Qonfig::Imports::Mappings.new(
      seeded_klass,
      imported_config,
      mappings: mappings,
      prefix: prefix,
      raw: raw,
      accessor: accessor
    )
  end
end
