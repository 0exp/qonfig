# frozen_string_literal: true

# @api private
# @since 0.21.0
module Qonfig::Compacted::Constructor
  # @return [NilClass]
  #
  # @api private
  # @since 0.21.0
  NO_NITIAL_DATA_SET = nil

  class << self
    # @param compacted_config [Qonfig::Compacted]
    # @param initial_data_set [NilClass, Qonfig::DataSet]
    # @option settings_map [Hash]
    # @param configuration [Block]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def construct(
      compacted_config,
      initial_data_set = NO_NITIAL_DATA_SET,
      settings_map: {},
      &configuration
    )
      prevent_incompatible_attributes!(compacted_config, initial_data_set)

      if initial_data_set
        construct_instance_from_data_set(
          compacted_config,
          initial_data_set,
          settings_map,
          &configuration
        )
      else
        construct_isntance_from_commands(
          compacted_config,
          settings_map,
          &configuration
        )
      end
    end

    private

    # @param compacted_config [Qonfig::Compacted]
    # @param initial_data_set [Qonfig::DataSet]
    # @param settings_map [Hash]
    # @param configuration [Block]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def construct_instance_from_data_set(
      compacted_config,
      initial_data_set,
      settings_map,
      &configuration
    )
      compacted_config.instance_eval do
        @____data_set____ = initial_data_set
        @____data_set____.configure(settings_map, &configuration)
        @____data_set____.export_settings(self, '*', accessor: true, raw: true)
      end
    end

    # @param compacted_config [Qonfig::Compacted]
    # @param settings_map [Hash]
    # @param configuration [Block]
    # @return [void]
    #
    # @see #construct_instance_from_data_set
    #
    # @api private
    # @since 0.21.0
    def construct_isntance_from_commands(
      compacted_config,
      settings_map,
      &configuration
    )
      compacted_config_klass = (class << compacted_config; self; end).superclass
      target_data_set_klass = Class.new(Qonfig::DataSet)
      Qonfig::DSL::Inheritance.inherit(base: compacted_config_klass, child: target_data_set_klass)
      target_data_set = target_data_set_klass.new

      construct_instance_from_data_set(
        compacted_config,
        target_data_set,
        settings_map,
        &configuration
      )
    end

    # @param compacted_config [Qonfig::Compacted]
    # @param initial_data_set [NilClass, Qonfig::DataSet]
    # @return [void]
    #
    # @api private
    # @since 0.21.0
    def prevent_incompatible_attributes!(compacted_config, initial_data_set)
      unless (class << compacted_config; self; end).superclass <= Qonfig::Compacted
        # :nocov:
        raise(Qonfig::ArgumentError, 'Compacted config should be a type of Qonfig::Compacted')
        # :nocov:
      end

      unless initial_data_set.nil? || initial_data_set.is_a?(Qonfig::DataSet)
        raise(Qonfig::ArgumentError, 'Initial config should be a type of Qonfig::DataSet')
      end
    end
  end
end
