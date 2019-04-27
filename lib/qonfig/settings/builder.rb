# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Settings::Builder
  class << self
    # @param commands [Qonfig::CommandSet]
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
