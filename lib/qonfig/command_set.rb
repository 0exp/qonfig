# frozen_string_literal: true

module Qonfig
  # @api private
  # @since 0.1.0
  class CommandSet
    # @return [Array<Qonfig::Commands::Base>]
    #
    # @api private
    # @since 0.1.0
    attr_reader :commands

    # @api private
    # @since 0.1.0
    def initialize
      @commands = []
    end

    # @param command [Qonfig::Commands::Base]
    # @return [void]
    #
    # @api private
    # @since 0.1.0
    def add_command(command)
      commands << command
    end
    alias_method :<<, :add_command

    # @param block [Proc]
    # @return [Enumerable]
    #
    # @api private
    # @since 0.1.0
    def each(&block)
      block_given? ? commands.each(&block) : commands.each
    end

    # @param command_set [Qonfig::CommandSet]
    # @return [Qonfig::CommandSet]
    #
    # @api private
    # @since 0.1.0
    def concat(command_set)
      commands.concat(command_set.commands)
    end
  end
end
