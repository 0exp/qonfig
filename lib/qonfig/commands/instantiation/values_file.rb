# frozen_string_literal: true

# @api private
# @since 0.17.0
class Qonfig::Commands::Instantiation::ValuesFile < Qonfig::Commands::Base
  # @return [Symbol]
  #
  # @api private
  # @since 0.17.0
  SELF_LOCATED_FILE_DEFINITION = :self

  # @return [NilClass]
  #
  # @api private
  # @since 0.17.0
  NO_EXPOSE = nil

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  DEFAULT_STRICT_BEHAVIOR = false

  # @return [Symbol]
  #
  # @api private
  # @since 0.17.0
  DEFAULT_FORMAT = :dynamic

  # @return [String, Symbol]
  #
  # @api private
  # @since 0.17.0
  attr_reader :file_path

  # @return [String]
  #
  # @api private
  # @since 0.17.0
  attr_reader :caller_location

  # @return [String, Symbol]
  #
  # @api private
  # @since 0.17.0
  attr_reader :format

  # @return [Boolean]
  #
  # @api private
  # @since 0.17.0
  attr_reader :strict

  # @return [NilClass, String, Symbol]
  #
  # @api private
  # @since 0.17.0
  attr_reader :expose

  # @param file_path [String, Symbol]
  # @param caller_location [String]
  # @option format [String, Symbol]
  # @option strict [Boolean]
  # @option expose [NilClass, String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.17.0
  def initialize(
    file_path,
    caller_location,
    format: DEFAULT_FORMAT,
    strict: DEFAULT_STRICT_BEHAVIOR,
    expose: NO_EXPOSE
  )
    prevent_incompatible_attributes!(file_path, format, strict, expose)

    @file_path = file_path
    @caller_location = caller_location
    @format = format
    @strict = strict
    @expose = expose
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.17.0
  def call(data_set, settings)
    settings_values = load_settings_values
    return unless settings_values
    settings_values = (settings_values[expose.to_sym] || settings_values[expose.to_s]) if expose
    data_set.configure(settings_values) if settings_values
  end

  private

  # @return [Hash]
  #
  # @raise [Qonfig::IncompatibleDataStructureError]
  #
  # @api private
  # @since 0.17.0
  def load_settings_values
    (file_path == SELF_LOCATED_FILE_DEFINITION) ? load_from_self : load_from_file
  end

  # @return [Hash]
  #
  # @api private
  # @since 0.17.0
  def load_from_file
    Qonfig::Loaders.resolve(format).load_file(file_path, fail_on_unexist: strict).tap do |values|
      raise(
        Qonfig::IncompatibleDataStructureError,
        'Setting values must be a hash-like structure'
      ) unless values.is_a?(Hash)
    end
  end

  # @return [Hash]
  #
  # @api private
  # @since 0.17.0
  def load_from_self
    end_data = Qonfig::Loaders::EndData.extract(caller_location)

    Qonfig::Loaders.resolve(format).load(end_data).tap do |values|
      raise(
        Qonfig::IncompatibleDataStructureError,
        'Setting values must be a hash-like structure'
      ) unless values.is_a?(Hash)
    end
  rescue Qonfig::SelfDataNotFoundError => error
    raise(error) if strict
  end

  # @param file_path [String, Symbol]
  # @param format [String, Symbol]
  # @param strict [Boolean]
  # @param expose [NilClass, String, Symbol]
  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  # @raise [Qonfig::UnsupportedLoaderError]
  #
  # @api private
  # @since 0.17.0
  def prevent_incompatible_attributes!(file_path, format, strict, expose)
    unless file_path.is_a?(String) || file_path == SELF_LOCATED_FILE_DEFINITION
      raise Qonfig::ArgumentError, 'Incorrect file path'
    end

    unless format.is_a?(String) || format.is_a?(Symbol)
      raise Qonfig::ArgumentError, 'Format should be a symbol or a string'
    end

    # NOTE: try to resolve corresponding loader (and fail if cannot be resolved)
    Qonfig::Loaders.resolve(format)

    unless expose.nil? || expose.is_a?(Symbol) || expose.is_a?(String)
      raise Qonfig::ArgumentError, ':expose should be a string or a symbol (or nil)'
    end

    unless strict.is_a?(TrueClass) || strict.is_a?(FalseClass)
      raise Qonfig::ArgumentError, ':strict should be a type of boolean'
    end
  end
end
