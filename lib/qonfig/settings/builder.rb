# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Settings::Builder
  class << self
    # @param commands [Qonfig::CommandSet]
    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.2.0
    def build(commands, data_set)
      Qonfig::Settings.new(build_callbacks(data_set)).tap do |settings|
        commands.each { |command| command.call(settings) }
      end
    end

    private

    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings::Callbacks]
    #
    # @api private
    # @since 0.13.0
    def build_callbacks(data_set)
      Qonfig::Settings::Callbacks.new.tap do |callbacks|
        # NOTE: validation callbacks
        callbacks.add { data_set.validate! }
      end
    end
  end
end
