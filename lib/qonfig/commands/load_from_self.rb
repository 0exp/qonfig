# frozen_string_literal: true

module Qonfig
  class Commands
    # @api private
    # @since 0.2.0
    class LoadFromSelf < Base
      # @return [String]
      #
      # @api private
      # @since 0.2.0
      attr_reader :self_data

      # @param self_data [String]
      #
      # @api private
      # @sicne 0.2.0
      def initialize(self_data)
        @self_data = self_data
      end

      # @param settings [Qonfig::Settings]
      # @return [void]
      #
      # @api private
      # @since 0.2.0
      def call(settings)
        # TODO: implement
      end
    end
  end
end
