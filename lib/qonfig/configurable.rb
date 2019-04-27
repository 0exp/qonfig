# frozen_string_literal: true

# @api public
# @since 0.2.0
module Qonfig::Configurable
  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.2.0
    def included(base_klass)
      base_klass.instance_variable_set(:@__qonfig_access_lock__, Mutex.new)
      base_klass.instance_variable_set(:@__qonfig_definition_lock__, Mutex.new)
      base_klass.instance_variable_set(:@__qonfig_config_klass__, Class.new(Qonfig::DataSet))
      base_klass.instance_variable_set(:@__qonfig_config__, nil)

      base_klass.extend(ClassMethods)
      base_klass.include(InstanceMethods)
      base_klass.singleton_class.prepend(ClassInheritance)

      super
    end
  end

  # @api private
  # @since 0.2.0
  module ClassInheritance
    # @param child_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.2.0
    def inherited(child_klass)
      inherited_config_klass = Class.new(@__qonfig_config_klass__)

      child_klass.instance_variable_set(:@__qonfig_definition_lock__, Mutex.new)
      child_klass.instance_variable_set(:@__qonfig_access_lock__, Mutex.new)
      child_klass.instance_variable_set(:@__qonfig_config_klass__, inherited_config_klass)
      child_klass.instance_variable_set(:@__qonfig_config__, nil)

      super
    end
  end

  # @api private
  # @since 0.2.0
  module ClassMethods
    # @param block [Proc]
    # @return [void]
    #
    # @api public
    # @since 0.2.0
    def configuration(&block)
      @__qonfig_definition_lock__.synchronize do
        @__qonfig_config_klass__.instance_eval(&block) if block_given?
      end
    end

    # @param options_map [Hash]
    # @param block [Proc]
    # @return [void]
    #
    # @api public
    # @since 0.2.0
    def configure(options_map = {}, &block)
      @__qonfig_access_lock__.synchronize do
        config.configure(options_map, &block)
      end
    end

    # @return [Qonfig::DataSet]
    #
    # @api public
    # @since 0.2.0
    def config
      @__qonfig_definition_lock__.synchronize do
        @__qonfig_config__ ||= @__qonfig_config_klass__.new
      end
    end
  end

  # @api private
  # @since 0.2.0
  module InstanceMethods
    # @return [Qonfig::DataSet]
    #
    # @api public
    # @since 0.2.0
    def config
      self.class.instance_variable_get(:@__qonfig_definition_lock__).synchronize do
        @__qonfig_config__ ||= self.class.instance_variable_get(:@__qonfig_config_klass__).new
      end
    end

    # @return [Qonfig::DataSet]
    #
    # @api public
    # @since 0.6.0
    def shared_config
      self.class.config
    end

    # @param options_map [Hash]
    # @param block [Proc]
    # @return [void]
    #
    # @api public
    # @since 0.2.0
    def configure(options_map = {}, &block)
      self.class.instance_variable_get(:@__qonfig_access_lock__).synchronize do
        config.configure(options_map, &block)
      end
    end
  end
end
