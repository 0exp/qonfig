# frozen_string_literal: true

# @api private
# @since 0.12.0
module Qonfig::DSL
  # @param file_path [String]
  # @option strict [Boolean]
  # @return [void]
  #
  # @api public
  # @since 0.12.0
  def load_from_toml(file_path, strict: true)
    commands << Qonfig::Commands::LoadFromTOML.new(file_path, strict: strict)
  end

  # @param file_path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [Symbol, String]
  # @return [void]
  #
  # @api public
  # @since 0.12.0
  def expose_toml(file_path, strict: true, via:, env:)
    commands << Qonfig::Commands::ExposeTOML.new(file_path, strict: strict, via: via, env: env)
  end
end
