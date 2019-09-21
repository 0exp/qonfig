# frozen_string_literal: true

# @api public
# @since 0.17.0
module Qonfig::Exporting
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
    # @return [void]
    #
    # @api public
    # @since 0.17.0
    def export_config(config, *setting_keys)

    end
  end
end
