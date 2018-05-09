# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Settings
  # @return [Hash]
  #
  # @api private
  # @since 0.1.0
  attr_reader :settings

  # @api private
  # @since 0.1.0
  def initialize
    @settings  = {}
    @appenders = [] # NOTE: debug only
  end

  # @option keys [Array]
  # @option value [Object]
  # @return void
  #
  # @pi private
  # @since 0.1.0
  def define_setting(key:, value:)
    settings[key] = value
  end

  def append_setting(key:, value:)
    @appenders << { key: key, value: value } # NOTE: debug only
  end
end
