# frozen_string_literal: true

# @api private
# @since 0.1.0
module Qonfig::SettingsBuilder
  class << self
    # @param definition_set [Qonfig::DefinitionSet]
    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.1.0
    def build(definition_set)
      Qonfig::Settings.new.tap do |settings|
        definition_set.each do |option|
          if option.value.is_a?(Qonfig::DataSet)
            settings.append_setting(
              key: option.key,
              value: option.value
            )
          else
            settings.define_setting(
              key: option.key,
              value: option.value
            )
          end
        end
      end
    end
  end
end
