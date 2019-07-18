# frozen_string_literal: true

module Qonfig
  # @api public
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @api public
  # @since 0.1.0
  ArgumentError = Class.new(ArgumentError)

  # @api public
  # @since 0.12.0
  PluginError = Class.new(Error)

  # @api public
  # @since 0.11.0
  IncorrectHashTransformationError = Class.new(ArgumentError)

  # @api public
  # @since 0.11.0
  IncorrectKeyTransformerError = Class.new(IncorrectHashTransformationError)

  # @api public
  # @since 0.11.0
  IncorrectValueTransformerError = Class.new(IncorrectHashTransformationError)

  # @see Qonfig::Settings
  #
  # @api public
  # @since 0.1.0
  UnknownSettingError = Class.new(Error)

  # @see Qonfig::Settings
  #
  # @api public
  # @since 0.2.0
  AmbiguousSettingValueError = Class.new(Error)

  # @see Qonfig::Settings
  # @see Qonfig::Settings::KeyGuard
  # @see Qonfig::Commands::AddOption
  # @see Qonfig::Commands::AddNestedOption
  #
  # @api public
  # @since 0.2.0
  CoreMethodIntersectionError = Class.new(Error)

  # @see Qonfig::Settings
  # @see Qonfig::DataSet
  #
  # @api public
  # @since 0.1.0
  FrozenSettingsError = begin # rubocop:disable Naming/ConstantName
    # :nocov:
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5.0')
      Class.new(::FrozenError)
    else
      Class.new(::RuntimeError)
    end
    # :nocov:
  end

  # @see Qonfig::Commands::LoadFromYAML
  #
  # @api public
  # @since 0.2.0
  IncompatibleYAMLStructureError = Class.new(Error)

  # @see Qonfig::Commands::LoadFromTOML
  #
  # @api public
  # @since 0.12.0
  IncompatibleTOMLStructureError = Class.new(Error)

  # @see Qonfig::Commands::LoadFromJSON
  #
  # @api public
  # @since 0.5.0
  IncompatibleJSONStructureError = Class.new(Error)

  # @see Qonfig::Loaders::YAML
  #
  # @api public
  # @since 0.2.0
  FileNotFoundError = Class.new(Errno::ENOENT)

  # @see Qonfig::Commands::LoadFromSelf
  #
  # @api public
  # @since 0.2.0
  SelfDataNotFoundError = Class.new(Error)

  # @see Qonfig::Plugins::Regsitry
  #
  # @api private
  # @since 0.4.0
  AlreadyRegisteredPluginError = Class.new(Error)

  # @see Qonfig::Plugins::Registry
  #
  # @api public
  # @since 0.4.0
  UnregisteredPluginError = Class.new(Error)

  # @see Qonfig::Commands::ExposeYAML
  #
  # @api public
  # @since 0.7.0
  ExposeError = Class.new(Error)

  # @see Qonfig::Plugin::TOMLFormat
  #
  # @api public
  # @since 0.12.0
  UnresolvedPluginDependencyError = Class.new(PluginError)
end
