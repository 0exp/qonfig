# frozen_string_literal: true

module Qonfig
  # @api private
  # @since 0.1.0
  module SettingsBuilder
    class << self
      # @param [Qonfig::CommandSet]
      # @return [Qonfig::Settings]
      #
      # @api private
      # @since 0.1.0
      def build(commands)
        Qonfig::Settings.new.tap do |settings|
          commands.each { |command| command.call(settings) }
        end
      end
    end
  end
end
