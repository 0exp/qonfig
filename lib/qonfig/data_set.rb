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

    # @param configurations [Proc]
    #
    # @api public
    # @since 0.1.0
    def initialize(&configurations)
      load!(&configurations)
    end

    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def freeze!
      settings.__freeze__
    end

    # @param configurations [Proc]
    # @return [void]
    #
    # @api public
    # @since 0.2.0
    def load!(&configurations)
      @settings = build_settings
      configure(&configurations) if block_given?
    end
    alias_method :reload!, :load!

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

    private

    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.2.0
    def build_settings
      Qonfig::SettingsBuilder.build(self.class.commands)
    end
  end
end
