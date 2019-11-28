# frozen_string_literal: true

# @api private
# @since 0.20.0
module Qonfig::Validation::DSL
  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.20.0
    def extended(base_klass)
      base_klass.instance_variable_set(:@predefined_validators, Qonfig::Validation::Collections::PredefinedRegistry.new)
      base_klass.instance_variable_set(:@validator_instances, Qonfig::Validation::Collections::InstanceCollection.new)

      base_klass.singleton_class.prepend(Module.new do
        def inherited(child_klass)
          child_klass.instance_variable_set(:@predefined_validators, Qonfig::Validation::Collections::PredefinedRegistry.new)
          child_klass.instance_variable_set(:@validator_instances, Qonfig::Validation::Colelctions::InstanceCollection.new)
          child_klass.predefined_validators.merge(predefined_validators)
          child_klass.validator_instances.concat(validator_instances)
          super
        end
      end)
    end
  end

  # @return [Qonfig::Validation::Collections::PredefinedRegistry]
  #
  # @api private
  # @since 0.19.0
  def predefined_validators
    @predefined_validators
  end

  # @return [Qonfig::Validation::Collections::InstanceCollection]
  #
  # @api private
  # @since 0.19.0
  def validator_instances
    @validator_instances
  end

  # @param name [String, Symbol]
  # @param validation_logic [Block]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def define_validator(name, &validation_logic)
    Qonfig::Validation::Building::PredefinedBuilder.build(
      name, validation_logic, predefined_validators
    )
  end
end
