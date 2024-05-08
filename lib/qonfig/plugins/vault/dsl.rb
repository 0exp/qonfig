# frozen_string_literal: true

# @api private
# @since 0.25.0
# @version 0.29.0
module Qonfig::DSL
  # @param path [String, Pathname]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromVault
  #
  # @api public
  # @since 0.25.0
  # @version 0.29.0
  def load_from_vault(path, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::LoadFromVault.new(
      path, strict: strict, replace_on_merge: replace_on_merge
    )
  end

  # @param path [String, Pathname]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeVault
  #
  # @api public
  # @since 0.25.0
  # @version 0.29.0
  def expose_vault(path, via:, env:, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::ExposeVault.new(
      path, via: via, env: env, strict: strict, replace_on_merge: replace_on_merge
    )
  end
end
