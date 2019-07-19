# frozen_string_literal: true

# @api private
# @since 0.12.0
class Qonfig::Loaders::TOML < Qonfig::Loaders::Basic
  class << self
    # @param data [String]
    # @return [Object]
    #
    # @api private
    # @since 0.12.0
    def load(data)
      ::TomlRB.parse(ERB.new(data).result)
    end

    # @return [Object]
    #
    # @api private
    # @since 0.12.0
    def load_empty_data
      ::TomlRB.parse('')
    end
  end
end