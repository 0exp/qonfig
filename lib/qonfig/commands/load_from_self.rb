# frozen_string_literal: true

# @api private
# @since 0.2.0
class Qonfig::Commands::LoadFromSelf < Qonfig::Commands::Base
  # @return [String, Symbol]
  #
  # @api private
  # @since 0.15.0
  attr_reader :format

  # @return [String]
  #
  # @api private
  # @since 0.2.0
  attr_reader :caller_location

  # @param caller_location [String]
  # @option format [String, Symbol]
  #
  # @api private
  # @since 0.2.0
  def initialize(caller_location)
    @caller_location = caller_location
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.2.0
  def call(data_set, settings)
    yaml_data = load_self_placed_yaml_data

    yaml_based_settings = build_data_set_klass(yaml_data).new.settings

    settings.__append_settings__(yaml_based_settings)
  end

  private

  # @return [Hash]
  #
  # @raise [Qonfig::SelfDataNotFound]
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.2.0
  def load_self_placed_yaml_data
    end_data  = Qonfig::Commands::SelfBased::EndDataExtractor.extract(caller_location)
    yaml_data = Qonfig::Loaders::YAML.load(end_data)

    raise(
      Qonfig::IncompatibleYAMLStructureError,
      'YAML content should have a hash-like structure'
    ) unless yaml_data.is_a?(Hash)

    yaml_data
  end

  # @param self_placed_yaml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.2.0
  def build_data_set_klass(self_placed_yaml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(self_placed_yaml_data)
  end
end
