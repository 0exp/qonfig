# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Builders::PredefinedBuilder
  class << self
    # @param name [String, Symbol]
    # @param validation_logic [Proc]
    # @param predefined_registry [Qonfig::Validation::Collections::PredefinedRegistry]
    # @return [void]
    #
    # @api private
    # @since 0.20.0
    def build(name, validation_logic, predefined_registry)
      new(name, validation_logic, predefined_registry).build
    end
  end

  # @param name [String, Symbol]
  # @param validation_logic [Proc]
  # @param predefined_registry [Qonfig::Validation::Collections::PredefinedRegistry]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize(name, validation_logic, predefined_registry)
    @name = name
    @validation_logic = validation_logic
    @predefined_registry = predefined_registry
  end

  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def build
    validate_attributes!
    predefine_validator
  end

  private

  # @return [void]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.20.0
  def validate_attributes!
    raise(
      Qonfig::ValidatorArgumentError,
      'Validator name should be a type of string or symbol'
    ) unless name.is_a?(String) || name.is_a?(Symbol)

    raise(
      Qonfig::ValidatorArgumentError,
      'Empty validation logic (block is not given)'
    ) if validation_logic.nil? || !validation_logic.is_a?(Proc)
  end

  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def predefine_validator
    predefined_registry[name] = validation_logic
  end

  # @return [String]
  #
  # @api private
  # @since 0.20.0
  attr_reader :name

  # @return [Proc]
  #
  # @api private
  # @since 0.20.0
  attr_reader :validation_logic

  # @return [Qonfig::Validation::Collections::PredefinedRegistry]
  #
  # @api private
  # @since 0.20.0
  attr_reader :predefined_registry
end
