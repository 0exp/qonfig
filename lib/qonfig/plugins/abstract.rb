# frozen_string_literal: true

module Qonfig
  module Plugins
    # @api private
    # @since 0.4.0
    class Abstract
      class << self
        # @return [void]
        #
        # @api private
        # @since 0.4.0
        def load!; end
      end
    end
  end
end
