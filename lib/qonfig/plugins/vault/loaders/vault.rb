# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Loaders::Vault < Qonfig::Loaders::Basic
  EVAL_CONTEXT = BasicObject.new.__binding__

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
      result = data || empty_data
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

    # @return [Object]
    #
    # @api private
    # @since 0.25.0
    def deep_transform_values(obj)
      return obj unless obj.is_a?(Hash)

      obj.transform_values do |value|
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
      parsed_expr = ERB.new(vault_expr).result
      EVAL_CONTEXT.eval(parsed_expr)
    rescue StandardError, ScriptError
      parsed_expr
    end
  end
end
