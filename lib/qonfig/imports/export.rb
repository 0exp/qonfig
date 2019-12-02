# frozen_string_literal: true

# @api private
# @since 0.18.0
module Qonfig::Imports::Export
  class << self
    # @param exportable_object [Object]
    # @param exported_config [Qonfig::DataSet]
    # @param exported_setting_keys [Array<String,Symbol>]
    # @option mappings [Hash<String|Symbol,String|Symbol>]
    # @option raw [Boolean]
    # @option prefix [String, Symbol]
    # @option accessor [Boolean]
    # @return [void]
    #
    # @api private
    # @since 0.18.0
    # @version 0.21.0
    def export!(
      exportable_object,
      exported_config,
      *exported_setting_keys,
      mappings: Qonfig::Imports::Mappings::EMPTY_MAPPINGS,
      raw: Qonfig::Imports::Abstract::DEFAULT_RAW_BEHAVIOR,
      prefix: Qonfig::Imports::Abstract::EMPTY_PREFIX,
      accessor: Qonfig::Imports::Abstract::AS_ACCESSOR
    )
      unless exportable_object.is_a?(Module)
        exportable_object = exportable_object.singleton_class
      end

      Qonfig::Imports::General.import!(
        exportable_object,
        exported_config,
        *exported_setting_keys,
        prefix: prefix,
        raw: raw,
        mappings: mappings,
        accessor: accessor
      )
    end
  end
end
