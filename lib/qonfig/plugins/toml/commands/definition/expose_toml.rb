# frozen_string_literal: true

# @api private
# @since 0.12.0
# @version 0.29.0
class Qonfig::Commands::Definition::ExposeTOML < Qonfig::Commands::Base
  # @since 0.20.0
  self.inheritable = true

  # @return [Hash]
  #
  # @api private
  # @since 0.12.0
  EXPOSERS = { file_name: :file_name, env_key: :env_key }.freeze

  # @return [Hash]
  #
  # @api private
  # @since 0.12.0
  EMPTY_TOML_DATA = {}.freeze

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.12.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.12.0
  attr_reader :strict

  # @return [Symbol]
  #
  # @api private
  # @since 0.12.0
  attr_reader :via

  # @return [Symbol, String]
  #
  # @api private
  # @since 0.12.0
  attr_reader :env

  # @return [Boolean]
  #
  # @api private
  # @since 0.29.0
  attr_reader :replace_on_merge

  # @param file_path [String]
  # @option via [Symbol]
  # @option env [String, Symbol]
  # @option strict [Boolean]
  # @option replace_on_merge [Boolean]
  #
  # @api private
  # @since 0.12.0
  # @version 0.29.0
  def initialize(file_path, via:, env:, strict: true, replace_on_merge: false)
    unless env.is_a?(Symbol) || env.is_a?(String) || env.is_a?(Numeric)
      raise Qonfig::ArgumentError, ':env should be a string or a symbol'
    end

    raise Qonfig::ArgumentError, ':env should be provided'  if env.to_s.empty?
    raise Qonfig::ArgumentError, 'used :via is unsupported' unless EXPOSERS.key?(via)

    @file_path = file_path
    @via = via
    @env = env
    @strict = strict
    @replace_on_merge = replace_on_merge
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.12.0
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
  # @since 0.12.0
  # @version 0.29.0
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

    toml_data = load_toml_data(realfile)
    toml_based_settings = build_data_set_klass(toml_data).new.settings

    settings.__append_settings__(toml_based_settings, with_redefinition: replace_on_merge)
  end
  # rubocop:enable Metrics/AbcSize

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @raise [Qonfig::ExposeError]
  #
  # @api private
  # @since 0.12.0
  # @version 0.29.0
  # rubocop:disable Metrics/AbcSize
  def expose_env_key!(settings)
    toml_data       = load_toml_data(file_path)
    toml_data_slice = toml_data[env] || toml_data[env.to_s] || toml_data[env.to_sym]
    toml_data_slice = EMPTY_TOML_DATA.dup if toml_data_slice.nil? && !strict

    raise(
      Qonfig::ExposeError,
      "#{file_path} file does not contain settings with <#{env}> environment key!"
    ) unless toml_data_slice

    toml_based_settings = build_data_set_klass(toml_data_slice).new.settings

    settings.__append_settings__(toml_based_settings, with_redefinition: replace_on_merge)
  end
  # rubocop:enable Metrics/AbcSize

  # @param file_path [String]
  # @return [Hash]
  #
  # @api private
  # @since 0.12.0
  def load_toml_data(file_path)
    Qonfig::Loaders::TOML.load_file(file_path, fail_on_unexist: strict)
  end

  # @param toml_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.12.0
  def build_data_set_klass(toml_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(toml_data)
  end
end
