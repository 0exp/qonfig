# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Plugins::Vault < Qonfig::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.25.0
    def install!
      raise(
        Qonfig::UnresolvedPluginDependencyError,
        '::Vault does not exist or "vault" gem is not loaded'
      ) unless const_defined?('::Vault')

      require_relative 'vault/errors'
      require_relative 'vault/loaders/vault'
      require_relative 'vault/commands/definition/load_from_vault'
      require_relative 'vault/commands/definition/expose_vault'
      require_relative 'vault/dsl'

      define_resolvers!
    end

    private

    # @return [void]
    #
    # @since 0.25.1
    # @api private
    def define_resolvers!
      ::Qonfig.define_resolver(:vault) do |file_path, **options|
        *vault_path, file_name = file_path.split(File::SEPARATOR)
        vault_path = vault_path.join(File::SEPARATOR)
        files = Qonfig::Loaders::Vault
          .load_file(vault_path, **options, transform_values: false)
        result = files[file_name.to_sym]
        if result == nil
          raise Qonfig::FileNotFoundError, "Can't load file with name #{file_name}"
        end
        result
      end
    end
  end
end
