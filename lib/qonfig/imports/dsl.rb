# frozen_string_literal: true

# @api private
# @since 0.18.0
module Qonfig::Imports::DSL
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
    # @param imported_config [Qonfig::DataSet]
    # @param imported_setting_keys [Array<String,Symbol>]
    # @option prefix [String, Symbol]
    # @option raw [Boolean]
    # @option mappings [Hash<String|Symbol,String|Symbol>]
    # @return [void]
    #
    # @api public
    # @since 0.18.0
    def import_settings(
      imported_config,
      *imported_setting_keys,
      prefix: Qonfig::Imports::Abstract::EMPTY_PREFIX,
      raw: Qonfig::Imports::Abstract::DEFAULT_RAW_BEHAVIOR,
      mappings: Qonfig::Imports::Mappings::EMPTY_MAPPINGS
    )
      Qonfig::Imports::General.new(
        self,
        imported_config,
        *imported_setting_keys,
        prefix: prefix,
        raw: raw,
        mappings: mappings
      ).import!
    end
  end
end
