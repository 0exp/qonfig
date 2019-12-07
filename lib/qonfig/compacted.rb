# frozen_string_literal: true

# @api public
# @since 0.21.0
class Qonfig::Compacted < BasicObject
  require_relative 'compacted/constructor'

  # @since 0.21.0
  extend ::Qonfig::DSL

  # @param init_from [NilClass, Qonfig::DataSet]
  # @return [void]
  #
  # @see Qonfig::Compacted::Constructor.construct
  #
  # @api public
  # @since 0.21.0
  def initialize(init_from = ::Qonfig::Compacted::Constructor::NO_NITIAL_DATA_SET)
    ::Qonfig::Compacted::Constructor.construct(self, init_from)
  end

  # @param key [String, Symbol]
  # @return [Object]
  #
  # @api public
  # @since 0.21.0
  def [](key)
    @____data_set____[key]
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
    @____data_set____[key] = value
  end
end
