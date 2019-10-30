# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Commands::Definition::Compose < Qonfig::Commands::Base
  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.1.0
  attr_reader :composable_data_set_klass

  # @param composable_data_set_klass [Qonfig::DataSet]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.1.0
  def initialize(composable_data_set_klass)
    unless composable_data_set_klass.is_a?(Class) && composable_data_set_klass < Qonfig::DataSet
      raise(
        Qonfig::ArgumentError,
        'Composed config class should be a subtype of Qonfig::DataSet'
      )
    end

    @composable_data_set_klass = composable_data_set_klass
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def call(data_set, settings)
    # NOTE: append new validators
    data_set.class.validators.concat(composable_data_set_klass.validators.dup)

    # NOTE: append new settings
    composite_settings = composable_data_set_klass.new.settings
    settings.__append_settings__(composite_settings)
  end
end
