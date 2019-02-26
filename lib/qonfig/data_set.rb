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

    # @param options_map [Hash]
    # @param configurations [Proc]
    #
    # @api public
    # @since 0.1.0
    def initialize(options_map = {}, &configurations)
      @__access_lock__ = Mutex.new
      @__definition_lock__ = Mutex.new

      thread_safe_definition { load!(options_map, &configurations) }
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

    # @param options_map [Hash]
    # @param configurations [Proc]
    # @return [void]
    #
    # @raise [Qonfig::FrozenSettingsError]
    #
    # @api public
    # @since 0.2.0
    def reload!(options_map = {}, &configurations)
      thread_safe_definition do
        raise Qonfig::FrozenSettingsError, 'Frozen config can not be reloaded' if frozen?
        load!(options_map, &configurations)
      end
    end

    # @param options_map [Hash]
    # @return [void]
    #
    # @api public
    # @since 0.1.0
    def configure(options_map = {})
      thread_safe_access do
        settings.__apply_values__(options_map)
        yield(settings) if block_given?
      end
    end

    # @return [Hash]
    #
    # @api public
    # @since 0.1.0
    def to_h
      thread_safe_access { settings.__to_hash__ }
    end
    alias_method :to_hash, :to_h

    # @param key [String, Symbol]
    # @return [Object]
    #
    # @api public
    # @since 0.2.0
    def [](key)
      thread_safe_access { settings[key] }
    end

    # @param keys [Array<String, Symbol>]
    # @return [Object]
    #
    # @api public
    # @since 0.2.0
    def dig(*keys)
      thread_safe_access { settings.__dig__(*keys) }
    end

    # @param keys [Array<String, Symbol>]
    # @return [Hash]
    #
    # @api public
    # @since 0.9.0
    def slice(*keys)
      thread_safe_access { settings.__slice__(*keys) }
    end

    # @param keys [Array<String, Symbol>]
    # @return [Hash,Any]
    #
    # @api public
    # @since 0.10.0
    def slice_value(*keys)
      thread_safe_access { settings.__slice_value__(*keys) }
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

    # @param options_map [Hash]
    # @param configurations [Proc]
    # @return [void]
    #
    # @api private
    # @since 0.2.0
    def load!(options_map = {}, &configurations)
      @settings = build_settings
      configure(options_map, &configurations)
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
