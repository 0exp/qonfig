# frozen_string_literal: true

# @api private
# @since 0.2.0
class Qonfig::Loaders::YAML < Qonfig::Loaders::Basic
  class << self
    # @param data [String]
    # @return [Object]
    #
    # @raise [Qonfig::YAMLLoaderParseError]
    #
    # @api private
    # @since 0.2.0
    # @version 0.27.0
    def load(data)
      yaml = ERB.new(data).result
      ::YAML.respond_to?(:unsafe_load) ? ::YAML.unsafe_load(yaml) : ::YAML.load(yaml)
    rescue ::YAML::Exception => error
      raise(
        Qonfig::YAMLLoaderParseError.new(
          error.file,
          error.line,
          error.column,
          error.offset,
          error.problem,
          error.context
        ).tap { |exception| exception.set_backtrace(error.backtrace) }
      )
    end

    # @return [Object]
    #
    # @api private
    # @since 0.5.0
    def load_empty_data
      load('{}')
    end
  end
end
