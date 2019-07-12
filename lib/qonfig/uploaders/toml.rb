# frozen_string_literal: true

# @api private
# @since 0.12.0
class Qonfig::Uploaders::TOML < Qonfig::Uploaders::File
  class << self
    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol,Any>]
    # @param value_processor [Block]
    # @return [String]
    #
    # @api private
    # @since 0.12.0
    def represent_settings(settings, options, &value_processor)
      settings_hash =
        if block_given?
          settings.__to_hash__(transform_value: value_processor)
        else
          settings.__to_hash__
        end

      begin
        # NOTE: баг содержится в сортировщике ключей вложенных ключей
        #  { a: 1, 'b' => 2 } - упадет
        #  { a: 1, b: 2 } - не упадет
        #  { 'a' => 1, 'b' => 2 } - не упадет
        #  падает с эксепшном сравнения "Не могу сравнить символ со строкой"
        #  думаю, надо жоска приводить все ключи к строкам, сделать PR
        ::TomlRB.dump(settings_hash)
      rescue => error
        binding.pry
      end
    end
  end
end
