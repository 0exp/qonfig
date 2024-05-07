# frozen_string_literal: true

# @api private
# @since 0.12.0
# @version 0.29.0
class Qonfig::Commands::Definition::LoadFromTOML < Qonfig::Commands::Base
  # @since 0.20.0
  self.inheritable = true

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.12.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.12.0
  attr_reader :strict

  # @return [Boolean]
  #
  # @api private
  # @since 0.29.0
  attr_reader :replace_on_merge

  # @param file_path [String]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  #
  # @api private
  # @since 0.12.0
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
  # @api private
  # @since 0.12.0
  # @version 0.29.0
  def call(data_set, settings)
    toml_data = Qonfig::Loaders::TOML.load_file(file_path, fail_on_unexist: strict)
    toml_based_settings = build_data_set_klass(toml_data).new.settings
    settings.__append_settings__(toml_based_settings, with_redefinition: replace_on_merge)
  end

  private

  # @param toml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.12.0
  def build_data_set_klass(toml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(toml_data)
  end
end
