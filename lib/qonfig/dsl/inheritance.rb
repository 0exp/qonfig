# frozen_string_literal: true

# @api private
# @since 0.21.0
module Qonfig::DSL::Inheritance
  class << self
    # @option base [Class<Qonfig::DataSet>, Class<Qonfig::Compacted>]
    # @option child [Class<Qonfig::DataSet>, Class<Qonfig::Compacted>]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def inherit(base:, child:)
      child.definition_commands.concat(base.definition_commands)
      child.instance_commands.concat(base.instance_commands, &:inheritable?)
      child.predefined_validators.merge(base.predefined_validators)
      child.validators.concat(base.validators)
    end
  end
end
