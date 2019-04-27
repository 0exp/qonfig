# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::Base
  class << self
    # @param data_set [Qonfig::DataSet]
    # @param options [Hash<Symbol,Any>]
    # @return [void]
    #
    # @api private
    # @since 0.11.0
    def upload(data_set, **options)
      nil # NOTE: consciously return nil (for clarity)
    end
  end
end
