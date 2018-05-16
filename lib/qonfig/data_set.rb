# frozen_string_literal: true

module Qonfig
  # @api public
  # @since 0.1.0
  class DataSet
    # @since 0.1.0
    extend Qonfig::DSL

    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.1.0
    attr_reader :settings

    # @api public
    # @since 0.1.0
    def initialize
      @settings = Qonfig::SettingsBuilder.build(self.class.commands)
    end

    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def configure
      yield(settings) if block_given?
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def to_h
      settings.__to_hash__
    end
    alias_method :to_hash, :to_h
  end
end
