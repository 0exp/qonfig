# Qonfig &middot; [![Gem Version](https://badge.fury.io/rb/qonfig.svg)](https://badge.fury.io/rb/qonfig) [![Build Status](https://travis-ci.org/0exp/qonfig.svg?branch=master)](https://travis-ci.org/0exp/qonfig) [![Coverage Status](https://coveralls.io/repos/github/0exp/qonfig/badge.svg?branch=master)](https://coveralls.io/github/0exp/qonfig?branch=master)

Config. Defined as a class. Used as an instance. Support for inheritance and composition.
Lazy instantiation. Command-style DSL. Extremely simple to define. Extremely simple to use. That's all.

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

---

### Definition and Access

```ruby
class Config < Qonfig::DataSet
  # nil by default
  setting :project_id

  # nested setting
  setting :vendor_api do
    setting :host, 'app.service.com'
    setting :port, 12345
  end

  setting :enable_graphql, false

  # nested setting reopening
  setting :vendor_api do
    setting :user, 'test_user'
    setting :password, 'test_password'
  end
end

config = Config.new

config.settings.project_id # => nil
config.settings.vendor_api.host # => 'app.service.com'
config.settings.vendor_api.port # => 12345
config.settings.vendor_api.user # => 'test_user'
config.settings.vendor_api.password # => 'test_password'
config.settings.enable_graphql # => false

config.settings[:project_id] # => nil
config.settings[:vendor_api][:host] # => 'app.service.com'
config.settings[:vendor_api][:port] # => 12345
config.settings[:vendor_api][:user] # => 'test_user'
config.settings[:vendor_api][:password] # => 'test_password'
config.settings[:enable_graphql] # => false
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
    setting :default: :memory_sync
  end

  setting :logger, Logger.new(STDOUT)
end

Config.new.to_h

{
  serializers: {
    json: { engine: :ok },
    hash: { engine: :native },
  },
  adapter: { default: :memory_sync },
  logger: #<Logger:0x4b0d79fc>
}
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
```

---

## License

Released under MIT License.

## Authors

[Rustam Ibragimov](https://github.com/0exp)
