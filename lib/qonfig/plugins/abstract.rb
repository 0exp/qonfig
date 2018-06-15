# frozen_string_literal: true

module Qonfig
  module Plugins
    # @api private
    # @since 0.4.0
    class Base
      class << self
        # @return [void]
        #
        # @api private
        # @since 0.4.0
        def load!
          load_dependencies!
          load_code!
        end

        private

        # @retirn [void]
        #
        # @api private
        # @since 0.4.0
        def load_dependencies!
        end

        # @return [void]
        #
        # @api private
        # @since 0.4.0
        def load_code!
        end
      end
    end
  end
end
