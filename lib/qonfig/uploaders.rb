# frozen_string_literal: true

# @api private
# @since 0.11.0
module Qonfig::Uploaders
  require_relative 'uploaders/base'
  require_relative 'uploaders/file'
  require_relative 'uploaders/json'
  require_relative 'uploaders/yaml'
  require_relative 'uploaders/toml'
end
