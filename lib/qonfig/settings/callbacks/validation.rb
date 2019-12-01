# frozen_string_literal: true

# @api private
# @since 0.21.0
class Qonfig::Settings::Callbacks::Validation
  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.21.0
  def initialize(data_set)
    @data_set = data_set
  end

  # @return [void]
  #
  # @api private
  # @since 0.21.0
  def call
    data_set.validate!
  end

  private

  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.21.0
  attr_reader :data_set
end
