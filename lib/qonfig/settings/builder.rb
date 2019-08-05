# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Settings::Builder
  class << self
    # @param commands [Qonfig::CommandSet]
    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings::Proxy]
    #
    # @api private
    # @since 0.2.0
    def build(commands, data_set)
      settings = Qonfig::Settings.new.tap do |settings|
        commands.each { |command| command.call(settings) }
      end

      Qonfig::Settings::ProxyAsBasicObject.new(settings, data_set)
    end
  end
end
