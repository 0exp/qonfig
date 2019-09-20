# frozen_string_literal: true

# @api public
# @since 0.17.0
module Qonfig::Importing
  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.17.0
    def included(base_klass)
      base_klass.extend(DSL)
    end
  end

  # @api private
  # @since 0.17.0
  module DSL
  end
end
