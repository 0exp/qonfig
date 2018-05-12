# frozen_string_literal: true

# @api public
# @since 0.1.0
class Qonfig::DataSet
  class << self
    # @param child_klass [Class]
    #
    # @api private
    # @since 0.1.0
    def inherited(child_klass)
      child_klass.definitions.concat(definitions)
      child_klass.compositors.concat(compositors)
    end

    # @return [Array]
    #
    # @api private
    # @since 0.1.0
    def definitions
      @definitions ||= Qonfig::Definitions.new
    end

    def compositors
      @compositors ||= []
    end

    # @param key [Symbol]
    # @param nested_settings [Proc]
    # @option value [Object]
    # @return [Qonfig::Option]
    #
    # @api public
    # @since 0.1.0
    def setting(key, value = nil, &nested_settings)
      option = begin
        if block_given?
          nested_dataset = Class.new(Qonfig::DataSet).tap do |data_set|
            data_set.instance_eval(&nested_settings)
          end

          Qonfig::NestedOption.new(key, nested_dataset)
        else
          Qonfig::Option.new(key, value)
        end
      end

      definitions << option
    end

    def compose(data_set_class)
      compositors << data_set_class
    end
  end

  # @return [Qonfig::Settings]
  #
  # @api private
  # @since 0.1.0
  attr_reader :settings

  # @api public
  # @since 0.1.0
  def initialize
    @settings = Qonfig::SettingsBuilder.build(definitions)
  end

  # @return [Qonfig::Definitions]
  #
  # @api private
  # @since 0.1.0
  def definitions
    option_collection = Qonfig::Definitions.new

    own_definitions        = self.class.definitions
    composable_definitions = self.class.compositors.map(&:definitions)

    composable_definitions.each do |definition|
      definition.each do |option|
        option_collection << option
      end
    end

    own_definitions.each do |option|
      option_collection << option
    end

    option_collection
  end

  def configure
    block_given? ? yield(settings) : settings
  end

  def to_h
    settings.to_h
  end
  alias_method :to_hash, :to_h
end
