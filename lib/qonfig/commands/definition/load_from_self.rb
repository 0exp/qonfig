# frozen_string_literal: true

# @api private
# @since 0.2.0
class Qonfig::Commands::Definition::LoadFromSelf < Qonfig::Commands::Base
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
  def initialize(caller_location, format:)
    unless format.is_a?(String) || format.is_a?(Symbol)
      raise Qonfig::ArgumentError, 'Format should be a symbol or a string'
    end

    @caller_location = caller_location
    @format = format.tap { Qonfig::Loaders.resolve(format) }
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.2.0
  def call(data_set, settings)
    self_placed_end_data = load_self_placed_end_data
    self_placed_settings = build_data_set_klass(self_placed_end_data).new.settings

    settings.__append_settings__(self_placed_settings)
  end

  private

  # @return [Hash]
  #
  # @raise [Qonfig::SelfDataNotFound]
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.2.0
  def load_self_placed_end_data
    end_data      = Qonfig::Loaders::EndData.extract(caller_location)
    settings_data = Qonfig::Loaders.resolve(format).load(end_data)

    raise(
      Qonfig::IncompatibleEndDataStructureError,
      '__END__-data must be a hash-like structure'
    ) unless settings_data.is_a?(Hash)

    settings_data
  end

  # @param self_placed_settings [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.2.0
  def build_data_set_klass(self_placed_settings)
    Qonfig::DataSet::ClassBuilder.build_from_hash(self_placed_settings)
  end
end
