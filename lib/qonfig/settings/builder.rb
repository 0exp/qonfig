# frozen_string_literal: true

# @api private
# @since 0.2.0
module Qonfig::Settings::Builder
  class << self
    # @param data_set [Qonfig::DataSet]
    # @param assignements [Block]
    # @yield [settings, validator]
    # @yieldparam settings [Qonfig::DataSet::Settings]
    # @yieldparam validator [Qonfig::Validation::Validators::Composite]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def build(data_set, &assignements)
      validator = build_validator(data_set)
      settings = build_definitions(data_set)
      yield(settings, validator)
      validator.validate!
      build_state(data_set)
    end

    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings]
    #
    # @api private
    # @since 0.19.0
    def build_definitions(data_set)
      Qonfig::Settings.new(build_mutation_callbacks(data_set)).tap do |settings|
        data_set.class.definition_commands.dup.each do |command|
          command.call(data_set, settings)
        end
      end
    end

    # @param data_set [Qonfig::DataSet]
    # @return [void]
    #
    # @api private
    # @since 0.19.0
    def build_state(data_set)
      data_set.class.instance_commands.dup.each do |command|
        command.call(data_set, data_set.settings)
      end
    end

    private

    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Validation::Validators::Composite]
    #
    # @api private
    # @since 0.21.0
    def build_validator(data_set)
      Qonfig::Validation::Validators::Composite.new(data_set)
    end

    # @param data_set [Qonfig::DataSet]
    # @return [Qonfig::Settings::Callbacks]
    #
    # @api private
    # @since 0.13.0
    def build_mutation_callbacks(data_set)
      Qonfig::Settings::Callbacks.new.tap do |callbacks|
        callbacks.add(Qonfig::Settings::Callbacks::Validation.new(data_set))
      end
    end
  end
end
