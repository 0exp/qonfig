# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Collections::PredefinedRegistry
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize
    @validators = {}
    @lock = Mutex.new
  end

  # @param name [String, Symbol]
  # @param validation [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def register(name, &validation)
    thread_safe do
      name = indifferently_accessable_name(name)
      validators[name] = validation
    end
  end

  # @param name [String, Symbol]
  # @return [Proc]
  #
  # @raise [Qonfig::ValidatorArgumentError]
  #
  # @api private
  # @since 0.20.0
  def resolve(name)
    thread_safe do
      begin
        validators.fetch(indifferently_accessable_name(name))
      rescue KeyError
        raise(
          Qonfig::ValidatorArgumentError,
          "Validator with name '#{name}' does not exist."
        )
      end
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

  # @param block [Proc]
  # @return [Any]
  #
  # @api private
  # @since 0.20.0
  def thread_safe(&block)
    @lock.synchronize(&block)
  end
end
