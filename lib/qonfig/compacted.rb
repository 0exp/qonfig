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
        Qonfig::ArgumentError,
        'Base class should be a type of Qonfig::DataSet or Qonfig::Compacted'
      ) unless base_config_klass <= Qonfig::Compacted

      Class.new(base_config_klass, &config_klass_definitions).new
    end

    # @param settings_map [Hash<Symbol|String,Any>]
    # @option init_from [NilClass, Qonfig::DataSet]
    # @param configurations [Block]
    # @return [Boolean]
    #
    # @api public
    # @since 0.21.0
    def valid_with?(
      settings_map = {},
      init_from: ::Qonfig::Compacted::Constructor::NO_NITIAL_DATA_SET,
      &configurations
    )
      new(settings_map, init_from: init_from, &configurations)
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

  # @param settings_map [Hash]
  # @option init_from [NilClass, Qonfig::DataSet]
  # @param configuration [Block]
  # @return [void]
  #
  # @see Qonfig::Compacted::Constructor.construct
  #
  # @api public
  # @since 0.21.0
  def initialize(
    settings_map = {},
    init_from: ::Qonfig::Compacted::Constructor::NO_NITIAL_DATA_SET,
    &configuration
  )
    ::Qonfig::Compacted::Constructor.construct(
      self, init_from, settings_map: settings_map, &configuration
    )
  end

  # @param key [String, Symbol]
  # @return [Object]
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
  # @raise [Qonfig::UnknownSettingError]
  # @raise [Qonfig::FrozenSettingsError]
  # @raise [Qonfig::AmbiguousSettingValueError]
  #
  # @api public
  # @since 0.21.0
  def []=(key, value)
    ____data_set____[key] = value
  end
end
