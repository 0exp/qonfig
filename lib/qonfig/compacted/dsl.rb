# frozen_string_literal: true

# @api private
# @since 0.21.0
module Qonfig::Compacted::DSL
  class << self
    # @param child_klass [Class<Qonfig::Compacted>]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def extended(child_klass)
      child_klass.instance_variable_set(:@definition_commands, Qonfig::CommandSet.new)
      child_klass.instance_variable_set(:@instance_commands, Qonfig::CommandSet.new)
      child_klass.instance_variable_set(:@predefined_validators, Qonfig::Validation::Colelctions::PredefinedRegistry.new)
      child_klass.instance_variable_set(:@valdiators, Qonfig::Validation::Collections::InstanceCollection.new)

      child_klass.singleton_class.prepend(Module.new do
        def inherited(child_klass)
          child_klass.instance_variable_set(:@definition_commands, Qonfig::CommandSet.new)
          child_klass.instance_variable_set(:@instance_commands, Qonfig::CommandSet.new)
          child_klass.instance_variable_set(:@predefined_validators, Qonfig::Validation::Colelctions::PredefinedRegistry.new)
          child_klass.instance_variable_set(:@valdiators, Qonfig::Validation::Collections::InstanceCollection.new)
          Qonfig::Compacted::ClassBuilder.inherit(base_klass: self, child_klass: child_klass)
        end
      end)
    end
  end

  # @return [Qonfig::CommandSet]
  #
  # @api private
  # @since 0.21.0
  def definition_commands
    @definition_commands
  end

  # @return [Qonfig::CommandSet]
  #
  # @api private
  # @since 0.21.0
  def instance_commands
    @instance_commands
  end

  # @return [Qonfig::Validation::Collections::PredefinedRegistry]
  #
  # @api private
  # @since 0.20.0
  def predefined_validators
    @predefined_validators
  end

  # @return [Qonfig::Validation::Collections::InstanceCollection]
  #
  # @api private
  # @since 0.20.0
  def validators
    @validators
  end

  # @param setting_key_pattern [String, Symbol, NilClass]
  # @param predefined [String, Symbol]
  # @option by [String, Symbol, NilClass]
  # @option stict [Boolean]
  # @param custom_validation [Proc]
  # @return [void]
  #
  # @see Qonfig::Validation::Building::InstanceBuilder
  #
  # @api public
  # @since 0.20.0
  def validate(
    setting_key_pattern = nil,
    predefined = nil,
    strict: false,
    by: nil,
    &custom_validation
  )
    validators << Qonfig::Validation::Building::InstanceBuilder.build(
      self,
      setting_key_pattern: setting_key_pattern,
      predefined_validator: predefined,
      runtime_validation_method: by,
      strict: strict,
      validation_logic: custom_validation
    )
  end

  # @param name [String, Symbol]
  # @param validation_logic [Block]
  # @return [void]
  #
  # @see Qonfig::Validation::Building::PredefinedBuilder
  #
  # @api public
  # @since 0.20.0
  def define_validator(name, &validation_logic)
    Qonfig::Validation::Building::PredefinedBuilder.build(
      name, validation_logic, predefined_validators
    )
  end

  # @param key [Symbol, String]
  # @param initial_value [Object]
  # @param nested_settings [Proc]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::AddNestedOption
  # @see Qonfig::Commands::Definition::AddOption
  #
  # @api public
  # @since 0.1.0
  def setting(key, initial_value = nil, &nested_settings)
    if block_given?
      definition_commands << Qonfig::Commands::Definition::AddNestedOption.new(key, nested_settings)
    else
      definition_commands << Qonfig::Commands::Definition::AddOption.new(key, initial_value)
    end
  end
  # @param key [Symbol, String]
  # @param initial_value [Object]
  # @param nested_settings [Proc]
  # @return [void]
  #
  # @see Qonfig::Comamnds::Definition::ReDefineOption
  #
  # @api public
  # @since 0.20.0
  def re_setting(key, initial_value = nil, &nested_settings)
    definition_commands << Qonfig::Commands::Definition::ReDefineOption.new(
      key, initial_value, nested_settings
    )
  end
end
