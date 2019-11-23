# frozen_string_literal: true

# @api private
# @since 0.17.0
class Qonfig::Loaders::Dynamic < Qonfig::Loaders::Basic
  class << self
    # @param data [String]
    # @return [Object]
    #
    # @raise [Qonfig::DynamicLoaderParseError]
    #
    # @api private
    # @since 0.17.0
    def load(data)
      try_to_load_json_data(data)
    rescue Qonfig::JSONLoaderParseError
      begin
        try_to_load_yaml_data(data)
      rescue Qonfig::YAMLLoaderParseError
        raise Qonfig::DynamicLoaderParseError, 'File data has unknown format'
      end
    end

    # @return [Hash]
    #
    # @api private
    # @since 0.17.0
    def load_empty_data
      {}
    end

    private

    # @param data [String]
    # @return [Object]
    #
    # @api private
    # @since 0.17.0
    def try_to_load_yaml_data(data)
      Qonfig::Loaders::YAML.load(data)
    end

    # @param data [String]
    # @return [Object]
    #
    # @api private
    # @since 0.17.0
    def try_to_load_json_data(data)
      Qonfig::Loaders::JSON.load(data)
    end
  end
end
