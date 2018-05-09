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
    end

    # @return [Array]
    #
    # @api private
    # @since 0.1.0
    def definitions
      @definitions ||= Qonfig::DefinitionSet.new
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
          data_set = Class.new(Qonfig::DataSet).tap do |klass|
            klass.instance_eval(&nested_settings)
          end.new

          Qonfig::Option.new(key, data_set)
        else
          Qonfig::Option.new(key, value)
        end
      end

      definitions << option
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
    @settings = Qonfig::SettingsBuilder.build(self.class.definitions)
  end
end
