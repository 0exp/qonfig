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
    def load(data)
      ::YAML.load(ERB.new(data).result)
    rescue ::Psych::SyntaxError => error
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
