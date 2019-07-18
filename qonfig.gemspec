# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qonfig/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = '>= 2.3.8'

  spec.name        = 'qonfig'
  spec.version     = Qonfig::VERSION
  spec.authors     = ['Rustam Ibragimov']
  spec.email       = ['iamdaiver@icloud.com']
  spec.summary     = 'Config object'
  spec.description = 'Config. Defined as a class. Used as an instance. ' \
                     'Support for inheritance and composition. ' \
                     'Lazy instantiation. Thread-safe. Command-style DSL. ' \
                     'Extremely simple to define. Extremely simple to use. That\'s all.'
  spec.homepage    = 'https://github.com/0exp/qonfig'
  spec.license     = 'MIT'

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_development_dependency 'coveralls',        '~> 0.8'
  spec.add_development_dependency 'simplecov',        '~> 0.16'
  spec.add_development_dependency 'rspec',            '~> 3.8'
  spec.add_development_dependency 'armitage-rubocop', '~> 0.71'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
end
