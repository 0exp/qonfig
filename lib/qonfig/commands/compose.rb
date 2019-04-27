# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Commands::Compose < Qonfig::Commands::Base
  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.1.0
  attr_reader :data_set_klass

  # @param data_set_klass [Qonfig::DataSet]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.1.0
  def initialize(data_set_klass)
    raise(
      Qonfig::ArgumentError,
      'Composed config class should be a subtype of Qonfig::DataSet'
    ) unless data_set_klass.is_a?(Class) && data_set_klass < Qonfig::DataSet

    @data_set_klass = data_set_klass
  end

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def call(settings)
    composite_settings = data_set_klass.new.settings

    settings.__append_settings__(composite_settings)
  end
end
