# frozen_string_literal: true

# @api private
# @since 0.21.0
class Qonfig::Compact
  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.21.0
  def initialize(data_set)
    @__data_set__ = data_set
    data_set.export_settings(self, '*', accessor: true, raw: true)
  end

  private

  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.21.0
  attr_reader :__data_set__
end
