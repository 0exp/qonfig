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
    @arbitary_lock = Mutex.new
  end

  # @param instructions [Block]
  # @return [void]
  #
  # @api private
  # @since 0.17.0
  def with_arbitary_access(&instructions)
    acquire_arbitary_lock(&instructions)
  end

  # @param instructions [Block]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def thread_safe_access(&instructions)
    if arbitary_lock.locked?
      # :nocov:
      # NOTE: covered in thread-based specs but simplecov can't gather this fact
      with_arbitary_access { acquire_access_lock(&instructions) } # :nocov:
      # :nocov:
    else
      acquire_access_lock(&instructions)
    end
  end

  # @param instructions [Block]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def thread_safe_definition(&instructions)
    if arbitary_lock.locked?
      # :nocov:
      # NOTE: covered in thread-based specs but simplecov can't gather this fact
      with_arbitary_access { acquire_definition_lock(&instructions) }
      # :nocov:
    else
      acquire_definition_lock(&instructions)
    end
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

  # @return [Mutex]
  #
  # @api private
  # @since 0.17.0
  attr_reader :arbitary_lock

  # @param instructions [Block]
  # @return [void]
  #
  # @api private
  # @since 0.17.0
  def acquire_arbitary_lock(&instructions)
    arbitary_lock.owned? ? yield : arbitary_lock.synchronize(&instructions)
  end

  # @param instructions [Block]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def acquire_access_lock(&instructions)
    access_lock.owned? ? yield : access_lock.synchronize(&instructions)
  end

  # @param instructions [Block]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def acquire_definition_lock(&instructions)
    definition_lock.owned? ? yield : definition_lock.synchronize(&instructions)
  end
end
