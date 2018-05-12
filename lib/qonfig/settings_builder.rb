# frozen_string_literal: true

# @api private
# @since 0.1.0
module Qonfig::SettingsBuilder
  class << self
    # @param definitions [Qonfig::Definitions]
    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.1.0
    def build(definitions)
      Qonfig::Settings.new.tap do |settings|
        definitions.each do |option|
          settings.define_setting(option.key, option.value)
        end
      end
    end
  end
end
