# frozen_string_literal: true

module Qonfig
  module Loaders
    module YAML
      class << self
        def load(data)
          ::YAML.load(ERB.new(data).result)
        end

        def load_file(file_path)
          load(::File.read(file_path))
        end
      end
    end
  end
end
