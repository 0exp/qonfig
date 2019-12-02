# frozen_string_literal: true

# @api private
# @since 0.18.0
class Qonfig::Imports::Abstract
  # @return [String]
  #
  # @api private
  # @since 0.18.0
  EMPTY_PREFIX = ''

  # @return [Boolean]
  #
  # @api private
  # @since 0.18.0
  DEFAULT_RAW_BEHAVIOR = false

  # @return [Boolean]
  #
  # @api private
  # @since 0.21.0
  AS_ACCESSOR = false

  # @param seeded_klass [Class]
  # @param imported_config [Qonfig::DataSet]
  # @option prefix [String, Symbol]
  # @option raw [Boolean]
  # @option accessor [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  # @version 0.21.0
  def initialize(
    seeded_klass,
    imported_config,
    prefix: EMPTY_PREFIX,
    raw: DEFAULT_RAW_BEHAVIOR,
    accessor: AS_ACCESSOR
  )
    @seeded_klass = seeded_klass
    @imported_config = imported_config
    @prefix = prefix
    @raw = !!raw
    @accessor = !!accessor
  end

  # @param settings_interface [Module]
  # @return [void]
  #
  # @api private
  # @since 0.18.0
  def import!(settings_interface = Module.new)
    # :nocov:
    raise NoMethodError
    # :nocov:
  end

  private

  # @return [Boolean]
  #
  # @api private
  # @since 0.18.0
  attr_reader :raw

  # @return [String, Symbol]
  #
  # @api private
  # @since 0.18.0
  attr_reader :prefix

  # @return [Class]
  #
  # @api private
  # @since 0.18.0
  attr_reader :seeded_klass

  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.18.0
  attr_reader :imported_config

  # @return [Boolean]
  #
  # @api private
  # @since 0.21.0
  attr_reader :accessor

  # @param imported_config [Qonfig::DataSet]
  # @param prefix [String, Symbol]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleImportedConfigError]
  # @raise [Qonfig::IncorrectImportPrefixError]
  #
  # @api private
  # @since 0.18.0
  def prevent_incompatible_import_params!(imported_config, prefix)
    raise(
      Qonfig::IncompatibleImportedConfigError,
      'Imported config object should be an isntance of Qonfig::DataSet'
    ) unless imported_config.is_a?(Qonfig::DataSet)

    raise(
      Qonfig::IncorrectImportPrefixError,
      'Import method prefix should be a type of string or symbol'
    ) unless prefix.is_a?(String) || prefix.is_a?(Symbol)
  end
end
