# frozen_string_literal: true

module Qonfig
  # @api public
  # @since 0.1.0
  Error = Class.new(StandardError)

  # @api public
  # @since 0.1.0
  ArgumentError = Class.new(ArgumentError)

  # @see Qonfig::Validation::Validators::MethodBased
  # @see Qonfig::Validation::Validators::ProcBased
  # @see Qonfig::Validation::Validators::Predefined
  #
  # @api public
  # @since 0.13.0
  ValidationError = Class.new(Error)

  # @see Qonfig::Validation::Building::InstanceBuilder::AttributeConsistency
  # @see Qonfig::Validation::Building::PredefinedBuilder
  #
  # @api public
  # @since 0.13.0
  ValidatorArgumentError = Class.new(ArgumentError)

  # @see Qonfig::Validation::Collections::PredefinedRegistry
  #
  # @api public
  # @since 0.20.0
  ValidatorNotFoundError = Class.new(ValidatorArgumentError)

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
  # @api private
  # @since 0.19.0
  StrangeThingsError = Class.new(Error)

  # @see Qonfig::Settings
  #
  # @api public
  # @since 0.2.0
  AmbiguousSettingValueError = Class.new(Error)

  # @see Qonfig::Settings
  # @see Qonfig::Settings::KeyGuard
  # @see Qonfig::Commands::Definition::AddOption
  # @see Qonfig::Commands::Definition::AddNestedOption
  # @see Qonfig::Commands::Definition::ReDefineOption
  #
  # @api public
  # @since 0.2.0
  CoreMethodIntersectionError = Class.new(Error)

  # @api public
  # @since 0.19.0
  FrozenError = begin # rubocop:disable Naming/ConstantName
    # :nocov:
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.5.0')
      Class.new(::FrozenError)
    else
      Class.new(::RuntimeError)
    end
    # :nocov:
  end

  # @see Qonfig::Settings
  # @see Qonfig::DataSet
  #
  # @api public
  # @since 0.1.0
  # @version 0.19.0
  FrozenSettingsError = Class.new(FrozenError)

  # @see Qonfig::Commands::Instantiation::ValuesFile
  #
  # @api public
  # @since 0.17.0
  IncompatibleDataStructureError = Class.new(Error)

  # @see Qonfig::Commands::Definition::LoadFromYAML
  #
  # @api public
  # @since 0.2.0
  IncompatibleYAMLStructureError = Class.new(IncompatibleDataStructureError)

  # @see Qonfig::Commands::Definition::LoadFromJSON
  #
  # @api public
  # @since 0.5.0
  IncompatibleJSONStructureError = Class.new(IncompatibleDataStructureError)

  # @see Qonfig::Commands::Definition::LoadFromSelf
  # @see Qonfig::Commands::Definition::ExposeSelf
  #
  # @api public
  # @since 0.15.0
  IncompatibleEndDataStructureError = Class.new(IncompatibleDataStructureError)

  # @see Qonfig::Loaders::YAML
  #
  # @api public
  # @since 0.2.0
  FileNotFoundError = Class.new(Errno::ENOENT)

  # @see Qonfig::Commands::Definition::LoadFromSelf
  # @see Qonfig::Loaders::EndData
  #
  # @api public
  # @since 0.2.0
  SelfDataNotFoundError = Class.new(Error)

  # @see Qonfig::Loaders::JSON
  # @see Qonfig::Loaders::Dynamic
  #
  # @api public
  # @since 0.17.0
  JSONLoaderParseError = Class.new(::JSON::ParserError)

  # @see Qonfig::Loaders::YAML
  # @see Qonfig::Loaders::Dynamic
  #
  # @api public
  # @since 0.17.0
  # @version 0.27.0
  YAMLLoaderParseError = Class.new(::YAML::Exception)

  # @see Qonfig::Loaders::Dynamic
  #
  # @api public
  # @since 0.17.0
  DynamicLoaderParseError = Class.new(Error)

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

  # @see Qonfig::Commands::Definition::ExposeYAML
  #
  # @api public
  # @since 0.7.0
  ExposeError = Class.new(Error)

  # @see Qonfig::Loaders
  #
  # @api public
  # @since 0.15.0
  UnsupportedLoaderFormatError = Class.new(Error)

  # @see Qonfig::Plugin::TOMLFormat
  #
  # @api public
  # @since 0.12.0
  UnresolvedPluginDependencyError = Class.new(PluginError)

  # @see Qonfig::Imports::Abstract
  #
  # @api public
  # @since 0.18.0
  IncompatibleImportedConfigError = Class.new(ArgumentError)

  # @see Qonfig::Imports::DirectKey
  #
  # @api public
  # @since 0.18.0
  IncorrectImportKeyError = Class.new(ArgumentError)

  # @see Qonfig::Imports::Abstract
  #
  # @api public
  # @since 0.18.0
  IncorrectImportPrefixError = Class.new(ArgumentError)

  # @see Qonfig::Imports::Mappings
  #
  # @api public
  # @since 0.18.0
  IncorrectImportMappingsError = Class.new(ArgumentError)
end
