# frozen_string_literal: true

# @api private
# @since 0.20.0
class Qonfig::Commands::Definition::ReDefineOption < Qonfig::Commands::Base
  # @since 0.20.0
  self.inheritable = true

  # @return [Symbol, String]
  #
  # @api private
  # @since 0.20.0
  attr_reader :key

  # @return [Object]
  #
  # @api private
  # @since 0.20.0
  attr_reader :value

  # @return [Proc, NilClass]
  #
  # @api private
  # @since 0.20.0
  attr_reader :nested_data_set_klass

  # @param key [Symbol, String]
  # @param value [Object]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::CoreMethodIntersectionError]
  #
  # @api private
  # @since 0.20.0
  def initialize(key, value, nested_definitions)
    Qonfig::Settings::KeyGuard.prevent_incomparabilities!(key)

    @key = key
    @value = value
    @nested_data_set_klass = Class.new(Qonfig::DataSet).tap do |data_set|
      data_set.instance_eval(&nested_definitions)
    end if nested_definitions
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.20.0
  # @version 0.31.0
  def call(data_set, settings)
    if nested_data_set_klass
      nested_settings = nested_data_set_klass.new.settings
      # NOTE:
      #   The nested instance is wired into the host's mutation-callback chain by
      #   Qonfig::Settings#__define_setting__ itself (see __store_setting_value__),
      #   so every nested-settings entry point shares one wiring path.
      settings.__define_setting__(key, nested_settings, with_redefinition: true)
    else
      settings.__define_setting__(key, value, with_redefinition: true)
    end
  end
end
