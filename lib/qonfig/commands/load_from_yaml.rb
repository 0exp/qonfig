# frozen_string_literal: true

# @api private
# @since 0.2.0
class Qonfig::Commands::LoadFromYAML < Qonfig::Commands::Base
  # @return [String]
  #
  # @api private
  # @since 0.2.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.2.0
  attr_reader :strict

  # @param file_path [String]
  # @option strict [Boolean]
  #
  # @api private
  # @since 0.2.0
  def initialize(file_path, strict: true)
    @file_path = file_path
    @strict = strict
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.2.0
  def call(data_set, settings)
    yaml_data = Qonfig::Loaders::YAML.load_file(file_path, fail_on_unexist: strict)

    raise(
      Qonfig::IncompatibleYAMLStructureError,
      'YAML content should have a hash-like structure'
    ) unless yaml_data.is_a?(Hash)

    yaml_based_settings = build_data_set_class(yaml_data).new.settings

    settings.__append_settings__(yaml_based_settings)
  end

  private

  # @param yaml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.2.0
  def build_data_set_class(yaml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(yaml_data)
  end
end
