# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Validation::Validators::Composite
  # @param data_set [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def initialize(data_set)
    @data_set = data_set
    @validators = data_set.class.validators.dup
  end

  # @return [void]
  #
  # @api private
  # @since 0.20.0
  def validate!
    validators.each do |validator|
      validator.validate(data_set)
    end
  end

  # @return [Boolean]
  #
  # @api private
  # @since 0.20.0
  def valid?
    validate!
    true
  rescue Qonfig::ValidationError
    false
  end

  private

  # @return [Qonfig::DataSet]
  #
  # @api private
  # @since 0.20.0
  attr_reader :data_set

  # @return [Qonfig::Validation::Collections::InstanceCollection]
  #
  # @api private
  # @since 0.20.0
  attr_reader :validators
end
