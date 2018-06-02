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
      @__access_lock__ = Mutex.new
      @__definition_lock__ = Mutex.new

      thread_safe_definition { load!(&configurations) }
    end

    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def freeze!
      thread_safe_access { settings.__freeze__ }
    end

    # @return [void]
    #
    # @api public
    # @since 0.2.0
    def frozen?
      thread_safe_access { settings.__is_frozen__ }
    end

    # @param configurations [Proc]
    # @return [void]
    #
    # @raise [Qonfig::FrozenSettingsError]
    #
    # @api public
    # @since 0.2.0
    def reload!(&configurations)
      thread_safe_definition do
        raise Qonfig::FrozenSettingsError, 'Frozen config can not be reloaded' if frozen?
        load!(&configurations)
      end
    end

    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def configure
      thread_safe_access { yield(settings) if block_given? }
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def to_h
      thread_safe_access { settings.__to_hash__ }
    end
    alias_method :to_hash, :to_h

    # @param setting_key [String, Symbol]
    # @return [Object]
    #
    # @api public
    # @since 0.2.0
    def [](setting_key)
      thread_safe_access { settings[setting_key] }
    end

    # @param keys [Array<String, Symbol>]
    # @return [Object]
    #
    # @api public
    # @since 0.2.0
    def dig(*keys)
      thread_safe_access { settings.__dig__(*keys) }
    end

    # @return [void]
    #
    # @api public
    # @since 0.2.0
    def clear!
      thread_safe_access { settings.__clear__ }
    end

    private

    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.2.0
    def build_settings
      Qonfig::Settings::Builder.build(self.class.commands.dup)
    end

    # @param configurations [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.2.0
    def load!(&configurations)
      @settings = build_settings
      configure(&configurations) if block_given?
    end

    # @param instructions [Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def thread_safe_access(&instructions)
      @__access_lock__.synchronize(&instructions)
    end

    # @param instructions [Proc]
    # @return [Object]
    #
    # @api private
    # @since 0.2.0
    def thread_safe_definition(&instructions)
      @__definition_lock__.synchronize(&instructions)
    end
  end
end
