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

    # @param key [String,Symbol]
    # @param initial_value [Object]
    # @param nested_settings [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def setting(key, initial_value = nil, &nested_settings)
      unless key.is_a?(Symbol) || key.is_a?(String)
        raise Qonfig::ArgumentError, 'Setting key should be a symbol or a string!'
      end

      if block_given?
        commands << Qonfig::Commands::AddNestedOption.new(key, nested_settings)
      else
        commands << Qonfig::Commands::AddOption.new(key, initial_value)
      end
    end

    # @param data_set_klass [Class{Qonfig::DataSet}]
    # @return [void]
    #
    # @api private
    # @sine 0.1.0
    def compose(data_set_klass)
      commands << Qonfig::Commands::Compose.new(data_set_klass)
    end
  end
end
