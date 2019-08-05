# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Settings::Proxy < Delegator
  ASSIGNING_METHOD_MARKER = '='
  ASSIGNING_METHOD_MARKER_POSITION = -1

  # @param __delegetable_settings__ [Qonfig::Settings]
  # @param __data_set_reference__ [Qonfig::DataSet]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def initialize(__delegetable_settings__, __data_set_reference__)
    @__delegetable_settings__ = __delegetable_settings__
    @__data_set_reference__ = __data_set_reference__
    @__data_set_validator__ = Qonfig::Validator.new(__data_set_reference__)
  end

  # @return [Qonfig::Settings]
  #
  # @api private
  # @since 0.13.0
  def __getobj__
    @__delegetable_settings__
  end

  # @param __method_name__ [String, Symbol]
  # @param __arguments__ [Array<Any>]
  # @param __block__ [Proc]
  # @return [void]
  #
  # @api private
  # @since 0.13.0
  def method_missing(__method_name__, *__arguments__, &__block__)
    @__delegetable_settings__.public_send(__method_name__, *__arguments__, &__block__).tap do
      # NOTE: {{ [-1] == '=' }} is fater than {{ .to_s.ends_with?('=') }}
      # NOTE: if the last symbol of method name is a `=`
      if __method_name__[ASSIGNING_METHOD_MARKER_POSITION] == ASSIGNING_METHOD_MARKER
        @__data_set_validator__.validate!
      end
    end
  end

  # @see Qonfig::Settings#__define_setting__
  #
  # @api private
  # @since 0.13.0
  def __define_setting__(__key__, __value__)
    @__delegetable_settings__.__define_setting__(__key__, __value__).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#__append_settings__
  #
  # @api private
  # @since 0.13.0
  def __append_settings__(__settings__)
    @__delegetable_settings__.__append_settings__(__settings__).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#[]=
  #
  # @api private
  # @since 0.13.0
  def []=(__key__, __value__)
    (@__delegetable_settings__[__key__] = __value__).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#__apply_values__
  #
  # @api private
  # @since 0.13.0
  def __apply_values__(__settings_map__)
    @__delegetable_settings__.__apply_values__(__settings_map__).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#__clear__
  #
  # @api private
  # @since 0.13.0
  def __clear__
    @__delegetable_settings__.__clear__.tap do
      @__data_set_validator__.validate!
    end
  end
end
