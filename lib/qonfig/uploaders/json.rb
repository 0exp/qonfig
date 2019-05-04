# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::JSON < Qonfig::Uploaders::File
  # @return [Hash<Symbol,Any>]
  #
  # @api private
  # @since 0.11.0
  DEFAULT_OPTIONS = {
    indent: ' ',
    space: ' ',
    object_nl: "\n",
  }.freeze

  class << self
    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol,Any>]
    # @param value_processor [Block]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(settings, options, &value_processor)
      settings_hash =
        if block_given?
          settings.__to_hash__(transform_value: value_processor)
        else
          settings.__to_hash__
        end

      ::JSON.generate(settings_hash, options)
    end
  end
end
