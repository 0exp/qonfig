# frozen_string_literal: true

# @api private
# @since 0.12.0
class Qonfig::Commands::LoadFromTOML < Qonfig::Commands::Base
  # @return [String]
  #
  # @api private
  # @since 0.12.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.12.0
  attr_reader :strict

  # @param file_path [String]
  # @option strict [Boolean]
  #
  # @api private
  # @since 0.12.0
  def initialize(file_path, strict: true)
    @file_path = file_path
    @strict = strict
  end

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleTOMLStructureError]
  #
  # @api private
  # @since 0.12.0
  def call(settings)
    toml_data = Qonfig::Loaders::TOML.load_file(file_path, fail_on_unexist: strict)

    raise(
      Qonfig::IncompatibleTOMLStructureError,
      'TOML content should have a hash-like structure'
    ) unless toml_data.is_a?(Hash)

    toml_based_settings = build_data_set_class(toml_data).new.settings

    settings.__append_settings__(toml_based_settings)
  end

  private

  # @param toml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.12.0
  def build_data_set_class(toml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(toml_data)
  end
end
