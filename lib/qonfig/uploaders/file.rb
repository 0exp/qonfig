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
  EMPTY_DATA_SET_REPRESENTATION = ''

  class << self
    # @param data_set [Qonfig::DataSet]
    # @option path [String]
    # @return [void]
    #
    # @api private
    # @since 0.11.0
    def upload(data_set, path:)
      File.open(path, FILE_OPENING_MODE) do |file_descriptor|
        settings_representation = represent_settings(data_set)
        file_descriptor.write(settings_representation)
      end
    end

    private

    # @param data_set [Qonfig::DataSet]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(data_set)
      EMPTY_DATA_SET_REPRESENTATION
    end
  end
end
