# frozen_string_literal: true

# @api private
# @since 0.21.0
module Qonfig::Compacted::ClassBuilder
  class << self
    # @option base_klass [Class<Qonfig::DataSet>]
    # @option child_klass [Class<Qonfig::DataSet>]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def inherit(base_klass:, child_klass:)
      child_klass.definition_commands.concat(base_klass.definition_commands)
      child_klass.instance_commands.concat(base_klass.instance_commands, &:inheritable?)
      child_klass.predefined_validators.merge(base_klass.predefined_validators)
      child_klass.validators.concat(base_klass.validators)
    end
  end
end
