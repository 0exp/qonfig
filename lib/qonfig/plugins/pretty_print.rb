# frozen_string_literal: true

# @api private
# @since 0.19.0
class Qonfig::Plugins::PrettyPrint < Qonfig::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.19.0
    # @version 0.21.0
    def install!
      require_relative 'pretty_print/mixin'
      require_relative 'pretty_print/data_set'
      require_relative 'pretty_print/settings'
      require_relative 'pretty_print/compacted'
    end
  end
end
