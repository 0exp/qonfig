# frozen_string_literal: true

# @api private
# @since 0.25.0
module Qonfig::DSL
  # @param path [String, Pathname]
  # @option strict [Boolean]
  # @option **file_resolve_options [Hash]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromVault
  #
  # @api public
  # @since 0.25.0
  def load_from_vault(path, strict: true, **file_resolve_options)
    definition_commands << Qonfig::Commands::Definition::LoadFromVault.new(
      path, strict: strict, file_resolve_options: file_resolve_options
    )
  end

  # @param path [String, Pathname]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @option **resolve_options [Hash]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeVault
  #
  # @api public
  # @since 0.25.0
  def expose_vault(path, strict: true, via:, env:, **file_resolve_options)
    definition_commands << Qonfig::Commands::Definition::ExposeVault.new(
      path, strict: strict, via: via, env: env, file_resolve_options: file_resolve_options
    )
  end
end
