# frozen_string_literal: true

# @api private
# @since 0.20.0
module Qonfig::Validation::PredefinitionMixin
  # @param name [String, Symbol]
  # @param validation_logic [Block]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def define_validator(name, &validation_logic)
    Qonfig::DataSet.define_validator(name, &validation_logic)
  end
end
