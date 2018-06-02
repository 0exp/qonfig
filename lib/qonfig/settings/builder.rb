# frozen_string_literal: true

module Qonfig
  class Settings
    # @api private
    # @since 0.2.0
    module Builder
      class << self
        # @param [Qonfig::CommandSet]
        # @return [Qonfig::Settings]
        #
        # @api private
        # @since 0.2.0
        def build(commands)
          Qonfig::Settings.new.tap do |settings|
            commands.each { |command| command.call(settings) }
          end
        end
      end
    end
  end
end
