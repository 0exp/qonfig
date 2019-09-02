# frozen_string_literal: true

# @api private
# @since 0.15.0
module Qonfig::Loaders
  class << self
    prepend(Module.new do
      # @param format [String, Symbol]
      # @return [Module]
      #
      # @raise [Qonfig::UnsupportedLoaderFormatError]
      #
      # @see Qonfig::Loaders.resolve
      #
      # @api private
      # @since 0.15.0
      def resolve(format)
        return Qonfig::Loaders::TOML if format.to_s == 'toml'
        super(format)
      end
    end)
  end
end
