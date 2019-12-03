# frozen_string_literal: true

# @api private
# @since 0.21.0
class Qonfig::Compacted < BasicObject
  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.21.0
  def initialize(data_set)
    @____data_set____ = data_set
    @____data_set____.export_settings(self, '*', accessor: true, raw: true)
  end
end
