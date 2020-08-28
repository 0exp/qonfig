# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Loaders::Vault < Qonfig::Loaders::Basic
  class << self
    # @param path [String, Pathname]
    # @option fail_on_unexist [Boolean]
    # @return [Object]
    #
    # @raise [Qonfig::FileNotFoundError]
    #
    # @api private
    # @since 0.25.0
    def load_file(path, fail_on_unexist: true)
      data = Vault.with_retries(Vault::HTTPError) do
        Vault.logical.read(path.to_s)&.data&.dig(:data)
      end
      raise Qonfig::FileNotFoundError, "Path #{path} not exist" if data.nil? && fail_on_unexist
      data || empty_data
    rescue Vault::VaultError => error
      raise(Qonfig::VaultLoaderError.new(error.message).tap do |exception|
        exception.set_backtrace(error.backtrace)
      end)
    end

    # @return [Hash]
    #
    # @api private
    # @since 0.25.0
    def empty_data
      {}
    end
  end
end
