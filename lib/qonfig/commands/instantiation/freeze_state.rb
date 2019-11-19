# frozen_string_literal: true

# @api private
# @since 0.19.0
class Qonfig::Commands::Instantiation::FreezeState < Qonfig::Commands::Base
  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.17.0
  def call(data_set, settings)
    settings.__freeze__
  end
end
