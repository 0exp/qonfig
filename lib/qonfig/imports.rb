# frozen_string_literal: true

# @api public
# @since 0.18.0
module Qonfig::Imports
  require_relative 'imports/importer'
  require_relative 'imports/direct_key_import'
  require_relative 'imports/mapping_import'

  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.18.0
    def included(base_klass)
      base_klass.extend(ClassMethods)
    end
  end

  # @api private
  # @since 0.18.0
  module ClassMethods
    # @param config [Qonfig::DataSet]
    # @param setting_keys [Array<String,Symbol>]
    # @option prefix [String, Symbol]
    # @option raw [Boolean]
    # @option mappings [Hash<String|Symbol,String|Symbol>]
    # @return [void]
    #
    # @api public
    # @since 0.18.0
    def import_settings(
      config,
      *setting_keys,
      prefix: Qonfig::Imports::Importer::EMPTY_PREFIX,
      raw: false,
      mappings: Qonfig::Imports::Importer::EMPTY_MAPPINGS
    )
      Qonfig::Imports::Importer.import!(
        self, config, *setting_keys, prefix: prefix, raw: raw, mappings: mappings
      )
    end
  end
end
