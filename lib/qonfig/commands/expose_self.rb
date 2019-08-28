# frozen_string_literal: true

# @api private
# @since 0.14.0
class Qonfig::Commands::ExposeSelf < Qonfig::Commands::Base
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

  # @param caller_location [String]
  # @option env [String, Symbol]
  #
  # @api private
  # @since 0.14.0
  def initialize(caller_location, env:)
    unless env.is_a?(Symbol) || env.is_a?(String)
      raise Qonfig::ArgumentError, ':env should be a string or a symbol'
    end

    if env.to_s.empty?
      raise Qonfig::ArgumentError, ':env should be provided'
    end

    @caller_location = caller_location
    @env = env
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.14.0
  def call(data_set, settings)
    yaml_data = load_self_placed_yaml_data
    yaml_data_slice = yaml_data[env] || yaml_data[env.to_s] || yaml_data[env.to_sym]

    raise(
      Qonfig::ExposeError,
      "#{file_path} file does not contain settings with <#{env}> environment key!"
    ) unless yaml_data_slice

    raise(
      Qonfig::IncompatibleYAMLStructureError,
      'YAML content should have a hash-like structure'
    ) unless yaml_data_slice.is_a?(Hash)

    yaml_based_settings = build_data_set_klass(yaml_data_slice).new.settings
    settings.__append_settings__(yaml_based_settings)
  end

  private

  # @return [Hash]
  #
  # @raise [Qonfig::SelfDataNotFound]
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.14.0
  def load_self_placed_yaml_data
    caller_file = caller_location.split(':').first

    raise(
      Qonfig::SelfDataNotFoundError,
      "Caller file does not exist! (location: #{caller_location})"
    ) unless File.exist?(caller_file)

    data_match = IO.read(caller_file).match(/\n__END__\n(?<end_data>.*)/m)
    raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless data_match

    end_data = data_match[:end_data]
    raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless end_data

    yaml_data = Qonfig::Loaders::YAML.load(end_data)
    raise(
      Qonfig::IncompatibleYAMLStructureError,
      'YAML content should have a hash-like structure'
    ) unless yaml_data.is_a?(Hash)

    yaml_data
  end

  # @param self_placed_yaml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.14.0
  def build_data_set_klass(self_placed_yaml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(self_placed_yaml_data)
  end
end
