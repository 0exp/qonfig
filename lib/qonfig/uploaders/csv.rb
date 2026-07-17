# frozen_string_literal: true

# @api private
# @since 0.25.0
class Qonfig::Uploaders::CSV < Qonfig::Uplaoders::Base
  # @return [String]
  #
  # @api private
  # @since 0.25.0
  FILE_OPENING_MODE = 'w'

  # @return [Hash<Symbol,Any>]
  #
  # @api private
  # @since 0.25.0
  DEFAULT_OPTIONS = {
    col_sep: '',
    row_sep: :auto,
    quote_char: '"',
    field_size_limit: nil,
    converters: nil,
    unconverted_fields: nil,
    headers: false,
    return_headers: false,
    write_headers: nil,
    header_converters: nil,
    skip_blanks: false,
    force_quotes: false,
    skip_lines: nil,
    liberal_parsing: false,
    internal_encoding: nil,
    external_encoding: nil,
    encoding: nil,
    nil_value: nil,
    empty_value: '',
    quote_empty: true,
    write_converters: nil,
    write_nil_value: nil,
    write_empty_value: '',
    strip: false
  }.freeze

  class << self
    # @param settings [Qonfig::Settings]
    # @param value_processor [Block]
    # @option path [String, Pathname]
    # @option options [Hash<Symbol|String,Any>]
    # @return [void]
    #
    # @api private
    # @since 0.11.0
    def upload(settings, path:, options: self::DEFAULT_OPTIONS, &value_processor)
      ::CSV.open(path, FILE_OPENING_MODE, **options) do |csv_descriptor|
        # TODO: realize
      end
    end
  end
end
