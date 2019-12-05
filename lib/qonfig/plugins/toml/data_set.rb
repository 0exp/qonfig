# frozen_string_literal: true

# @api public
# @since 0.12.0
class Qonfig::DataSet
  # @option path [String]
  # @option options [Hash<Symbol,Any>] Nothing, just for compatability and consistency
  # @param value_processor [Block]
  # @return [void]
  #
  # @api public
  # @since 0.12.0
  def save_to_toml(path:, options: Qonfig::Uploaders::TOML::DEFAULT_OPTIONS, &value_processor)
    thread_safe_access do
      Qonfig::Uploaders::TOML.upload(settings, path: path, options: options, &value_processor)
    end
  end
  alias_method :dump_to_toml, :save_to_toml

  # @param file_path [String]
  # @option strict [Boolean]
  # @option expose [NilClass, String, Symbol] Environment key
  # @param configuration [Block]
  # @return [void]
  #
  # @see Qonfig::DataSet#load_from_file
  #
  # @api public
  # @since 0.17.0
  # @version 0.21.0
  def load_from_toml(file_path, strict: true, expose: nil, &configuration)
    load_from_file(file_path, format: :toml, strict: strict, expose: expose, &configuration)
  end
end
