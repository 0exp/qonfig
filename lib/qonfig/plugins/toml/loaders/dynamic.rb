# frozen_string_literal: true

# @api private
# @since 0.17.0
class Qonfig::Loaders::Dynamic < Qonfig::Loaders::Basic
  class << self
    prepend(Module.new do
      # @param data [String]
      # @return [Object]
      #
      # @api private
      # @since 0.17.0
      def load(data)
        try_to_load_toml_data(data)
      rescue Qonfig::TOMLLoaderParseError
        super(data)
      end

      private

      # @param data [String]
      # @return [Object]
      #
      # @api private
      # @since 0.17.0
      def try_to_load_toml_data(data)
        Qonfig::Loaders::TOML.load(data)
      end
    end)
  end
end
