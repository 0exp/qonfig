# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Collections::InstanceCollection
  # @api private
  # @since 0.20.0
  include Enumerable

  # @return [Array<Qonfig::Validation::Validators::Base>]
  #
  # @api private
  # @since 0.20.0
  attr_reader :validators

  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize
    @validators = []
    @access_lock = Mutex.new
  end

  # @param validator [Qonfig::Validation::Validators::Base]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def add_validator(validator)
    thread_safe { validators << validator }
  end
  alias_method :<<, :add_validator

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.20.0
  def each(&block)
    thread_safe { block_given? ? validators.each(&block) : validators.each }
  end

  # @param collection [Qonfig::Validation::Collections::InstanceCollection]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def concat(collection)
    thread_safe { validators.concat(collection.validators) }
  end

  # @return [Qonfig::Validation::Collections::InstanceCollection]
  #
  # @api private
  # @since 0.20.0
  def dup
    thread_safe do
      Qonfig::Validation::Collections::InstanceCollection.new.tap do |duplicate|
        duplicate.concat(self)
      end
    end
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
