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
        # @option fail_on_unexist [Boolean]
        # @return [Object]
        #
        # @raise [Qonfig::FileNotFoundError]
        #
        # @api private
        # @since 0.2.0
        def load_file(file_path, fail_on_unexist: true)
          load(::File.read(file_path))
        rescue Errno::ENOENT => error
          fail_on_unexist ? (raise Qonfig::FileNotFoundError, error.message) : load('{}')
        end
      end
    end
  end
end
