# frozen_string_literal: true

# @api public
# @since 0.21.0
class Qonfig::Compacted < BasicObject
  require_relative 'compacted/constructor'

  # @since 0.21.0
  extend ::Qonfig::DSL

  class << self
    # @param base_config_klass [Class<Qonfig::Compacted>]
    # @param config_klass_definitions [Block]
    # @return [Qonfig::Compacted]
    #
    # @api public
    # @since 0.21.0
    def build(base_config_klass = self, &config_klass_definitions)
      raise(
        ::Qonfig::ArgumentError,
        'Base class should be a type of Qonfig::Compacted'
      ) unless base_config_klass <= ::Qonfig::Compacted

      Class.new(base_config_klass, &config_klass_definitions).new
    end

    # @param data_set [Qonfig::DataSet]
    # @param configurations [Block]
    # @return [Qonfig::Compacted]
    #
    # @api public
    # @since 0.21.0
    def build_from(
      data_set = ::Qonfig::Compacted::Constructor::NO_INITIAL_DATA_SET,
      &configurations
    )
      compacted_config = allocate # NOTE: #tap does not exist on BasicObject :(
      ::Qonfig::Compacted::Constructor.construct(compacted_config, data_set, &configurations)
      compacted_config
    end

    # @param settings_map [Hash<Symbol|String,Any>]
    # @option init_from [NilClass, Qonfig::DataSet]
    # @param configurations [Block]
    # @return [Boolean]
    #
    # @api public
    # @since 0.21.0
    def valid_with?(settings_map = {}, &configurations)
      new(settings_map, &configurations)
      true
    rescue ::Qonfig::ValidationError
      false
    end
  end

  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.21.0
  attr_reader :____data_set____

  # @param settings_map [Hash<Symbol|String,Any>]
  # @param configuration [Block]
  # @return [void]
  #
  # @see Qonfig::Compacted::Constructor
  #
  # @api public
  # @since 0.21.0
  def initialize(settings_map = {}, &configuration)
    ::Qonfig::Compacted::Constructor.construct(
      self,
      ::Qonfig::Compacted::Constructor::NO_INITIAL_DATA_SET,
      settings_map: settings_map,
      &configuration
    )
  end

  # @param key [String, Symbol]
  # @return [Any]
  #
  # @api public
  # @since 0.21.0
  def [](key)
    ____data_set____[key]
  end

  # @param key [String, Symbol]
  # @param value [Any]
  # @return [void]
  #
  # @api public
  # @since 0.21.0
  def []=(key, value)
    ____data_set____[key] = value
  end
end
