# frozen_string_literal: true

# @api private
# @since 0.2.0
# @version 0.29.0
class Qonfig::Commands::Definition::LoadFromYAML < Qonfig::Commands::Base
  # @since 0.19.0
  self.inheritable = true

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.2.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.2.0
  attr_reader :strict

  # @return [Boolean]
  #
  # @api private
  # @since 0.29.0
  attr_reader :replace_on_merge

  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  #
  # @api private
  # @since 0.2.0
  # @version 0.29.0
  def initialize(file_path, strict: true, replace_on_merge: false)
    @file_path = file_path
    @strict = strict
    @replace_on_merge = replace_on_merge
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.2.0
  # @version 0.29.0
  def call(data_set, settings)
    yaml_data = Qonfig::Loaders::YAML.load_file(file_path, fail_on_unexist: strict)

    raise(
      Qonfig::IncompatibleYAMLStructureError,
      'YAML content must be a hash-like structure'
    ) unless yaml_data.is_a?(Hash)

    yaml_based_settings = build_data_set_klass(yaml_data).new.settings
    settings.__append_settings__(yaml_based_settings, with_redefinition: replace_on_merge)
  end

  private

  # @param yaml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.2.0
  def build_data_set_klass(yaml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(yaml_data)
  end
end
