# frozen_string_literal: true

# @api private
# @since 0.12.0
module Qonfig::DSL
  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromTOML
  #
  # @api public
  # @since 0.12.0
  # @version 0.20.0
  def load_from_toml(file_path, strict: true)
    definition_commands << Qonfig::Commands::Definition::LoadFromTOML.new(
      file_path, strict: strict
    )
  end

  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeTOML
  #
  # @api public
  # @since 0.12.0
  # @version 0.20.0
  def expose_toml(file_path, strict: true, via:, env:)
    definition_commands << Qonfig::Commands::Definition::ExposeTOML.new(
      file_path, strict: strict, via: via, env: env
    )
  end
end
