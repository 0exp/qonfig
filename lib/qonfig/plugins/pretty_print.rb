# frozen_string_literal: true

# @api private
# @since 0.17.0
class Qonfig::Plugins::PrettyPrint < Qonfig::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.17.0
    def load!
      require_relative 'pretty_print/mixin'
      require_relative 'pretty_print/data_set'
    end
  end
end
