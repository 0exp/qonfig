# frozen_string_literal: true

# @api public
# @since 0.17.0
module Qonfig
  # @see Qonfig::Loaders::TOML
  # @see Qondig::Loaders::Dynamic
  #
  # @api public
  # @since 0.17.0
  TOMLLoaderParseError = Class.new(::TomlRB::ParseError)
end
