# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Loaders::Vault < Qonfig::Loaders::Basic
  # @return [Binding]
  #
  # @api private
  # @since 0.25.0
  VAULT_EXPR_EVAL_SCOPE = BasicObject.new.__binding__.tap do |binding|
    Object.new.method(:freeze).unbind.bind(binding.receiver).call
  end

  class << self
    # @param path [String, Pathname]
    # @option fail_on_unexist [Boolean]
    # @return [Object]
    #
    # @raise [Qonfig::FileNotFoundError]
    #
    # @api private
    # @since 0.25.0
    def load_file(path, fail_on_unexist: true, transform_values: true, version: nil)
      data = load_data(path, version)
      raise Qonfig::FileNotFoundError, "Path #{path} not exist" if data == nil && fail_on_unexist
      result = data || empty_data
      return result unless transform_values

      deep_transform_values(result)
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

    private

    # @param file_path [String]
    # @param version [Integer]
    # @return [Object]
    #
    # @api private
    # @since 0.25.1
    def load_data(file_path, version)
      response = ::Vault.with_retries(::Vault::HTTPError) do
        if version == nil
          ::Vault.logical.read(file_path.to_s)
        else
          mount_path, secret_path = file_path.to_s.split(::File::Separator, 2)
          ::Vault.kv(mount_path).read(secret_path, version)
        end
      end

      response&.data&.dig(:data)
    end

    # @param vault_data [Hash<Object,Object>]
    # @return [Object]
    #
    # @api private
    # @since 0.25.0
    def deep_transform_values(vault_data)
      return vault_data unless vault_data.is_a?(Hash)

      vault_data.transform_values do |value|
        next safely_evaluate(value) if value.is_a?(String)

        deep_transform_values(value)
      end
    end

    # @param vault_expr [String]
    # @return [Object]
    #
    # @api private
    # @since 0.25.0
    def safely_evaluate(vault_expr)
      parsed_expr = ::ERB.new(vault_expr).result
      VAULT_EXPR_EVAL_SCOPE.eval(parsed_expr)
    rescue StandardError, ScriptError
      parsed_expr
    end
  end
end
