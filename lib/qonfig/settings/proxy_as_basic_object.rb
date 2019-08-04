# frozen_string_literal: true

# IS NOT USED YET
#
# @api private
# @since 0.13.0
class Qonfig::Settings::ProxyAsBasicObject < BasicObject
  # @param __delegetable_settings__ [Qonfig::Settings]
  # @param __data_set_reference__ [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(__delegetable_settings__, __data_set_reference__)
    @__delegetable_settings__ = __delegetable_settings__
    @__data_set_reference__ = __data_set_reference__
  end

  # @param __method_name__ [String, Symbol]
  # @param __arguments__ [Array<Any>]
  # @param __block__ [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def method_missing(__method_name__, *__arguments__, &__block__)
    @__delegetable_settings__.public_send(__method_name__, *__arguments__, &__block__)
  end

  # @param __method_name__ [String, Symbol]
  # @param __include_private__ [Boolean]
  # @return [Boolean]
  #
  # @see Qonfig::Settings#respond_to_missing?
  #
  # @api private
  # @since 0.13.0
  def respond_to_missing?(__method_name__, __include_private__ = false)
    @__delegetable_settings__.send(:respond_to_missing?, __method_name__, __include_private__)
  end

  # @param __klass__ [Class]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def is_a?(__klass__)
    __klass__ <= ::Qonfig::Settings::Proxy ||
      @__delegetable_settings__.public_send(:is_a?, __klass__)
  end

  # @param __klass__ [Class]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def kind_of?(__klass__)
    __klass__ <= ::Qonfig::Settings::Proxy ||
      @__delegetable_settings__.public_send(:is_a?, __klass__)
  end
end
