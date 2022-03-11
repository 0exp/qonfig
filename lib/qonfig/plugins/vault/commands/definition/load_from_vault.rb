# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Commands::Definition::LoadFromVault < Qonfig::Commands::Base
  # @since 0.25.0
  self.inheritable = true

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.25.0
  attr_reader :path

  # @return [Boolean]
  #
  # @api private
  # @since 0.25.0
  attr_reader :strict

  # @return [Hash]
  #
  # @api private
  # @since 0.26.0
  attr_reader :file_resolve_options

  # @param path [String]
  # @option strict [Boolean]
  # @option file_resolve_options [Hash]
  #
  # @api private
  # @since 0.25.0
  def initialize(path, strict: true, file_resolve_options: {})
    @path = path
    @strict = strict
    @file_resolve_options = file_resolve_options
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.25.0
  def call(_data_set, settings)
    vault_data = Qonfig::Loaders::Vault
      .load_file(path, fail_on_unexist: strict, **file_resolve_options)
    vault_based_settings = build_data_set_klass(vault_data).new.settings
    settings.__append_settings__(vault_based_settings)
  end

  private

  # @param toml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.25.0
  def build_data_set_klass(toml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(toml_data)
  end
end
