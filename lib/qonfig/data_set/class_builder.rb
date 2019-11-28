# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::DataSet::ClassBuilder
  class << self
    # @param hash [Hash]
    # @return [Class<Qonfig::DataSet>]
    #
    # @see Qonfig::DataSet
    #
    # @api private
    # @since 0.2.0
    def build_from_hash(hash)
      Class.new(Qonfig::DataSet).tap do |data_set_klass|
        hash.each_pair do |key, value|
          if value.is_a?(Hash) && value.any?
            sub_data_set_klass = build_from_hash(value)
            data_set_klass.setting(key) { compose sub_data_set_klass }
          else
            data_set_klass.setting key, value
          end
        end
      end
    end

    # @option base_klass [Class<Qonfig::DataSet>]
    # @option child_klass [Class<Qonfig::DataSet>]
    # @return [void]
    #
    # @api private
    # @since 0.19.0
    def inherit(base_klass:, child_klass:)
      child_klass.definition_commands.concat(base_klass.definition_commands)
      child_klass.instance_commands.concat(base_klass.instance_commands, &:inheritable?)
      child_klass.predefined_validators.merge(base_klass.predefined_validators)
      child_klass.validators.concat(base_klass.validators)
    end
  end
end
