# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator::Collection
  # @return [Array<Qonfig::Validator::MethodBased,Qonfig::Validator::ProcBased>]
  #
  # @api private
  # @since 0.13.0
  attr_reader :validators

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize
    @validators = []
    @access_lock = Mutex.new
  end

  # @param validator [Qonfig::Validator::MethodBased, Qonfig::Validator::ProcBased]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def add_validator(validator)
    thread_safe { validators << validator }
  end
  alias_method :<<, :add_validator

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.13.0
  def each(&block)
    thread_safe { block_given? ? validators.each(&block) : validators.each }
  end

  # @param collection [Qonfig::Validator::Collection]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def concat(collection)
    thread_safe { validators.concat(collection.validators) }
  end

  # @return [Qonfig::Validator::Collection]
  #
  # @api private
  # @since 0.13.0
  def dup
    thread_safe do
      self.class.new.tap { |duplicate| duplicate.concat(self) }
    end
  end

  # @return [Integer]
  #
  # @api private
  # @since 0.13.0
  def size
    thread_safe { validators.size }
  end

  # @return [Integer]
  #
  # @api private
  # @since 0.13.0
  def count
    thread_safe { validators.count }
  end

  private

  # @param block [Proc]
  # @return [Any]
  #
  # @api private
  # @since 0.13.0
  def thread_safe(&block)
    @access_lock.synchronize(&block)
  end
end
