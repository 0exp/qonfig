# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Loaders::Vault < Qonfig::Loaders::Basic
  # @return [Binding]
  #
  # @api private
  # @since 0.25.0
  # @version 0.27.0
  VAULT_EXPR_EVAL_SCOPE = BasicObject.new.__binding__.tap do |binding|
    Object.new.method(:freeze).unbind.bind_call(binding.receiver)
  end

  class << self
    # @param path [String, Pathname]
    # @option fail_on_unexist [Boolean]
    # @option version [String, Integer]
    # @return [Object]
    #
    # @raise [Qonfig::FileNotFoundError]
    #
    # @api private
    # @since 0.25.0
    def load_file(path, fail_on_unexist: true, transform_values: true, version: nil, use_kv: true)
      data = load_data(path, version, use_kv)
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
    # @since 0.26.0
    def load_data(file_path, version, use_kv)
      response = ::Vault.with_retries(::Vault::HTTPError) do
        if use_kv
          mount_path, secret_path = file_path.to_s.split(::File::Separator, 2)
          ::Vault.kv(mount_path).read(secret_path, version)
        else
          ::Vault.logical.read(file_path.to_s)
        end
      end

      response&.data
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
