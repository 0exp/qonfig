# frozen_string_literal: true

module Qonfig
  module Loaders
    # @api private
    # @sicne 0.5.0
    module Basic
      # @param data [String]
      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def load(data)
        nil
      end

      # @return [void]
      #
      # @api private
      # @since 0.5.0
      def load_empty_data
        nil
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
        fail_on_unexist ? (raise Qonfig::FileNotFoundError, error.message) : load_empty_data
      end
    end
  end
end
