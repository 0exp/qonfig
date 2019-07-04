# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Loaders
  require_relative 'loaders/basic'
  require_relative 'loaders/json'
  require_relative 'loaders/yaml'
  require_relative 'loaders/toml'
end
