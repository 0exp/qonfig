# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::DefinitionSet
  # @return [Array]
  #
  # @api private
  # @since 0.1.0
  attr_reader :definitions

  # @api private
  # @since 0.1.0
  def initialize
    @definitions = []
  end

  # @param definition [Qonfig::Option]
  # @return void
  #
  # @api private
  # @since 0.1.0
  def add_definition(definition)
    @definitions << definition
  end
  alias_method :<<, :add_definition

  # @param definition_set [Qonfig::DefinitionSet]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def concat(definition_set)
    definitions.concat(definition_set.definitions)
  end

  # @param block [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    definitions.each(&block)
  end
end
