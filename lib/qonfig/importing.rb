# frozen_string_literal: true

# @api public
# @since 0.17.0
module Qonfig::Importing
  require_relative 'importing/importer'

  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.17.0
    def included(base_klass)
      base_klass.extend(DSL)
    end
  end

  # @api private
  # @since 0.17.0
  module DSL
    # @param config [Qonfig::DataSet]
    # @param setting_keys [Array<String,Symbol>]
    # @option prefix [String, Symbol]
    # @option raw [Boolean]
    # @option mappings [Hash<String|Symbol,String|Symbol>]
    # @return [void]
    #
    # @api public
    # @since 0.17.0
    def import_settings(
      config,
      *setting_keys,
      prefix: Qonfig::Importing::Importer::EMPTY_PREFIX,
      raw: false,
      mappings: Qonfig::Importing::Importer::EMPTY_MAPPINGS
    )
      Qonfig::Importing::Importer.import!(
        self, config, *setting_keys, prefix: prefix, raw: raw, mappings: mappings
      )
    end
  end
end
