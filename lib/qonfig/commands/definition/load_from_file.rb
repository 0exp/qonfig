# frozen_string_literal: true

# @api private
# @since 0.24.0
class Qonfig::Commands::Definition::LoadFromFile < Qonfig::Commands::Base
  # @since 0.24.0
  self.inheritable = true

  # @return [Symbol]
  #
  # @api private
  # @since 0.24.0
  SELF_FILE_PATH = :self

  # @return [String, Pathname]
  #
  # @api private
  # @since 0.24.0
  attr_reader :file_path

  # @return [Boolean]
  #
  # @api private
  # @since 0.24.0
  attr_reader :strict

  # @return [String, Symbol]
  #
  # @api private
  # @since 0.24.0
  attr_reader :format

  # @param file_path [String, Pathname]
  # @option strcit [Boolean]
  # @option format [String, Symbol]
  # @return [void]
  #
  # @api private
  # @since 0.24.0
  def initialize(file_path, strict: true, format: :dynamic)
    unless format.is_a?(String) || format.is_a?(Symbol)
      raise Qonfig::ArgumentError, 'Formad should be a type of string or symbol'
    end

    unless file_path.is_a?(String) || file_path.is_a?(Pathname) || file_path == SELF_FILE_PATH
      raise Qonfig::ArgumentError, 'Incorrect file path'
    end

    unless strict.is_a?(TrueClass) || strict.is_a?(FalseClass)
      raise Qonfig::ArgumentError, ':strict should be a type of boolean'
    end

    @file_path = file_path
    @strict = strict
    @format = format.tap { Qonfig::Loaders.resolve(format) }
  end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.24.0
  def call(data_set, settings)
    settings_data = Qonfig::Loaders.resolve(format).load_file(file_path, fail_on_unexist: strict)

    raise(
      Qonfig::IncompatibleDataStructureError,
      'Setting values should be represented as a hash-like structure'
    ) unless settings_data.is_a?(Hash)
  end
end
