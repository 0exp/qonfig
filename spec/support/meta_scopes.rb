# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:example, :plugin) do |example|
    example.call if SpecSupport.test_plugins?
  end
end
