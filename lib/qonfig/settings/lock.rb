# frozen_string_literal: true

# @api private
# @since 0.2.0
class Qonfig::Settings::Lock
  # @api private
  # @since 0.2.0
  def initialize
    @definition_lock = Mutex.new
    @access_lock = Mutex.new
    @merge_lock = Mutex.new
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_definition(&instructions)
    definition_lock.owned? ? yield : definition_lock.synchronize(&instructions)
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_access(&instructions)
    access_lock.owned? ? yield : access_lock.synchronize(&instructions)
  end

  # @param instructions [Proc]
  # @return [Object]
  #
  # @api private
  # @since 0.2.0
  def thread_safe_merge(&instructions)
    merge_lock.owned? ? yield : merge_lock.synchronize(&instructions)
  end

  private

  # @return [Mutex]
  #
  # @api private
  # @since 0.2.0
  attr_reader :definition_lock

  # @return [Mutex]
  #
  # @api private
  # @since 0.2.0
  attr_reader :access_lock

  # @return [Mutex]
  #
  # @api private
  # @since 0.2.0
  attr_reader :merge_lock
end
