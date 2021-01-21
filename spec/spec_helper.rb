# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
require "simplecov-lcov"

require 'pry'
require 'securerandom'

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.lcov_file_name = 'lcov.info'
  c.output_directory = 'coverage'
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::LcovFormatter,
])

SimpleCov.minimum_coverage(100) if !!ENV['FULL_TEST_COVERAGE_CHECK']
SimpleCov.enable_coverage(:branch)
SimpleCov.enable_coverage(:line)
SimpleCov.start

require 'qonfig'

require_relative 'support/spec_support'
require_relative 'support/meta_scopes'

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.order = :random
  config.disable_monkey_patching!
  config.expose_dsl_globally = true
  config.shared_context_metadata_behavior = :apply_to_host_groups
  Kernel.srand config.seed
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  Thread.abort_on_exception = true

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
