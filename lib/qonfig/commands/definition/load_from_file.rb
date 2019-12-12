# frozen_string_literal: true

# @api private
# @since 0.24.0
class Qonfig::Commands::Definition::LoadFromFile < Qonfig::Commands::Base
  # @since 0.24.0
  self.inheritable = true

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
  def initialize(file_path, strict:, format:); end

  # @param data_set [Qonfig::DataSet]
  # @param settings [Qonfig::Settings]
  # @return [void]
  #
  # @api private
  # @since 0.24.0
  def call(data_set, settings); end
end
