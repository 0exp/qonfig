# frozen_string_literal: true

# @api private
# @since 0.2.0
# @version 0.29.0
class Qonfig::Commands::Definition::LoadFromENV < Qonfig::Commands::Base
  require_relative 'load_from_env/value_converter'

  # @since 0.19.0
  self.inheritable = true

  # @return [Boolean]
  #
  # @api private
  # @since 0.2.0
  attr_reader :convert_values

  # @return [Regexp]
  #
  # @api private
  # @since 0.2.0
  attr_reader :prefix_pattern

  # @return [Boolean]
  #
  # @api private
  # @since 0.2.0
  attr_reader :trim_prefix

  # @return [Regexp]
  #
  # @api private
  # @since 0.2.0
  attr_reader :trim_pattern

  # @return [Boolean]
  #
  # @api private
  # @since 0.29.0
  attr_reader :redefine_on_merge

  # @option convert_values [Boolean]
  # @opion prefix [NilClass, String, Regexp]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.2.0
  # @version 0.29.0
  def initialize(convert_values: false, prefix: nil, trim_prefix: false, redefine_on_merge: false)
    unless convert_values.is_a?(FalseClass) || convert_values.is_a?(TrueClass)
      raise Qonfig::ArgumentError, ':convert_values option should be a boolean'
    end

    unless prefix.is_a?(NilClass) || prefix.is_a?(String) || prefix.is_a?(Regexp)
      raise Qonfig::ArgumentError, ':prefix option should be a nil / string / regexp'
    end

    unless trim_prefix.is_a?(FalseClass) || trim_prefix.is_a?(TrueClass)
      raise Qonfig::ArgumentError, ':trim_refix options should be a boolean'
    end

    @convert_values = convert_values
    @prefix_pattern = prefix.is_a?(Regexp) ? prefix : /\A#{Regexp.escape(prefix.to_s)}.*\z/m
    @trim_prefix = trim_prefix
    @redefine_on_merge = redefine_on_merge

    # TODO: mb trim_prefix ?
    @trim_pattern = prefix.is_a?(Regexp) ? prefix : /\A(#{Regexp.escape(prefix.to_s)})/m
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @option redefine_on_merge [Boolean]
  # @return [void]
  #
  # @api private
  # @since 0.2.0
  # @version 0.29.0
  def call(data_set, settings)
    env_data = extract_env_data
    env_based_settings = build_data_set_klass(env_data).new.settings
    settings.__append_settings__(env_based_settings, with_redefinition: redefine_on_merge)
  end

  private

  # @return [Hash]
  #
  # @api private
  # @since 0.2.0
  def extract_env_data
    ENV.each_with_object({}) do |(key, value), env_data|
      next unless key.match(prefix_pattern)
      key = key.sub(trim_pattern, '') if trim_prefix
      env_data[key] = value
    end.tap do |env_data|
      ValueConverter.convert_values!(env_data) if convert_values
    end
  end

  # @param env_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.2.0
  def build_data_set_klass(env_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(env_data)
  end
end
