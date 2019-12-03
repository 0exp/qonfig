# frozen_string_literal: true

# @api private
# @since 0.1.0
# @version 0.20.0
module Qonfig::DSL # rubocop:disable Metrics/ModuleLength
  class << self
    # @param child_klass [Qonfig::DataSet]
    # @return [void]
    #
    # @see Qonfig::DataSet::ClassBuilder
    #
    # @api private
    # @since 0.1.0
    # @version 0.20.0
    # rubocop:disable Metrics/LineLength, Metrics/AbcSize
    def extended(child_klass)
      child_klass.instance_variable_set(:@definition_commands, Qonfig::CommandSet.new)
      child_klass.instance_variable_set(:@instance_commands, Qonfig::CommandSet.new)
      child_klass.instance_variable_set(:@predefined_validators, Qonfig::Validation::Collections::PredefinedRegistry.new)
      child_klass.instance_variable_set(:@validators, Qonfig::Validation::Collections::InstanceCollection.new)

      child_klass.singleton_class.prepend(Module.new do
        def inherited(child_klass)
          child_klass.instance_variable_set(:@definition_commands, Qonfig::CommandSet.new)
          child_klass.instance_variable_set(:@instance_commands, Qonfig::CommandSet.new)
          child_klass.instance_variable_set(:@predefined_validators, Qonfig::Validation::Collections::PredefinedRegistry.new)
          child_klass.instance_variable_set(:@validators, Qonfig::Validation::Collections::InstanceCollection.new)
          Qonfig::DataSet::ClassBuilder.inherit(base_klass: self, child_klass: child_klass)
          super
        end
      end)
    end
    # rubocop:enable Metrics/LineLength, Metrics/AbcSize
  end

  # @return [Qonfig::CommandSet]
  #
  # @api private
  # @since 0.17.0
  def definition_commands
    @definition_commands
  end

  # @return [Qonfig::CommandSet]
  #
  # @api private
  # @since 0.17.0
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

  # @param data_set_klass [Class<Qonfig::DataSet>]
  # @return [void]
  #
  # @see Qonfig::Comamnds::Definition::Compose
  #
  # @api private
  # @sine 0.1.0
  def compose(data_set_klass)
    definition_commands << Qonfig::Commands::Definition::Compose.new(data_set_klass)
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromYAML
  #
  # @api public
  # @since 0.2.0
  def load_from_yaml(file_path, strict: true)
    definition_commands << Qonfig::Commands::Definition::LoadFromYAML.new(
      file_path, strict: strict
    )
  end

  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromSelf
  #
  # @api public
  # @since 0.2.0
  def load_from_self(format: :yaml) # TODO: resolve format dynamically (:dynamic instead of :yaml)
    caller_location = caller(1, 1).first

    definition_commands << Qonfig::Commands::Definition::LoadFromSelf.new(
      caller_location, format: format
    )
  end

  # @option convert_values [Boolean]
  # @option prefix [NilClass, String, Regexp]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromENV
  #
  # @api public
  # @since 0.2.0
  def load_from_env(convert_values: false, prefix: nil, trim_prefix: false)
    definition_commands << Qonfig::Commands::Definition::LoadFromENV.new(
      convert_values: convert_values,
      prefix: prefix,
      trim_prefix: trim_prefix
    )
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromJSON
  #
  # @api public
  # @since 0.5.0
  def load_from_json(file_path, strict: true)
    definition_commands << Qonfig::Commands::Definition::LoadFromJSON.new(file_path, strict: strict)
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeYAML
  #
  # @api public
  # @since 0.7.0
  def expose_yaml(file_path, strict: true, via:, env:)
    definition_commands << Qonfig::Commands::Definition::ExposeYAML.new(
      file_path, strict: strict, via: via, env: env
    )
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeJSON
  #
  # @api public
  # @since 0.14.0
  def expose_json(file_path, strict: true, via:, env:)
    definition_commands << Qonfig::Commands::Definition::ExposeJSON.new(
      file_path, strict: strict, via: via, env: env
    )
  end

  # @option env [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeSelf
  #
  # @api public
  # @since 0.14.0
  def expose_self(env:, format: :yaml)
    caller_location = caller(1, 1).first

    definition_commands << Qonfig::Commands::Definition::ExposeSelf.new(
      caller_location, env: env, format: format
    )
  end

  # @param file_path [String]
  # @option format [String, Symbol]
  # @option strict [Boolean]
  # @option expose [NilClass, String, Symbol] Environment key
  # @return [void]
  #
  # @see Qonfig::Commands::Instantiation::ValuesFile
  #
  # @api public
  # @since 0.17.0
  def values_file(file_path, format: :dynamic, strict: false, expose: nil)
    caller_location = caller(1, 1).first

    instance_commands << Qonfig::Commands::Instantiation::ValuesFile.new(
      file_path, caller_location, format: format, strict: strict, expose: expose
    )
  end

  # @return [void]
  #
  # @see Qonfig::Commands::Instantiation::FreezeState
  #
  # @api public
  # @since 0.19.0
  def freeze_state!
    instance_commands << Qonfig::Commands::Instantiation::FreezeState.new
  end
end
