# frozen_string_literal: true

module Qonfig
  # @api public
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @api public
  # @since 0.1.0
  ArgumentError = Class.new(Error)

  # @api public
  # @since 0.1.0
  UnknownSettingError = Class.new(Error)
end

