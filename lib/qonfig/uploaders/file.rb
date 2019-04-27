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

  class << self
    # @param settings [Qonfig::Settings]
    # @option path [String]
    # @return [void]
    #
    # @api private
    # @since 0.11.0
    def upload(settings, path:)
      ::File.open(path, FILE_OPENING_MODE) do |file_descriptor|
        settings_representation = represent_settings(settings)
        file_descriptor.write(settings_representation)
      end
    end

    private

    # @param settings [Qonfig::Settings]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(settings)
      EMPTY_SETTINGS_REPRESENTATION
    end
  end
end
