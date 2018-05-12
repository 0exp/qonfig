# frozen_string_literal: true

class Qonfig::NestedOption < Qonfig::Option
  def value
    @value.new.settings
  end
end
