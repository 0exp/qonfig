# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Collections::PredefinedRegistry
  # @since 0.20.0
  include Enumerable

  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize
    @validators = {}
    @lock = Mutex.new
  end

  # @param predefined_registry [Qonfig::Validation::Collections::PredefinedRegistry]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def merge(predefined_registry)
    thread_safe { concat(predefined_registry) }
  end

  # @param name [String, Symbol]
  # @param validation [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def register(name, validation)
    thread_safe { apply(name, validation) }
  end
  alias_method :[]=, :register

  # @param name [String, Symbol]
  # @return [Proc]
  #
  # @api private
  # @since 0.20.0
  def resolve(name)
    thread_safe { fetch(name) }
  end
  alias_method :[], :resolve

  # @return [Qonfig::Validation::Collection::PredefinedRegistry]
  #
  # @api private
  # @since 0.20.0
  def dup
    thread_safe { duplicate }
  end

  # @param block [Block]
  # @yield [validator_name, validation_logic]
  # @yieldparam validator_name [String]
  # @yieldparam validation_logic [Proc]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.20.0
  def each(&block)
    thread_safe do
      block_given? ? validators.each_pair(&block) : validators.each_pair
    end
  end

  private

  # @return [Hash<String,Proc>]
  #
  # @api private
  # @since 0.20.0
  attr_reader :validators

  # @param name [String, Symbol]
  # @return [String]
  #
  # @api private
  # @since 0.20.0
  def indifferently_accessable_name(name)
    name.to_s
  end

  # @param name [String, Symbol]
  # @param validation [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def apply(name, validation)
    name = indifferently_accessable_name(name)
    validators[name] = validation
  end

  # @param name [String, Symbol]
  # @return [Proc]
  #
  # @raise [Qonfig::ValidatorNotFoundError]
  #
  # @api private
  # @since 0.20.0
  def fetch(name)
    validators.fetch(indifferently_accessable_name(name))
  rescue KeyError
    raise(
      Qonfig::ValidatorNotFoundError,
      "Validator with name '#{name}' does not exist."
    )
  end

  # @param predefined_registry [Qonfig::Validation::Collections::PredefinedRegistry]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def concat(predefined_registry)
    predefined_registry.dup.each do |validator_name, validation_logic|
      validators[validator_name] = validation_logic
    end
  end

  # @return [Qonfig::Validation::Collections::PredefinedRegistry]
  #
  # @api private
  # @since 0.20.0
  def duplicate
    Qonfig::Validation::Collections::PredefinedRegistry.new.tap do |registry|
      validators.each_pair do |validator_name, validation_logic|
        registry.register(validator_name, validation_logic)
      end
    end
  end

  # @param block [Proc]
  # @return [Any]
  #
  # @api private
  # @since 0.20.0
  def thread_safe(&block)
    @lock.synchronize(&block)
  end
end
