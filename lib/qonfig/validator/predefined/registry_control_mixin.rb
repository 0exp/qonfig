# frozen_string_literal: true

# @api private
# @since 0.13.0
module Qonfig::Validator::Predefined::RegistryControlMixin
  class << self
    # @param basic_klass [Class, Module]
    # @return [void]
    #
    # @api private
    # @since 0.13.0
    def extended(basic_klass)
      basic_klass.instance_variable_set(:@registry, Qonfig::Validator::Predefined::Registry.new)
    end
  end

  # @return [Qonfig::Validator::Predefined::Registry]
  #
  # @api private
  # @since 0.13.0
  attr_reader :registry

  # @param name [String, Symbol]
  # @param validation [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def predefine(name, &validation)
    registry.register(name, &validation)
  end

  # @param name [String, Symbol]
  # @param setting_key_matcher [Qonfig::Setting::KeyMatcher]
  # @return [Qonfig::Validator::Predefined::Common]
  #
  # @api private
  # @since 0.13.0
  def build(name, setting_key_matcher)
    validation = registry.resolve(name)
    Qonfig::Validator::Predefined::Common.new(setting_key_matcher, validation)
  end
end
