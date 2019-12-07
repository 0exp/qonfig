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
  # @api public
  # @since 0.21.0
  def initialize(init_from = Qonfig::Compacted::Constructor::NO_NITIAL_DATA_SET)
    ::Qonfig::Compacted::Constructor.construct(self, init_from)
  end
end
