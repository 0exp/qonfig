# frozen_string_literal: true

# @api private
# @since 0.7.0
class Qonfig::Commands::Definition::ExposeYAML < Qonfig::Commands::Base
  # @since 0.19.0
  self.inheritable = true

  # @return [Hash]
  #
  # @api private
  # @since 0.7.0
  EXPOSERS = { file_name: :file_name, env_key: :env_key }.freeze

  # @return [Hash]
  #
  # @api private
  # @since 0.7.0
  EMPTY_YAML_DATA = {}.freeze

  # @return [String]
  #
  # @api private
  # @since 0.7.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.7.0
  attr_reader :strict

  # @return [Symbol]
  #
  # @api private
  # @since 0.7.0
  attr_reader :via

  # @return [Symbol, String]
  #
  # @api private
  # @since 0.7.0
  attr_reader :env

  # @param file_path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [String, Symbol]
  #
  # @api private
  # @since 0.7.0
  def initialize(file_path, strict: true, via:, env:)
    unless env.is_a?(Symbol) || env.is_a?(String) || env.is_a?(Numeric)
      raise Qonfig::ArgumentError, ':env should be a string or a symbol'
    end

    raise Qonfig::ArgumentError, ':env should be provided'  if env.to_s.empty?
    raise Qonfig::ArgumentError, 'used :via is unsupported' unless EXPOSERS.key?(via)

    @file_path = file_path
    @strict    = strict
    @via       = via
    @env       = env
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.7.0
  def call(data_set, settings)
    case via
    when EXPOSERS[:file_name]
      expose_file_name!(settings)
    when EXPOSERS[:env_key]
      expose_env_key!(settings)
    end
  end

  private

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.7.0
  # rubocop:disable Metrics/AbcSize
  def expose_file_name!(settings)
    # NOTE: transform file name (insert environment name into the file name)
    #   from: path/to/file/file_name.file_extension
    #   to:   path/to/file/file_name.env_name.file_extension

    pathname = Pathname.new(file_path)
    dirname  = pathname.dirname
    extname  = pathname.extname.to_s
    basename = pathname.basename.to_s.sub!(extname, '')
    envname  = [env.to_s, extname].reject(&:empty?).join('')
    envfile  = [basename, envname].reject(&:empty?).join('.')
    realfile = dirname.join(envfile).to_s

    yaml_data = load_yaml_data(realfile)
    yaml_based_settings = build_data_set_klass(yaml_data).new.settings

    settings.__append_settings__(yaml_based_settings)
  end
  # rubocop:enable Metrics/AbcSize

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @raise [Qonfig::ExposeError]
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.7.0
  # rubocop:disable Metrics/AbcSize
  def expose_env_key!(settings)
    yaml_data       = load_yaml_data(file_path)
    yaml_data_slice = yaml_data[env] || yaml_data[env.to_s] || yaml_data[env.to_sym]
    yaml_data_slice = EMPTY_YAML_DATA.dup if yaml_data_slice.nil? && !strict

    raise(
      Qonfig::ExposeError,
      "#{file_path} file does not contain settings with <#{env}> environment key!"
    ) unless yaml_data_slice

    raise(
      Qonfig::IncompatibleYAMLStructureError,
      'YAML content must be a hash-like structure'
    ) unless yaml_data_slice.is_a?(Hash)

    yaml_based_settings = build_data_set_klass(yaml_data_slice).new.settings

    settings.__append_settings__(yaml_based_settings)
  end
  # rubocop:enable Metrics/AbcSize

  # @param file_path [String]
  # @return [Hash]
  #
  # @raise [Qonfig::IncompatibleYAMLStructureError]
  #
  # @api private
  # @since 0.7.0
  def load_yaml_data(file_path)
    Qonfig::Loaders::YAML.load_file(file_path, fail_on_unexist: strict).tap do |yaml_data|
      raise(
        Qonfig::IncompatibleYAMLStructureError,
        'YAML content must be a hash-like structure'
      ) unless yaml_data.is_a?(Hash)
    end
  end

  # @param yaml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.7.0
  def build_data_set_klass(yaml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(yaml_data)
  end
end
