# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Loaders
  require_relative 'loaders/basic'
  require_relative 'loaders/json'
  require_relative 'loaders/yaml'
  require_relative 'loaders/end_data'

  class << self
    # @param format [String, Symbol]
    # @return [Module]
    #
    # @raise [Qonfig::UnsupportedLoaderFormatError]
    #
    # @api private
    # @since 0.15.0
    def resolve(format)
      case format.to_s
      when "yaml", "yml"
        Qonfig::Loaders::YAML
      when "json"
        Qonfig::Loaders::JSON
      else
        raise(Qonfig::UnsupportedLoaderFormatError, "<#{format}> format is not supported.")
      end
    end
    alias_method :[], :resolve
  end
end
