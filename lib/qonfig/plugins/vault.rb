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
      require_relative 'vault/commands/load_from_vault'
      require_relative 'vault/commands/expose_vault'
      require_relative 'vault/dsl'
    end
  end
end
