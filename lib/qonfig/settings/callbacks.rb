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
    @lock = Mutex.new
  end

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def call
    thread_safe { callbacks.each(&:call) }
  end

  # @param callback [Proc, Qonfig::Settings::Callbacks, #call]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def add(callback)
    thread_safe { callbacks << callback }
  end

  private

  # @return [Array<Proc>]
  #
  # @api private
  # @since 0.13.0
  attr_reader :callbacks

  # @return [Any]
  #
  # @api private
  # @since 0.14.0
  def thread_safe(&block)
    @lock.owned? ? yield : @lock.synchronize(&block)
  end
end
