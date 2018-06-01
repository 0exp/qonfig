# frozen_string_literal: true

module Qonfig
  # @api private
  # @since 0.1.0
  module DSL
    class << self
      # @param child_klass [Qonfig::DataSet]
      # @return [void]
      #
      # @api private
      # @since 0.1.0
      def extended(child_klass)
        child_klass.instance_variable_set(:@commands, Qonfig::CommandSet.new)

        class << child_klass
          def inherited(child_klass)
            child_klass.instance_variable_set(:@commands, Qonfig::CommandSet.new)
            child_klass.commands.concat(commands)
          end
        end
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

    # @param data_set_klass [Class{Qonfig::DataSet}]
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
    # @return [void]
    #
    # @see Qonfig::Commands::LoadFromYAML
    #
    # @api public
    # @since 0.2.0
    def load_from_yaml(file_path)
      commands << Qonfig::Commands::LoadFromYAML.new(file_path)
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

    # @return [void]
    #
    # @see Qonfig::Commands::LoadFromENV
    #
    # @api public
    # @since 0.2.0
    def load_from_env(convert_values: false)
      commands << Qonfig::Commands::LoadFromENV.new(convert_values: convert_values)
    end
  end
end
