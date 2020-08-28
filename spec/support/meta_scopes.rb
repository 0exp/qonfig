# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:example, :plugin) do |example|
    if SpecSupport.test_plugins?
      case example.metadata[:plugin]
      when :toml
        require 'toml-rb'
        Qonfig.plugin(:toml)
      when :pretty_print
        Qonfig.plugin(:pretty_print)
      when :vault
        require 'vault'
        Qonfig.plugin(:vault)
      end

      example.call
    end
  end
end
