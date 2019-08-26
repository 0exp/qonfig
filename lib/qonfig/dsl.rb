# frozen_string_literal: true

# @api private
# @since 0.1.0
module Qonfig::DSL
  class << self
    # @param child_klass [Qonfig::DataSet]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def extended(child_klass)
      child_klass.instance_variable_set(:@commands, Qonfig::CommandSet.new)

      child_klass.singleton_class.prepend(Module.new do
        def inherited(child_klass)
          child_klass.instance_variable_set(:@commands, Qonfig::CommandSet.new)
          child_klass.commands.concat(commands)
          super
        end
      end)
    end
  end

  # @return [Qonfig::CommandSet]
  #
  # @api private
  # @since 0.1.0
  def commands
    @commands
  end

  # @param key [Symbol, String]
  # @param initial_value [Object]
  # @param nested_settings [Proc]
  # @return [void]
  #
  # @see Qonfig::Commands::AddNestedOption
  # @see Qonfig::Commands::AddOption
  #
  # @api public
  # @since 0.1.0
  def setting(key, initial_value = nil, &nested_settings)
    if block_given?
      commands << Qonfig::Commands::AddNestedOption.new(key, nested_settings)
    else
      commands << Qonfig::Commands::AddOption.new(key, initial_value)
    end
  end

  # @param data_set_klass [Class<Qonfig::DataSet>]
  # @return [void]
  #
  # @see Qonfig::Comamnds::Compose
  #
  # @api private
  # @sine 0.1.0
  def compose(data_set_klass)
    commands << Qonfig::Commands::Compose.new(data_set_klass)
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::LoadFromYAML
  #
  # @api public
  # @since 0.2.0
  def load_from_yaml(file_path, strict: true)
    commands << Qonfig::Commands::LoadFromYAML.new(file_path, strict: strict)
  end

  # @return [void]
  #
  # @see Qonfig::Commands::LoadFromSelf
  #
  # @api public
  # @since 0.2.0
  def load_from_self
    caller_location = caller(1, 1).first
    commands << Qonfig::Commands::LoadFromSelf.new(caller_location)
  end

  # @option convert_values [Boolean]
  # @option prefix [NilClass, String, Regexp]
  # @return [void]
  #
  # @see Qonfig::Commands::LoadFromENV
  #
  # @api public
  # @since 0.2.0
  def load_from_env(convert_values: false, prefix: nil, trim_prefix: false)
    commands << Qonfig::Commands::LoadFromENV.new(
      convert_values: convert_values,
      prefix: prefix,
      trim_prefix: trim_prefix
    )
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @return [void]
  #
  # @api public
  # @since 0.5.0
  def load_from_json(file_path, strict: true)
    commands << Qonfig::Commands::LoadFromJSON.new(file_path, strict: strict)
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @api public
  # @since 0.7.0
  def expose_yaml(file_path, strict: true, via:, env:)
    commands << Qonfig::Commands::ExposeYAML.new(file_path, strict: strict, via: via, env: env)
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @api public
  # @since 0.14.0
  def expose_json(file_path, strict: true, via:, env:)
    commands << Qonfig::Commands::ExposeJSON.new(file_path, strict: strict, via: via, env: env)
  end

  # @option env [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Commands::LoadFromSelf
  #
  # @api public
  # @since 0.14.0
  def expose_self(env:)
    caller_location = caller(1, 1).first
    commands << Qonfig::Commands::ExposeSelf.new(caller_location, env: env)
  end
end
