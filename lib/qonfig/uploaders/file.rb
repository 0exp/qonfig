# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::File < Qonfig::Uploaders::Base
  # @return [String]
  #
  # @api private
  # @since 0.11.0
  FILE_OPENING_MODE = 'w'

  # @return [String]
  #
  # @api private
  # @since 0.11.0
  EMPTY_SETTINGS_REPRESENTATION = ''

  # @return [Hash]
  #
  # @api private
  # @since 0.11.0
  DEFAULT_OPTIONS = {}.freeze

  class << self
    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol|String,Any>]
    # @param value_processor [Block]
    # @option path [String]
    # @return [void]
    #
    # @api private
    # @since 0.11.0
    def upload(settings, path:, options: self::DEFAULT_OPTIONS, &value_processor)
      ::File.open(path, FILE_OPENING_MODE) do |file_descriptor|
        settings_representation = represent_settings(settings, options, &value_processor)
        file_descriptor.write(settings_representation)
      end
    end

    private

    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol|String,Any>]
    # @param value_processor [Block]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(settings, options, &value_processor)
      # :nocov:
      EMPTY_SETTINGS_REPRESENTATION
      # :nocov:
    end
  end
end
