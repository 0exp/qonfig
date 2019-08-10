# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::DataSet::Lock
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize
    @access_lock = Mutex.new
    @definition_lock = Mutex.new
  end

  # @param instructions [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def thread_safe_access(&instructions)
    access_lock.owned? ? yield : access_lock.synchronize(&instructions)
  end

  # @param instructions [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def thread_safe_definition(&instructions)
    definition_lock.owned? ? yield : definition_lock.synchronize(&instructions)
  end

  private

  # @return [Mutex]
  #
  # @api private
  # @since 0.13.0
  attr_reader :access_lock

  # @return [Mutex]
  #
  # @api private
  # @since 0.13.0
  attr_reader :definition_lock
end
