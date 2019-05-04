# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::Base
  class << self
    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol,Any>]
    # @param value_procssor [Block]
    # @return [void]
    #
    # @api private
    # @since 0.11.0
    def upload(settings, **options, &value_processor)
      nil # NOTE: consciously return nil (for clarity)
    end
  end
end
