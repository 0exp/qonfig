# frozen_string_literal: true

# @api private
# @since 0.25.0
module Qonfig::DSL
  # @param path [String, Pathname]
  # @option strict [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromVault
  #
  # @api public
  # @since 0.25.0
  def load_from_vault(path, strict: true)
    definition_commands << Qonfig::Commands::Definition::LoadFromVault.new(
      path, strict: strict
    )
  end

  # @param path [String, Pathname]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeVault
  #
  # @api public
  # @since 0.25.0
  def expose_vault(path, strict: true, via:, env:)
    definition_commands << Qonfig::Commands::Definition::ExposeVault.new(
      path, strict: strict, via: via, env: env
    )
  end
end
