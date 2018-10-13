# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop'
require 'rubocop-rspec'
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  config_path = File.expand_path(File.join('.rubocop.yml'), __dir__)

  t.options = ['--config', config_path]
  t.requires << 'rubocop-rspec'
end

RSpec::Core::RakeTask.new(:rspec)

task default: :rspec
