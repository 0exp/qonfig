# Qonfig &middot; [![Gem Version](https://badge.fury.io/rb/qonfig.svg)](https://badge.fury.io/rb/qonfig) [![Build Status](https://travis-ci.org/0exp/qonfig.svg?branch=master)](https://travis-ci.org/0exp/qonfig) [![Coverage Status](https://coveralls.io/repos/github/0exp/qonfig/badge.svg?branch=master)](https://coveralls.io/github/0exp/qonfig?branch=master)

Config. Defined as a class. Used as an instance. Support for inheritance and composition.
Lazy instantiation. Thread-safe. Command-style DSL. Validation layer. Support for **YAML**, **TOML**, **JSON**, **\_\_END\_\_**, **ENV**.
Extremely simple to define. Extremely simple to use. That's all? **NOT** :)

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

- [Definition](#definition)
  - [Definition and Settings Access](#definition-and-access)
  - [Configuration](#configuration)
  - [Inheritance](#inheritance)
  - [Composition](#composition)
  - [Hash representation](#hash-representation)
  - [Smart Mixin](#smart-mixin) (`Qonfig::Configurable`)
- [Interaction](#interaction)
  - [Iteration over setting keys](#iteration-over-setting-keys) (`#each_setting`, `#deep_each_setting`)
  - [Config reloading](#config-reloading) (reload config definitions and option values)
  - [Clear options](#clear-options) (set to nil)
  - [State freeze](#state-freeze)
  - [Settings as Predicates](#settings-as-predicates)
- [Validation](#validation)
  - [Key search pattern](#key-search-pattern)
  - [Proc-based validation](#proc-based-validation)
  - [Method-based validation](#method-based-validation)
  - [Predefined validations](#predefined-validations)
- [Work with files](#work-with-files)
  - [Load from YAML file](#load-from-yaml-file)
  - [Expose YAML](#expose-yaml) (`Rails`-like environment-based YAML configs)
  - [Load from JSON file](#load-from-json-file)
  - [Load from ENV](#load-from-env)
  - [Load from \_\_END\_\_](#load-from-__end__) (aka `load_from_self`)
  - [Save to JSON file](#save-to-json-file) (`save_to_json`)
  - [Save to YAML file](#save-to-yaml-file) (`save_to_yaml`)
- [Plugins](#plugins)
  - [toml](#plugins-toml) (provides `load_from_toml`, `save_to_toml`, `expose_toml`)
---

## Definition

### Definition and Access

```ruby
# --- definition ---
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

config = Config.new # your configuration object instance

# --- setting access ---

# get option value via method
config.settings.project_id # => nil
config.settings.vendor_api.host # => 'app.service.com'
config.settings.vendor_api.user # => 'test_user'
config.settings.enable_graphql # => false

# get option value via index (with indifferent (string / symbol / mixed) access)
config.settings[:project_id] # => nil
config.settings[:vendor_api][:host] # => 'app.service.com'
config.settings[:vendor_api][:user] # => 'test_user'
config.settings[:enable_graphql] # => false

# get option value via index (with indifferent (string / symbol / mixed) access)
config.settings['project_id'] # => nil
config.settings['vendor_api']['host'] # => 'app.service.com'
config.settings['vendor_api']['user'] # => 'test_user'
config.settings['enable_graphql'] # => false

# get option value directly via index (with indifferent access)
config['project_id'] # => nil
config['enable_graphql'] # => false
config[:project_id] # => nil
config[:enable_graphql] # => false

# get option value in Hash#dig manner (and fail when the required key does not exist)
config.dig(:vendor_api, :host) # => 'app.service.com' # (key exists)
config.dig(:vendor_api, :port) # => Qonfig::UnknownSettingError # (key does not exist)

# get a hash slice of setting options (and fail when the required key does not exist)
config.slice(:vendor_api) # => { 'vendor_api' => { 'host' => 'app_service', 'user' => 'test_user' } }
config.slice(:vendor_api, :user) # => { 'user' => 'test_user' }
config.slice(:project_api) # => Qonfig::UnknownSettingError # (key does not exist)
config.slice(:vendor_api, :port) # => Qonfig::UnknownSettingError # (key does not exist)

# get value from the slice of setting options using the given key set (and fail when the required key does not exist) (works in slice manner)
config.slice_value(:vendor_api) # => { 'host' => 'app_service', 'user' => 'test_user' }
config.slice_value(:vendor_api, :user) # => 'test_user'
config.slice_value(:project_api) # => Qonfig::UnknownSettingError # (key does not exist)
config.slice_value(:vendor_api, :port) # => Qonfig::UnknownSettingError # (key does not exist)
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

# using a hash
config = Config.new(
  testing: { engine: :mini_test, parallel: false },
  geo_api: { provider: :rambler_maps },
  enable_middlewares: true
)
config.configure(enable_middlewares: false)

# using both hash and proc (proc has higher priority)
config = Config.new(enable_middlewares: true) do |conf|
  conf.testing.parallel = true
end

config.configure(geo_api: { provider: nil }) do |conf|
  conf.testing.engine = :rspec
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

### Smart Mixin

- class-level:
  - `.configuration` - settings definitions;
  - `.configure` - configuration;
  - `.config` - config object;
  - settings definitions are inheritable;
- instance-level:
  - `#configure` - configuration;
  - `#config` - config object;
  - `#shared_config` - class-level config object;

```ruby
# --- usage ---

class Application
  # make configurable
  include Qonfig::Configurable

  configuration do
    setting :user
    setting :password
  end
end

app = Application.new

# class-level config
Application.config.settings.user # => nil
Application.config.settings.password # => nil

# instance-level config
app.config.settings.user # => nil
app.config.settings.password # => nil

# access to the class level config from an instance
app.shared_config.settings.user # => nil
app.shared_config.settings.password # => nil

# class-level configuration
Application.configure do |conf|
  conf.user = '0exp'
  conf.password = 'test123'
end

# instance-level configuration
app.configure do |conf|
  conf.user = 'admin'
  conf.password = '123test'
end

# class has own config object
Application.config.settings.user # => '0exp'
Application.config.settings.password # => 'test123'

# instance has own config object
app.config.settings.user # => 'admin'
app.config.settings.password # => '123test'

# access to the class level config from an instance
app.shared_config.settings.user # => '0exp'
app.shared_config.settings.password # => 'test123'

# and etc... (all Qonfig-related features)
```

```ruby
# --- inheritance ---

class BasicApplication
  # make configurable
  include Qonfig::Configurable

  configuration do
    setting :user
    setting :pswd
  end

  configure do |conf|
    conf.user = 'admin'
    conf.pswd = 'admin'
  end
end

class GeneralApplication < BasicApplication
  # extend inherited definitions
  configuration do
    setting :db do
      setting :adapter
    end
  end

  configure do |conf|
    conf.user = '0exp' # .user inherited from BasicApplication
    conf.pswd = '123test' # .pswd inherited from BasicApplication
    conf.db.adapter = 'pg'
  end
end

BasicApplication.config.to_h
{ 'user' => 'admin', 'pswd' => 'admin' }

GeneralApplication.config.to_h
{ 'user' => '0exp', 'pswd' => '123test', 'db' => { 'adapter' => 'pg' } }

# and etc... (all Qonfig-related features)
```

---


## Interaction

---

### Iteration over setting keys

- `#each_setting { |key, value| }`
  - iterates over the root setting keys;
- `#deep_each_setting { |key, value| }`
  - iterates over all setting keys (deep inside);
  - key object is represented as a string of `.`-joined keys;

```ruby
class Config < Qonfig::DataSet
  setting :db do
    setting :creds do
      setting :user, 'D@iVeR'
      setting :password, 'test123',
      setting :data, test: false
    end
  end

  setting :telegraf_url, 'udp://localhost:8094'
  setting :telegraf_prefix, 'test'
end

config = Config.new

# 1. #each_setting
config.each_setting { |key, value| { key => value } }
# result of each step:
{ 'db' => <Qonfig::Settings:0x00007ff8> }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }

# 2. #deep_each_setting
config.deep_each_setting { |key, value| { key => value } }
# result of each step:
{ 'db.creds.user' => 'D@iveR' }
{ 'db.creds.password' => 'test123' }
{ 'db.creds.data' => { test: false } }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

---

### Config reloading

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
config.settings.enable_api # => false (new setting)

# reload with instant configuration
config.reload!(db: { adapter: 'oracle' }) do |conf|
  conf.enable_api = true # changed instantly
end

config.settings.db.adapter # => 'oracle'
config.settings.logger = # => #<Logger:0x00007ff9>
config.settings.enable_api # => true # value from instant change
```

---

### Clear options

```ruby
class Config
  setting :database do
    setting :user
    setting :password
  end

  setting :web_api do
    setting :endpoint
  end
end

config = Config.new do |conf|
  conf.database.user = '0exp'
  conf.database.password = 'test123'

  conf.web_api.endpoint = '/api/'
end

config.settings.database.user # => '0exp'
config.settings.database.password # => 'test123'
config.settings.web_api.endpoint # => '/api'

# clear all options
config.clear!

config.settings.database.user # => nil
config.settings.database.password # => nil
config.settings.web_api.endpoint # => nil
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
config.clear! # => Qonfig::FrozenSettingsError
```

---

### Settings as Predicates

- predicate form: `?` at the end of setting name;
- `nil` and `false` setting values indicates `false`;
- other setting values indicates `true`;
- setting roots always returns `true`;

```ruby
class Config < Qonfig::DataSet
  setting :database do
    setting :user
    setting :host, 'google.com'

    setting :engine do
      setting :driver, 'postgres'
    end
  end
end

config = Config.new

# predicates
config.settings.database.user? # => false (nil => false)
config.settings.database.host? # => true ('google.com' => true)
config.settings.database.engine.driver? # => true ('postgres' => true)

# setting roots always returns true
config.settings.database? # => true
config.settings.database.engine? # => ture

config.configure do |conf|
  conf.database.user = '0exp'
  conf.database.host = false
  conf.database.engine.driver = true
end

# predicates
config.settings.database.user? # => true ('0exp' => true)
config.settings.database.host? # => false (false => false)
config.settings.database.engine.driver? # => true (true => true)
```

---

## Validation

Qonfig provides a lightweight DSL for defining validations and works in all cases when setting values are initialized or mutated.
Settings are validated as keys (matched with a [specific string pattern](#key-search-patern)).
You can validate both a set of keys and each key separately.
If you want to check the config object completely you can define a custom validation.

**Features**:

- is invoked on any mutation of any setting key
  - during dataset instantiation;
  - when assigning new values;
  - when calling `#reload!`;
  - when calling `#clear!`;

- provides special [key search pattern](#key-search-pattern) for matching setting key names;
- uses the [key search pattern](#key-search-pattern) for definging what the setting key should be validated;
- you can define your own custom validation logic and validate dataset instance completely;
- validation logic should return **truthy** or **falsy** value;

- supprots two validation techniques (**proc-based** and **dataset-method-based**)
  - **proc-based** (`setting validation`)
    ```ruby
      validate 'db.user' do |value|
        value.is_a?(String)
      end
    ```
  - **proc-based** (`dataset validation`)
    ```ruby
      validate do
        settings.user == User[1]
      end
    ```
  - **dataset-method-based** (`setting validation`)
    ```ruby
      validate 'db.user', by: :check_user

      def check_user(value)
        value.is_a?(String)
      end
    ```
  - **dataset-method-based** (`dataset validation`)
    ```ruby
      validate by: :check_config

      def check_config
        settings.user == User[1]
      end
    ```

- provides a set of standard validations:
  - `integer`
  - `float`
  - `numeric`
  - `big_decimal`
  - `boolean`
  - `string`
  - `symbol`
  - `text` (string or symbol)
  - `array`
  - `hash`
  - `proc`
  - `class`
  - `module`
  - `not_nil`

---

### Key search pattern

**Key search pattern** works according to the following rules:

- works in `RabbitMQ`-like key pattern ruleses;
- has a string format;
- nested configs are defined by a set of keys separated by `.`-symbol;
- if the setting key name at the current nesting level does not matter - use `*`;
- if both the setting key name and nesting level does not matter - use `#`
- examples:
  - `db.settings.user` - matches to `db.settings.user` setting;
  - `db.settings.*` - matches to all setting keys inside `db.settings` group of settings;
  - `db.*.user` - matches to all `user` setting keys at the first level of `db` group of settings;
  - `#.user` - matches to all `user` setting keys;
  - `service.#.password` - matches to all `password` setting keys at all levels of `service` group of settings;
  - `#` - matches to ALL setting keys;
  - `*` - matches to all setting keys at the root level;
  - and etc;

---

### Proc-based validation

- your proc should return truthy value or falsy value;
- how to validate setting keys:
  - define proc with attribute: `validate 'your.setting.path' do |value|; end`
  - proc will receive setting value;
- how to validate dataset instance:
  - define proc without setting key pattern: `validate do; end`

```ruby
class Config < Qonfig::DataSet
  setting :db do
    setting :user, 'D@iVeR'
    setting :password, 'test123'
  end

  setting :service do
    setting :address, 'google.ru'
    setting :protocol, 'https'

    setting :creds do
      seting :admin, 'D@iVeR'
    end
  end

  setting :enabled, false

  # validates:
  #   - db.password
  validate 'db.password' do |value|
    value.is_a?(String)
  end

  # validates:
  #   - service.address
  #   - service.protocol
  #   - service.creds.user
  validate 'service.#' do |value|
    value.is_a?(String)
  end

  # validates:
  #   - dataset instance
  validate do # NOTE: no setting key pattern
    settings.enabled == false
  end
end

config = Config.new
config.settings.db.password = 123 # => Qonfig::ValidationError (should be a string)
config.settings.service.address = 123 # => Qonfig::ValidationError (should be a string)
config.settings.service.protocol = :http # => Qonfig::ValidationError (should be a string)
config.settings.service.creds.admin = :billikota # => Qonfig::ValidationError (should be a string)
config.settings.enabled = true # => Qonfig::ValidationError (isnt `true`)
```

---

### Method-based validation

- method should return truthy value or falsy value;
- how to validate setting keys:
  - define validation: `validate 'db.*.user', by: :your_custom_method`;
  - define your method with attribute: `def your_custom_method(setting_value); end`
- how to validate config instance
  - define validation: `validate by: :your_custom_method`
  - define your method without attributes: `def your_custom_method; end`

```ruby
class Config < Qonfig::DataSet
  setting :services do
    setting :counts do
      setting :google, 2
      setting :rambler, 3
    end

    setting :minimals do
      setting :google, 1
      setting :rambler, 0
    end
  end

  setting :enabled, true

  # validates:
  #   - services.counts.google
  #   - services.counts.rambler
  #   - services.minimals.google
  #   - services.minimals.rambler
  validate 'services.#', by: :check_presence

  # validates:
  #   - dataset instance
  validate by: :check_state # NOTE: no setting key pattern

  def check_presence(value)
    value.is_a?(Numeric) && value > 0
  end

  def check_state
    settings.enabled.is_a?(TrueClass) || settings.enabled.is_a?(FalseClass)
  end
end

config = Config.new

config.settings.counts.google = 0 # => Qonfig::ValidationError (< 0)
config.settings.counts.rambler = nil # => Qonfig::ValidationError (should be a numeric)
config.settings.minimals.google = -1 # => Qonfig::ValidationError (< 0)
config.settings.minimals.rambler = 'no' # => Qonfig::ValidationError (should be a numeric)
config.settings.enabled = nil # => Qonfig::ValidationError (should be a boolean)
```

---

### Predefined validations

- DSL: `validate 'key.pattern', :predefned_validator`
- predefined validators:
  - `:not_nil`
  - `:integer`
  - `:float`
  - `:numeric`
  - `:big_decimal`
  - `:array`
  - `:hash`
  - `:string`
  - `:symbol`
  - `:text` (`string` or `symbol`)
  - `:boolean`
  - `:class`
  - `:module`
  - `:proc`

```ruby
class Config < Qonfig::DataSet
  setting :user
  setting :password

  setting :service do
    setting :provider
    setting :protocol
    setting :on_fail, -> { puts 'atata!' }
  end

  setting :ignorance, false

  validate 'user', :string
  validate 'password', :string
  validate 'service.provider', :text
  validate 'service.protocol', :text
  validate 'service.on_fail', :proc
  validate 'ignorance', :not_nil
end

config = Config.new do |conf|
  conf.user = 'D@iVeR'
  conf.password = 'test123'
  conf.service.provider = :google
  conf.service.protocol = :https
end # NOTE: all right :)

config.settings.ignorance = nil # => Qonfig::ValidationError (cant be nil)
```

---

## Work with files

### Load from YAML file

- supports `ERB`;
- `:strict` mode (fail behaviour when the required yaml file doesnt exist):
  - `true` (by default) - causes `Qonfig::FileNotFoundError`;
  - `false` - do nothing, ignore current command;

```yaml
# travis.yml

sudo: false
language: ruby
rvm:
  - ruby-head
  - jruby-head
```

```yaml
# project.yml

enable_api: false
Sidekiq/Scheduler:
  enable: true
```

```yaml
# ruby_data.yml

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

```ruby
# --- strict mode ---
class Config < Qonfig::DataSet
  setting :nonexistent_yaml do
    load_from_yaml 'nonexistent_yaml.yml', strict: true # true by default
  end

  setting :another_key
end

Config.new # => Qonfig::FileNotFoundError

# --- non-strict mode ---
class Config < Qonfig::DataSet
  settings :nonexistent_yaml do
    load_from_yaml 'nonexistent_yaml.yml', strict: false
  end

  setting :another_key
end

Config.new.to_h # => { "nonexistent_yaml" => {}, "another_key" => nil }
```

---

### Expose YAML

- load configurations from YAML file in Rails-like manner (with environments);
- works in `load_from_yaml` manner;
- `via:` - how an environment will be determined:
    - `:file_name`
        - load configuration from YAML file that have an `:env` part in it's name;
    - `:env_key`
        - load configuration from YAML file;
        - concrete configuration should be defined in the root key with `:env` name;
- `env:` - your environment name (must be a type of `String`, `Symbol` or `Numeric`);
- `strict:` - requires the existence of the file and/or key with the name of the used environment:
    - `true`:
        - file should exist;
        - root key with `:env` name should exist (if `via: :env_key` is used);
        - raises `Qonfig::ExposeError` if file does not contain the required env key (if `via: :env` key is used);
        - raises `Qonfig::FileNotFoundError` if the required file does not exist;
    - `false`:
        - file is not required;
        - root key with `:env` name is not required (if `via: :env_key` is used);

#### Environment is defined as a root key of YAML file

```yaml
# config/project.yml

default: &default
  enable_api_mode: true
  google_key: 12345
  window:
    width: 100
    height: 100

development:
  <<: *default

test:
  <<: *default
  sidekiq_instrumentation: false

staging:
  <<: *default
  google_key: 777
  enable_api_mode: false

production:
  google_key: asd1-39sd-55aI-O92x
  enable_api_mode: true
  window:
    width: 50
    height: 150
```

```ruby
class Config < Qonfig::DataSet
  expose_yaml 'config/project.yml', via: :env_key, env: :production # load from production env

  # NOTE: in rails-like application you can use this:
  expose_yaml 'config/project.yml', via: :env_key, env: Rails.env
end

config = Config.new

config.settings.enable_api_mode # => true (from :production subset of keys)
config.settings.google_key # => asd1-39sd-55aI-O92x (from :production subset of keys)
config.settings.window.width # => 50 (from :production subset of keys)
config.settings.window.height # => 150 (from :production subset of keys)
```

#### Environment is defined as a part of YAML file name

```yaml
# config/sidekiq.staging.yml

web:
  username: staging_admin
  password: staging_password
```

```yaml
# config/sidekiq.production.yml

web:
  username: urj1o2
  password: u192jd0ixz0
```

```ruby
class SidekiqConfig < Qonfig::DataSet
  # NOTE: file name should be described WITHOUT environment part (in file name attribute)
  expose_yaml 'config/sidekiq.yml', via: :file_name, env: :staging # load from staging env

  # NOTE: in rails-like application you can use this:
  expose_yaml 'config/sidekiq.yml', via: :file_name, env: Rails.env
end

config = SidekiqConfig.new

config.settings.web.username # => staging_admin (from sidekiq.staging.yml)
config.settings.web.password # => staging_password (from sidekiq.staging.yml)
```

---

### Load from JSON file

- `:strict` mode (fail behaviour when the required yaml file doesnt exist):
  - `true` (by default) - causes `Qonfig::FileNotFoundError`;
  - `false` - do nothing, ignore current command;

```json
// options.json

{
  "user": "0exp",
  "password": 12345,
  "rubySettings": {
    "allowedVersions": ["2.3", "2.4.2", "1.9.8"],
    "gitLink": null,
    "withAdditionals": false
  }
}
```

```ruby
class Config < Qonfig::DataSet
  load_from_json 'options.json'
end

config = Config.new

config.settings.user # => '0exp'
config.settings.password # => 12345
config.settings.rubySettings.allowedVersions # => ['2.3', '2.4.2', '1.9.8']
config.settings.rubySettings.gitLink # => nil
config.settings.rubySettings.withAdditionals # => false
```

```ruby
# --- strict mode ---
class Config < Qonfig::DataSet
  setting :nonexistent_json do
    load_from_json 'nonexistent_json.json', strict: true # true by default
  end

  setting :another_key
end

Config.new # => Qonfig::FileNotFoundError

# --- non-strict mode ---
class Config < Qonfig::DataSet
  settings :nonexistent_json do
    load_from_json 'nonexistent_json.json', strict: false
  end

  setting :another_key
end

Config.new.to_h # => { "nonexistent_json" => {}, "another_key" => nil }
```

---

### Load from ENV

- `:convert_values` (`false` by default):
  - `'t'`, `'T'`, `'true'`, `'TRUE'` - covnerts to `true`;
  - `'f'`, `'F'`, `'false'`, `'FALSE'` - covnerts to `false`;
  - `1`, `23` and etc - converts to `Integer`;
  - `1.25`, `0.26` and etc - converts to `Float`;
  - `1, 2, test`, `FALSE,Qonfig` (strings without quotes that contains at least one comma) -
    converts to `Array` with recursively converted values;
  - `'"please, test"'`, `"'test, please'"` (quoted strings) - converts to `String` without quotes;
- `:prefix` - load ENV variables which names starts with a prefix:
  - `nil` (by default) - empty prefix;
  - `Regexp` - names that match the regexp pattern;
  - `String` - names which starts with a passed string;
- `:trim_prefix` (`false` by default);

```ruby
# some env variables
ENV['QONFIG_BOOLEAN'] = 'true'
ENV['QONFIG_INTEGER'] = '0'
ENV['QONFIG_STRING'] = 'none'
ENV['QONFIG_ARRAY'] = '1, 2.5, t, f, TEST'
ENV['QONFIG_MESSAGE'] = '"Hello, Qonfig!"'
ENV['RUN_CI'] = '1'

class Config < Qonfig::DataSet
  # nested
  setting :qonfig do
    load_from_env convert_values: true, prefix: 'QONFIG' # or /\Aqonfig.*\z/i
  end

  setting :trimmed do
    load_from_env convert_values: true, prefix: 'QONFIG_', trim_prefix: true # trim prefix
  end

  # on the root
  load_from_env
end

config = Config.new

# customized
config.settings['qonfig']['QONFIG_BOOLEAN'] # => true ('true' => true)
config.settings['qonfig']['QONFIG_INTEGER'] # => 0 ('0' => 0)
config.settings['qonfig']['QONFIG_STRING'] # => 'none'
config.settings['qonfig']['QONFIG_ARRAY'] # => [1, 2.5, true, false, 'TEST']
config.settings['qonfig']['QONFIG_MESSAGE'] # => 'Hello, Qonfig!'
config.settings['qonfig']['RUN_CI'] # => Qonfig::UnknownSettingError

# trimmed (and customized)
config.settings['trimmed']['BOOLEAN'] # => true ('true' => true)
config.settings['trimmed']['INTEGER'] # => 0 ('0' => 0)
config.settings['trimmed']['STRING'] # => 'none'
config.settings['trimmed']['ARRAY'] # => [1, 2.5, true, false, 'TEST']
config.settings['trimmed']['MESSAGE'] # => 'Hello, Qonfig!'
config.settings['trimmed']['RUN_CI'] # => Qonfig::UnknownSettingError

# default
config.settings['QONFIG_BOOLEAN'] # => 'true'
config.settings['QONFIG_INTEGER'] # => '0'
config.settings['QONFIG_STRING'] # => 'none'
config.settings['QONFIG_ARRAY'] # => '1, 2.5, t, f, TEST'
config.settings['QONFIG_MESSAGE'] # => '"Hello, Qonfig!"'
config.settings['RUN_CI'] # => '1'
```

---

### Load from \_\_END\_\_

- aka `load_from_self`

```ruby
class Config < Qonfig::DataSet
  load_from_self # on the root

  setting :nested do
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

### Save to JSON file

- `#save_to_json` - represents config object as a json structure and saves it to a file:
  - uses native `::JSON.generate` under the hood;
  - writes new file (or rewrites existing file);
  - attributes:
    - `:path` - (required) - file path;
    - `:options` - (optional) - native `::JSON.generate` options (from stdlib):
      - `:indent` - `" "` by default;
      - `:space` - `" "` by default/
      - `:object_nl` - `"\n"` by default;
    - `&value_preprocessor` - (optional) - value pre-processor;

#### Without value preprocessing (standard usage)

```ruby
class AppConfig < Qonfig::DataSet
  setting :server do
    setting :address, 'localhost'
    setting :port, 12_345
  end

  setting :enabled, true
end

config = AppConfig.new

# NOTE: save to json file
config.save_to_json(path: 'config.json')
```

```json
{
 "sentry": {
  "address": "localhost",
  "port": 12345
 },
 "enabled": true
}
```

#### With value preprocessing and custom options

```ruby
class AppConfig < Qonfig::DataSet
  setting :server do
    setting :address, 'localhost'
    setting :port, 12_345
  end

  setting :enabled, true
  setting :dynamic, -> { 1 + 2 }
end

config = AppConfig.new

# NOTE: save to json file with custom options (no spaces / no new line / no indent; call procs)
config.save_to_json(path: 'config.json', options: { indent: '', space: '', object_nl: '' }) do |value|
  value.is_a?(Proc) ? value.call : value
end
```

```json
// no spaces / no new line / no indent / calculated "dynamic" setting key
{"sentry":{"address":"localhost","port":12345},"enabled":true,"dynamic":3}
```

---

### Save to YAML file

- `#save_to_yaml` - represents config object as a yaml structure and saves it to a file:
  - uses native `::Psych.dump` under the hood;
  - writes new file (or rewrites existing file);
  - attributes:
    - `:path` - (required) - file path;
    - `:options` - (optional) - native `::Psych.dump` options (from stdlib):
      - `:indentation` - `2` by default;
      - `:line_width` - `-1` by default;
      - `:canonical` - `false` by default;
      - `:header` - `false` by default;
      - `:symbolize_keys` - (non-native option) - `false` by default;
    - `&value_preprocessor` - (optional) - value pre-processor;

#### Without value preprocessing (standard usage)

```ruby
class AppConfig < Qonfig::DataSet
  setting :server do
    setting :address, 'localhost'
    setting :port, 12_345
  end

  setting :enabled, true
end

config = AppConfig.new

# NOTE: save to yaml file
config.save_to_yaml(path: 'config.yml')
```

```yaml
---
server:
  address: localhost
  port: 12345
enabled: true
```

#### With value preprocessing and custom options

```ruby
class AppConfig < Qonfig::DataSet
  setting :server do
    setting :address, 'localhost'
    setting :port, 12_345
  end

  setting :enabled, true
  setting :dynamic, -> { 5 + 5 }
end

config = AppConfig.new

# NOTE: save to yaml file with custom options (add yaml version header; call procs)
config.save_to_yaml(path: 'config.yml', options: { header: true }) do |value|
  value.is_a?(Proc) ? value.call : value
end
```

```yaml
# yaml version header / calculated "dynamic" setting key
%YAML 1.1
---
server:
  address: localhost
  port: 12345
enabled: true
dynamic: 10
```

---

### Plugins

```ruby
# --- show names of registered plugins ---
Qonfig.plugins # => array of strings

# --- load specific plugin ---
Qonfig.plugin(:plugin_name) # or Qonfig.plugin('plugin_name')
```

---

### Plugins: toml

- adds support for `toml` format ([specification](https://github.com/toml-lang/toml));
- depends on `toml-rb` gem ([link](https://github.com/emancu/toml-rb));
- supports TOML `0.4.0` format (dependency lock);
- provides `load_from_toml` (works in `load_from_yaml` manner ([doc](#load-from-yaml-file)));
- provides `save_to_toml` (works in `save_to_yaml` manner ([doc](#save-to-yaml-file))) (`toml-rb` has no native options);
- provides `expose_toml` (works in `expose_yaml` manner ([doc](#expose-yaml)));

```ruby
# 1) require external dependency
require 'toml-rb'

# 2) enable plugin
Qonfig.plugin(:toml)

# 3) use :)
```
---

## Roadmap

- distributed configuration server;
- support for Rails-like secrets;

## Contributing

- Fork it ( https://github.com/0exp/qonfig/fork )
- Create your feature branch (`git checkout -b feature/my-new-feature`)
- Commit your changes (`git commit -am 'Add some feature'`)
- Push to the branch (`git push origin feature/my-new-feature`)
- Create new Pull Request

## License

Released under MIT License.

## Authors

[Rustam Ibragimov](https://github.com/0exp)
