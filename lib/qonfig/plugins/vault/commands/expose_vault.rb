# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Commands::Definition::ExposeVault < Qonfig::Commands::Base
  # @since 0.25.0
  self.inheritable = true

  # @return [Hash]
  #
  # @api private
  # @since 0.25.0
  EXPOSERS = { path: :path, env_key: :env_key }.freeze

  # @return [Hash]
  #
  # @api private
  # @since 0.25.0
  EMPTY_VAULT_DATA = {}.freeze

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.12.0
  attr_reader :path

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

  # @param path [String]
  # @option strict [Boolean]
  # @option via [Symbol]
  # @option env [String, Symbol]
  #
  # @api private
  # @since 0.25.0
  def initialize(path, strict: true, via:, env:)
    unless env.is_a?(Symbol) || env.is_a?(String) || env.is_a?(Numeric)
      raise Qonfig::ArgumentError, ':env should be a string or a symbol'
    end

    raise Qonfig::ArgumentError, ':env should be provided'  if env.to_s.empty?
    raise Qonfig::ArgumentError, 'used :via is unsupported' unless EXPOSERS.key?(via)

    @path   = path
    @strict = strict
    @via    = via
    @env    = env
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.25.0
  def call(_data_set, settings)
    case via
    when EXPOSERS[:path]
      expose_path!(settings)
    when EXPOSERS[:env_key]
      expose_env_key!(settings)
    end
  end

  private

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.25.0
  def expose_path!(settings)
    # NOTE: transform path (insert environment name into a secret name)
    #   from: kv/data/secret_name
    #   to:   kv/data/env_name.secret_name

    splitted_path = path.split('/')
    splitted_path[-1] = [env.to_s, splitted_path[-1]].reject(&:empty?).join('.')
    real_path = splitted_path.join('/')

    vault_data = load_vault_data(real_path)
    vault_based_settings = build_data_set_class(vault_data).new.settings

    settings.__append_settings__(vault_based_settings)
  end

  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @raise [Qonfig::ExposeError]
  #
  # @api private
  # @since 0.25.0
  def expose_env_key!(settings)
    vault_data       = load_vault_data(path)
    vault_data_slice = vault_data[env.to_sym]
    vault_data_slice = EMPTY_VAULT_DATA.dup if vault_data_slice.nil? && !strict

    raise(
      Qonfig::ExposeError,
      "#{path} does not contain settings with <#{env}> environment key!"
    ) unless vault_data_slice

    vault_based_settings = build_data_set_class(vault_data_slice).new.settings

    settings.__append_settings__(vault_based_settings)
  end

  # @param path [String]
  # @return [Hash]
  #
  # @api private
  # @since 0.25.0
  def load_vault_data(path)
    Qonfig::Loaders::Vault.load_file(path, fail_on_unexist: strict)
  end

  # @param vault_data [Hash]
  # @return [Class<Qonfig::DataSet>]
  #
  # @api private
  # @since 0.25.0
  def build_data_set_class(vault_data)
    Qonfig::DataSet::ClassBuilder.build_from_hash(vault_data)
  end
end
