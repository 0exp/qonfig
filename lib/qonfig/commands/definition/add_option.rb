# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Commands::Definition::AddOption < Qonfig::Commands::Base
  # @return [Symbol, String]
  #
  # @api private
  # @since 0.1.0
  attr_reader :key

  # @return [Object]
  #
  # @api private
  # @since 0.1.0
  attr_reader :value

  # @param key [Symbol, String]
  # @param value [Object]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::CoreMethodIntersectionError]
  #
  # @api private
  # @since 0.1.0
  def initialize(key, value)
    Qonfig::Settings::KeyGuard.prevent_incomparabilities!(key)

    @key = key
    @value = value
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def call(data_set, settings)
    settings.__define_setting__(key, value)
  end
end
