# frozen_string_literal: true

# @api private
# @since 0.14.0
# @version 0.29.0
class Qonfig::Commands::Definition::ExposeSelf < Qonfig::Commands::Base
  # @since 0.19.0
  self.inheritable = true

  # @return [String, Symbol]
  #
  # @api private
  # @since 0.15.0
  attr_reader :format

  # @return [String]
  #
  # @api private
  # @since 0.14.0
  attr_reader :caller_location

  # @return [Symbol, String]
  #
  # @api private
  # @since 0.14.0
  attr_reader :env

  # @return [Boolean]
  #
  # @api private
  # @since 0.29.0
  attr_reader :replace_on_merge

  # @param caller_location [String]
  # @option env [String, Symbol]
  # @option format [String, Symbol]
  # @option replace_on_merge [Boolean]
  #
  # @api private
  # @since 0.14.0
  # @version 0.29.0
  def initialize(caller_location, env:, format:, replace_on_merge: false)
    unless env.is_a?(Symbol) || env.is_a?(String)
      raise Qonfig::ArgumentError, ':env should be a string or a symbol'
    end

    raise Qonfig::ArgumentError, ':env should be provided' if env.to_s.empty?

    unless format.is_a?(String) || format.is_a?(Symbol)
      raise Qonfig::ArgumentError, 'Format should be a symbol or a string'
    end

    @caller_location = caller_location
    @env = env
    @format = format.tap { Qonfig::Loaders.resolve(format) }
    @replace_on_merge = replace_on_merge
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.14.0
  # @version 0.29.0
  # rubocop:disable Metrics/AbcSize
  def call(data_set, settings)
    self_placed_data = load_self_placed_end_data
    env_based_data_slice =
      self_placed_data[env] || self_placed_data[env.to_s] || self_placed_data[env.to_sym]

    raise(
      Qonfig::ExposeError,
      "#{file_path} file does not contain settings with <#{env}> environment key!"
    ) unless env_based_data_slice

    raise(
      Qonfig::IncompatibleEndDataStructureError,
      '__END__-data content must be a hash-like structure'
    ) unless env_based_data_slice.is_a?(Hash)

    self_placed_settings = build_data_set_klass(env_based_data_slice).new.settings
    settings.__append_settings__(self_placed_settings, with_redefinition: replace_on_merge)
  end
  # rubocop:enable Metrics/AbcSize

  private

  # @return [Hash]
  #
  # @raise [Qonfig::SelfDataNotFound]
  # @raise [Qonfig::IncompatibleEndDataStructureError]
  #
  # @api private
  # @since 0.14.0
  def load_self_placed_end_data
    end_data      = Qonfig::Loaders::EndData.extract(caller_location)
    settings_data = Qonfig::Loaders.resolve(format).load(end_data)

    raise(
      Qonfig::IncompatibleEndDataStructureError,
      '__END__-data must be a hash-like structure'
    ) unless settings_data.is_a?(Hash)

    settings_data
  end

  # @param self_placed_settings [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.14.0
  def build_data_set_klass(self_placed_settings)
    Qonfig::DataSet::ClassBuilder.build_from_hash(self_placed_settings)
  end
end
