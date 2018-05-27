# frozen_string_literal: true

module Qonfig
  module Loaders
    # @api private
    # @since 0.2.0
    module YAML
      class << self
        # @param data [String]
        # @return [Object]
        #
        # @api private
        # @since 0.2.0
        def load(data)
          ::YAML.load(ERB.new(data).result)
        end

        # @param file_path [String]
        # @return [Object]
        #
        # @api private
        # @since 0.2.0
        def load_file(file_path)
          load(::File.read(file_path))
        end
      end
    end
  end
end
