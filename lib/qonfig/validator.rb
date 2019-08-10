# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Validator
  require_relative 'validator/basic'
  require_relative 'validator/method_based'
  require_relative 'validator/proc_based'
  require_relative 'validator/builder'
  require_relative 'validator/collection'
  require_relative 'validator/dsl'

  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(data_set)
    @data_set = data_set
  end

  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def validate!
    data_set.class.validators.each do |validator|
      validator.validate(data_set)
    end
  end

  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def valid?
    (validate! || true) rescue false
  end

  private

  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.13.0
  attr_reader :data_set
end
