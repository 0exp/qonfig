# frozen_string_literal: true

# @api private
# @since 0.5.0
class Qonfig::Loaders::JSON < Qonfig::Loaders::Basic
  class << self
    # @param data [String]
    # @return [Object]
    #
    # @api private
    # @since 0.5.0
    def load(data)
      ::JSON.parse(data, max_nesting: false, allow_nan: true)
    rescue ::JSON::ParserError => error
      raise(
        Qonfig::JSONLoaderParseError.new(error.message).tap do |exception|
          exception.set_backtrace(error.backtrace)
        end
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
