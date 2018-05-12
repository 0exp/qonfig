# frozen_string_literal: true

# @api private
# @since 0.1.0
class Qonfig::Settings
  # @return [Hash]
  #
  # @api private
  # @since 0.1.0
  attr_reader :options

  # @api private
  # @since 0.1.0
  def initialize
    @options = {}
  end

  # @param keys [Array]
  # @param value [Object]
  # @return [void]
  #
  # @pi private
  # @since 0.1.0
  def define_setting(key, value = nil)
    unless key.is_a?(Symbol) || key.is_a?(String)
      raise Qonfig::SettingDefinitionError, 'Setting key should be a symbol or a string!'
    end

    if options.key?(key) && options[key].is_a?(Qonfig::Settings) && value.is_a?(Qonfig::Settings)
      options[key].append_settings(value)
    else
      options[key] = value
    end

    singleton_class.send(:undef_method, key) rescue NameError
    singleton_class.send(:undef_method, "#{key}=") rescue NameError

    define_singleton_method(key) { options[key] }
    define_singleton_method("#{key}=") do |value|
      options[key] = value
    end unless options[key].is_a?(Qonfig::Settings)
  end

  # @param key [Symbol]
  # @return [Object]
  #
  # @api private
  # @since 0.1.0
  def [](key)
    options[key]
  end

  # @param block [Proc]
  # @return [Enumerable]
  #
  # @api private
  # @since 0.1.0
  def each_option(&block)
    block_given? ? options.each_pair(&block) : options.each_pair
  end

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @sine 0.4.0
  def append_settings(settings)
    settings.each_option { |key, value| define_setting(key, value) }
  end

  def to_h
    options.dup.tap do |hashed|
      hashed.each_pair do |key, value|
        if value.is_a?(Qonfig::Settings)
          hashed[key] = value.is_a?(Qonfig::Settings) ? value.to_h : value
        end
      end
    end
  end
  alias_method :to_hash, :to_h
end
