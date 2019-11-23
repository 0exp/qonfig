# frozen_string_literal: true

# @api public
# @since 0.18.0
module Qonfig::Imports
  require_relative 'imports/abstract'
  require_relative 'imports/direct_key'
  require_relative 'imports/mappings'
  require_relative 'imports/general'
  require_relative 'imports/dsl'
  require_relative 'imports/export'

  class << self
    # @param base_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.18.0
    def included(base_klass)
      base_klass.include(Qonfig::Imports::DSL)
    end
  end
end
