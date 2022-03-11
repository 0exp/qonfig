# frozen_string_literal: true

# @api private
# @since 0.2.0
# rubocop:disable Style/StaticClass
class Qonfig::Loaders::Basic
  class << self
    # @param data [String]
    # @return [void]
    #
    # @api private
    # @since 0.5.0
    def load(data)
      nil # NOTE: consciously return nil (for clarity)
    end

    # @return [void]
    #
    # @api private
    # @since 0.5.0
    def load_empty_data
      nil # NOTE: consciously return nil (for clarity)
    end

    # @param file_path [String, Pathname]
    # @option fail_on_unexist [Boolean]
    # @return [Object]
    #
    # @raise [Qonfig::FileNotFoundError]
    #
    # @api private
    # @since 0.5.0
    def load_file(file_path, fail_on_unexist: true, **options)
      data = Qonfig::FileDataResolving::Resolver.resolve!(file_path, **options)
      load(data)
    rescue Qonfig::FileNotFoundError
      fail_on_unexist ? raise : load_empty_data
    end
  end
end
# rubocop:enable Style/StaticClass
