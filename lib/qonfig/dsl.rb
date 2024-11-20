# frozen_string_literal: true

# @api private
# @since 0.1.0
# @version 0.29.0
module Qonfig::DSL # rubocop:disable Metrics/ModuleLength
  require_relative 'dsl/inheritance'

  class << self
    # @param child_klass [Class<Qonfig::DataSet>]
    # @return [void]
    #
    # @see Qonfig::DataSet::ClassBuilder
    #
    # @api private
    # @since 0.1.0
    # @version 0.20.0
    # rubocop:disable Layout/LineLength, Metrics/AbcSize
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
          Qonfig::DSL::Inheritance.inherit(base: self, child: child_klass)
          super
        end
      end)
    end
    # rubocop:enable Layout/LineLength, Metrics/AbcSize
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

  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromYAML
  #
  # @api public
  # @since 0.2.0
  # @version 0.29.0
  def load_from_yaml(file_path, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::LoadFromYAML.new(
      file_path, strict: strict, replace_on_merge: replace_on_merge
    )
  end

  # @option format [Symbol, String]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromSelf
  #
  # @api public
  # @since 0.2.0
  # @version 0.29.0
  def load_from_self(format: :dynamic, replace_on_merge: false)
    caller_location = ::Kernel.caller(1, 1).first

    definition_commands << Qonfig::Commands::Definition::LoadFromSelf.new(
      caller_location, format: format, replace_on_merge: replace_on_merge
    )
  end

  # @option convert_values [Boolean]
  # @option prefix [NilClass, String, Regexp]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromENV
  #
  # @api public
  # @since 0.2.0
  # @version 0.29.0
  def load_from_env(convert_values: false, prefix: nil, trim_prefix: false)
    definition_commands << Qonfig::Commands::Definition::LoadFromENV.new(
      convert_values: convert_values,
      prefix: prefix,
      trim_prefix: trim_prefix
    )
  end

  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromJSON
  #
  # @api public
  # @since 0.5.0
  # @version 0.29.0
  def load_from_json(file_path, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::LoadFromJSON.new(
      file_path, strict: strict, replace_on_merge: replace_on_merge
    )
  end

  # @option file_path [String, Pathname]
  # @option strict [Boolean]
  # @option format [Symbol, String]
  # @return [void]
  #
  # @api public
  # @version 0.24.0
  def load_from_file(file_path, strict: true, format: :dynamic)
    definition_commands << Qonfig::Commands::Definition::LoadFroMfile.new(
      file_path, strict: strict, format: format
    )
  end

  # @param file_path [String, Pathname]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeYAML
  #
  # @api public
  # @since 0.7.0
  # @version 0.29.0
  def expose_yaml(file_path, via:, env:, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::ExposeYAML.new(
      file_path, via: via, env: env, strict: strict, replace_on_merge: replace_on_merge
    )
  end

  # @param file_path [String, Pathname]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeJSON
  #
  # @api public
  # @since 0.14.0
  # @version 0.29.0
  def expose_json(file_path, via:, env:, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::ExposeJSON.new(
      file_path, via: via, env: env, strict: strict, replace_on_merge: replace_on_merge
    )
  end

  # @option env [Symbol, String]
  # @option format [Symbol, String]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeSelf
  #
  # @api public
  # @since 0.14.0
  # @version 0.29.0
  def expose_self(env:, format: :dynamic, replace_on_merge: false)
    caller_location = ::Kernel.caller(1, 1).first

    definition_commands << Qonfig::Commands::Definition::ExposeSelf.new(
      caller_location, env: env, format: format, replace_on_merge: replace_on_merge
    )
  end

  # @option [String, Pathname]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @option strict [Boolean]
  # @option format [Symbol, String]
  # @return [void]
  #
  # @api public
  # @version 0.24.0
  def expose_file(file_path, via:, env:, strict: true, format: :dynamic)
    definition_commands << Qonfig::Commands::Definition::ExposeFile.new(
      file_path, strict: strict, via: via, env: env, format: format
    )
  end

  # @param file_path [String, Pathname]
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
    caller_location = ::Kernel.caller(1, 1).first

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
