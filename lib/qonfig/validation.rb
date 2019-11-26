# frozen_string_literal: true

# @api private
# @since 0.19.0
module Qonfig::Validation
  require_relative 'validation/validators'
  require_relative 'validation/collections'
  require_relative 'validation/building'
  require_relative 'validation/composite'
  require_relative 'validation/dsl'

  # 1. базовый валидатор для всего со всеми настройками
  # 2. коллекция классов валидаторов - глобальная И чисто отдельная для каждого класса
  # 3. коллекция инстансов валидаторов (для каждого класса - своя)
  # 4. валидатор-раннер, который инвокает валидаторы и проверяет что все валидное
end
