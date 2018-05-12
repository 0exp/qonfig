# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Definitions
  # @return [Array]
  #
  # @api private
  # @since 0.1.0
  attr_reader :options

  # @api private
  # @since 0.1.0
  def initialize
    @options = []
  end

  # @param option [Qonfig::Option]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def add_option(option)
    options << option
  end
  alias_method :<<, :add_option

  # @param another_definitions [Qonfig::Definitions]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def concat(another_definitions)
    options.concat(another_definitions.options)
  end

  # @param block [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.1.0
  def each(&block)
    options.each(&block)
  end
end
