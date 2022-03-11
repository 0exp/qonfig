# frozen_string_literal: true

# @api private
# @since 0.5.0
class Qonfig::Commands::Definition::LoadFromJSON < Qonfig::Commands::Base
  # @since 0.19.0
  self.inheritable = true

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.5.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @sicne 0.5.0
  attr_reader :strict

  # @return [Hash]
  #
  # @api private
  # @since 0.26.0
  attr_reader :file_resolve_options

  # @param file_path [String, Pathname]
  # @option strict [Boolean]
  # @option file_resolve_options [Hash]
  #
  # @api private
  # @since 0.5.0
  def initialize(file_path, strict: true, file_resolve_options: {})
    @file_path = file_path
    @strict = strict
    @file_resolve_options = file_resolve_options
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.5.0
  def call(data_set, settings)
    json_data = Qonfig::Loaders::JSON.load_file(file_path, fail_on_unexist: strict)

    raise(
      Qonfig::IncompatibleJSONStructureError,
      'JSON object must be a hash-like structure'
    ) unless json_data.is_a?(Hash)

    json_based_settings = build_data_set_klass(json_data).new.settings
    settings.__append_settings__(json_based_settings)
  end

  private

  # @param json_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.5.0
  def build_data_set_klass(json_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(json_data)
  end
end
