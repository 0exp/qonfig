# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Settings::Proxy < Delegator
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
    @__delegetable_settings__.public_send(__method_name__, *__arguments__, &__block__)
  end

  # @see Qonfig::Settings#__define_setting__
  #
  # @api private
  # @since 0.13.0
  def __define_setting__(key, value)
    @__delegetable_settings__.__define_setting__(key, value).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#__append_settings__
  #
  # @api private
  # @since 0.13.0
  def __append_settings__(settings)
    @__delegetable_settings__.__append_settings__(settings).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#[]=
  #
  # @api private
  # @since 0.13.0
  def []=(key, value)
    (@__delegetable_settings__[key] = value).tap do
      @__data_set_validator__.validate!
    end
  end

  # @see Qonfig::Settings#__apply_values__
  #
  # @api private
  # @since 0.13.0
  def __apply_values__(settings_map)
    @__delegetable_settings__.__apply_values__(settings_map).tap do
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
