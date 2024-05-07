# frozen_string_literal: true

# @api private
# @since 0.12.0
# @version 0.29.0
module Qonfig::DSL
  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::LoadFromTOML
  #
  # @api public
  # @since 0.12.0
  # @version 0.29.0
  def load_from_toml(file_path, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::LoadFromTOML.new(
      file_path, strict: strict, replace_on_merge: replace_on_merge
    )
  end

  # @param file_path [String, Pathname]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  # @return [void]
  #
  # @see Qonfig::Commands::Definition::ExposeTOML
  #
  # @api public
  # @since 0.12.0
  # @version 0.29.0
  def expose_toml(file_path, via:, env:, strict: true, replace_on_merge: false)
    definition_commands << Qonfig::Commands::Definition::ExposeTOML.new(
      file_path, via: via, env: env, strict: strict, replace_on_merge: replace_on_merge
    )
  end
end
