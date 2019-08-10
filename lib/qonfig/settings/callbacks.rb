# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Settings::Callbacks
  # @api private
  # @since 0.13.0
  include Enumerable

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize
    @callbacks = []
  end

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def call
    callbacks.each(&:call)
  end

  # @param callback [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def add(&callback)
    callbacks << callback
  end
  attr_reader :callback

  private

  # @return [Array<Proc>]
  #
  # @api private
  # @since 0.13.0
  attr_reader :callbacks
end
