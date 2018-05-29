# Qonfig &middot; [![Gem Version](https://badge.fury.io/rb/qonfig.svg)](https://badge.fury.io/rb/qonfig) [![Build Status](https://travis-ci.org/0exp/qonfig.svg?branch=master)](https://travis-ci.org/0exp/qonfig) [![Coverage Status](https://coveralls.io/repos/github/0exp/qonfig/badge.svg?branch=master)](https://coveralls.io/github/0exp/qonfig?branch=master)

Config. Defined as a class. Used as an instance. Support for inheritance and composition.
Lazy instantiation. Thread-safe. Command-style DSL. Extremely simple to define. Extremely simple to use. That's all.

## Installation

```ruby
gem 'qonfig'
```

```shell
$ bundle install
# --- or ---
$ gem install 'qonfig'
```

```ruby
require 'qonfig'
```

## Usage

- [Definition and Access](#definition-and-access)
- [Configuration](#configuration)
- [Inheritance](#inheritance)
- [Composition](#composition)
- [Hash representation](#hash-representation)
- [State freeze](#state-freeze)
- [Reload](#reload)
- [Load from YAML file](#load-from-yaml-file)
- [Load from self](#load-from-self)

---

### Definition and Access

```ruby
class Config < Qonfig::DataSet
  # nil by default
  setting :project_id

  # nested setting
  setting :vendor_api do
    setting :host, 'app.service.com'
  end

  setting :enable_graphql, false

  # nested setting reopening
  setting :vendor_api do
    setting :user, 'test_user'
  end
end

config = Config.new

# get option value via method
config.settings.project_id # => nil
config.settings.vendor_api.host # => 'app.service.com'
config.settings.vendor_api.user # => 'test_user'
config.settings.enable_graphql # => false

# get option value via index (with indifferent access)
config.settings[:project_id] # => nil
config.settings[:vendor_api][:host] # => 'app.service.com'
config.settings[:vendor_api][:user] # => 'test_user'
config.settings[:enable_graphql] # => false

# get option value via index (with indifferent access)
config.settings['project_id'] # => nil
config.settings['vendor_api']['host'] # => 'app.service.com'
config.settings['vendor_api']['user'] # => 'test_user'
config.settings['enable_graphql'] # => false

# get option value directly via index (with indifferent access)
config['project_id'] # => nil
config['enable_graphql'] # => false
config[:project_id] # => nil
config[:enable_graphql] # => false

# get option value with Hash#dig manner (fails when the required key does not exist)
config.dig(:vendor_api, :host) # => 'app.service.com' # (key exists)
config.dig(:vendor_api, :port) # => Qonfig::UnknownSettingError # (key does not exist)
```

---

### Configuration

```ruby
class Config < Qonfig::DataSet
  setting :testing do
    setting :engine, :rspec
    setting :parallel, true
  end

  setting :geo_api do
    setting :provider, :google_maps
  end

  setting :enable_middlewares, false
end

config = Config.new

# configure via proc
config.configure do |conf|
  conf.enable_middlewares = true
  conf.geo_api.provider = :yandex_maps
  conf.testing.engine = :mini_test
end

# configure via settings object (by option name)
config.settings.enable_middlewares = false
config.settings.geo_api.provider = :apple_maps
config.settings.testing.engine = :ultra_test

# configure via settings object (by setting key)
config.settings[:enable_middlewares] = true
config.settings[:geo_api][:provider] = :rambler_maps
config.settings[:testing][:engine] = :mega_test

# instant configuration via proc
config = Config.new do |conf|
  conf.enable_middlewares = false
  conf.geo_api.provider = :amazon_maps
  conf.testing.engine = :crypto_test
end
```

---

### Inheritance

```ruby
class CommonConfig < Qonfig::DataSet
  setting :uploader, :fog
end

class ProjectConfig < CommonConfig
  setting :auth_provider, :github
end

project_config = ProjectConfig.new

# inherited setting
project_config.settings.uploader # => :fog

# own setting
project_config.settings.auth_provider # => :github
```

---

### Composition

```ruby
class SharedConfig < Qonfig::DataSet
  setting :logger, Logger.new
end

class ServerConfig < Qonfig::DataSet
  setting :port, 12345
  setting :address, '0.0.0.0'
end

class DatabaseConfig < Qonfig::DataSet
  setting :user, 'test'
  setting :password, 'testpaswd'
end

class ProjectConfig < Qonfig::DataSet
  compose SharedConfig

  setting :server do
    compose ServerConfig
  end

  setting :db do
    compose DatabaseConfig
  end
end

project_config = ProjectConfig.new

# fields from SharedConfig
project_config.settings.logger # => #<Logger:0x66f57048>

# fields from ServerConfig
project_config.settings.server.port # => 12345
project_config.settings.server.address # => '0.0.0.0'

# fields from DatabaseConfig
project_config.settings.db.user # => 'test'
project_config.settings.db.password # => 'testpaswd'
```

---

### Hash representation

```ruby
class Config < Qonfig::DataSet
  setting :serializers do
    setting :json do
      setting :engine, :ok
    end

    setting :hash do
      setting :engine, :native
    end
  end

  setting :adapter do
    setting :default, :memory_sync
  end

  setting :logger, Logger.new(STDOUT)
end

Config.new.to_h

{
  "serializers": {
    "json" => { "engine" => :ok },
    "hash" => { "engine" => :native },
  },
  "adapter" => { "default" => :memory_sync },
  "logger" => #<Logger:0x4b0d79fc>
}
```

---

### Reload

```ruby
class Config < Qonfig::DataSet
  setting :db do
    setting :adapter, 'postgresql'
  end

  setting :logger, Logger.new(STDOUT)
end

config = Config.new

config.settings.db.adapter # => 'postgresql'
config.settings.logger # => #<Logger:0x00007ff9>

config.configure { |conf| conf.logger = nil } # redefine some settings (will be reloaded)

# re-define and append settings
class Config
  setting :db do
    setting :adapter, 'mongoid' # re-define defaults
  end

  setting :enable_api, false # append new setting
end

# reload settings
config.reload!

config.settings.db.adapter # => 'mongoid'
config.settings.logger # => #<Logger:0x00007ff9> (reloaded from defaults)
config.enable_api # => false (new setting)

# reload with instant configuration
config.reload! do |conf|
  conf.enable_api = true # changed instantly
end

config.settings.db.adapter # => 'mongoid'
config.settings.logger = # => #<Logger:0x00007ff9>
config.settings.enable_api # => true # value from instant change
```

---

### State freeze

```ruby
class Config < Qonfig::DataSet
  setting :logger, Logger.new(STDOUT)
  setting :worker, :sidekiq
  setting :db do
    setting :adapter, 'postgresql'
  end
end

config = Config.new
config.freeze!

config.settings.logger = Logger.new(StringIO.new) # => Qonfig::FrozenSettingsError
config.settings.worker = :que # => Qonfig::FrozenSettingsError
config.settings.db.adapter = 'mongoid' # => Qonfig::FrozenSettingsError

config.reload! # => Qonfig::FrozenSettingsError
```

---

### Load from YAML file

```yaml
<!-- travis.yml -->
sudo: false
language: ruby
rvm:
  - ruby-head
  - jruby-head
```

```yaml
<!-- project.yml -->
enable_api: false
Sidekiq/Scheduler:
  enable: true
```

```yaml
<!-- ruby_data.yml -->
version: <%= RUBY_VERSION %>
platform: <%= RUBY_PLATFORM %>
```

```ruby
class Config < Qonfig::DataSet
  setting :ruby do
    load_from_yaml 'ruby_data.yml'
  end

  setting :travis do
    load_from_yaml 'travis.yml'
  end

  load_from_yaml 'project.yml'
end

config = Config.new

config.settings.travis.sudo # => false
config.settings.travis.language # => 'ruby'
config.settings.travis.rvm # => ['ruby-head', 'jruby-head']
config.settings.enable_api # => false
config.settings['Sidekiq/Scheduler']['enable'] #=> true
config.settings.ruby.version # => '2.5.1'
config.settings.ruby.platform # => 'x86_64-darwin17'
```

---

### Load from self

```ruby
class Config < Qonfig::DataSet
  load_from_self # on the root

  setting :clowd do
    load_from_self # nested
  end
end

config = Config.new

# on the root
config.settings.ruby_version # => '2.5.1'
config.settings.secret_key # => 'top-mega-secret'
config.settings.api_host # => 'super.puper-google.com'
config.settings.connection_timeout.seconds # => 10
config.settings.connection_timeout.enabled # => false

# nested
config.settings.nested.ruby_version # => '2.5.1'
config.settings.nested.secret_key # => 'top-mega-secret'
config.settings.nested.api_host # => 'super.puper-google.com'
config.settings.nested.connection_timeout.seconds # => 10
config.settings.nested.connection_timeout.enabled # => false

__END__

ruby_version: <%= RUBY_VERSION %>
secret_key: top-mega-secret
api_host: super.puper-google.com
connection_timeout:
   seconds: 10
   enabled: false
```

---

## Contributing

- Fork it ( https://github.com/0exp/qonfig/fork )
- Create your feature branch (`git checkout -b feature/my-new-feature development`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin feature/my-new-feature`)
- Create new Pull Request

## License

Released under MIT License.

## Authors

[Rustam Ibragimov](https://github.com/0exp)
