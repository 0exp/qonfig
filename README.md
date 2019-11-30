# Qonfig &middot; [![Gem Version](https://badge.fury.io/rb/qonfig.svg)](https://badge.fury.io/rb/qonfig) [![Build Status](https://travis-ci.org/0exp/qonfig.svg?branch=master)](https://travis-ci.org/0exp/qonfig) [![Coverage Status](https://coveralls.io/repos/github/0exp/qonfig/badge.svg?branch=master)](https://coveralls.io/github/0exp/qonfig?branch=master)

Config. Defined as a class. Used as an instance. Support for inheritance and composition.
Lazy instantiation. Thread-safe. Command-style DSL. Validation layer. **DOT-NOTATION**! And pretty-print :) Support for **YAML**, **TOML**, **JSON**, **\_\_END\_\_**, **ENV**.
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
    - [access via method](#access-via-method)
    - [access via index-method \[\]](#access-via-index-method-)
    - [.dig](#dig)
    - [.slice](#slice)
    - [.slice_value](#slice_value)
    - [.subset](#subset)
  - [Configuration](#configuration)
    - [configure via proc](#configure-via-proc)
    - [configure via settings object (by option name)](#configure-via-settings-object-by-option-name)
    - [configure via settings object (by setting key)](#configure-via-settings-object-by-setting-key)
    - [instant configuration via proc](#instant-configuration-via-proc)
    - [using a hash](#using-a-hash)
    - [using both hash and proc](#using-both-hash-and-proc-proc-has-higher-priority)
  - [Inheritance](#inheritance)
  - [Composition](#composition)
  - [Hash representation](#hash-representation)
  - [Smart Mixin](#smart-mixin) (`Qonfig::Configurable`)
  - [Instantiation without class definition](#instantiation-without-class-definition) (`Qonfig::DataSet.build(&definitions)`)
- [Interaction](#interaction)
  - [Iteration over setting keys](#iteration-over-setting-keys) (`#each_setting`, `#deep_each_setting`)
  - [List of config keys](#list-of-config-keys) (`#keys`, `#root_keys`)
  - [Config reloading](#config-reloading) (reload config definitions and option values)
  - [Clear options](#clear-options) (set to `nil`)
  - [Frozen state](#frozen-state) (`.freeze_state!`, `#freeze!`, `#frozen?`)
  - [Settings as Predicates](#settings-as-predicates)
  - [Setting key existence](#setting-key-existence) (`#key?`/`#option?`/`#setting?`)
  - [Run arbitrary code with temporary settings](#run-arbitrary-code-with-temporary-settings) (`#with(configs = {}, &arbitrary_code)`)
- [Import settings / Export settings](#import-settings--export-settings)
  - [Import config settings](#import-config-settings) (`as instance methods`)
  - [Export config settings](#export-config-settings) (`as singleton methods`)
- [Validation](#validation)
  - [Introduction](#introduction)
  - [Key search pattern](#key-search-pattern)
  - [Proc-based validation](#proc-based-validation)
  - [Method-based validation](#method-based-validation)
  - [Predefined validations](#predefined-validations)
  - [Custom predefined validators](#custom-predefined-validators)
  - [Validation of potential setting values](#validation-of-potential-setting-values)
- [Work with files](#work-with-files)
  - **Setting keys definition**
    - [Load from YAML file](#load-from-yaml-file)
    - [Expose YAML](#expose-yaml) (`Rails`-like environment-based YAML configs)
    - [Load from JSON file](#load-from-json-file)
    - [Expose JSON](#expose-json) (`Rails`-like environment-based JSON configs)
    - [Load from ENV](#load-from-env)
    - [Load from \_\_END\_\_](#load-from-__end__) (aka `.load_from_self`)
    - [Expose \_\_END\_\_](#expose-__end__) (aka `.expose_self`)
  - **Setting values**
    - [Default setting values file](#default-setting-values-file)
    - [Load setting values from YAML file](#load-setting-values-from-yaml-file-by-instance)
    - [Load setting values from JSON file](#load-setting-values-from-json-file-by-instance)
    - [Load setting values from \_\_END\_\_](#load-setting-values-from-__end__-by-instance)
    - [Load setting values from file manually](#load-setting-values-from-file-manually-by-instance)
  - **Daily work**
    - [Save to JSON file](#save-to-json-file) (`#save_to_json`)
    - [Save to YAML file](#save-to-yaml-file) (`#save_to_yaml`)
- [Plugins](#plugins)
  - [toml](#plugins-toml) (support for `TOML` format)
  - [pretty_print](#plugins-pretty_print) (beautified/prettified console output)
- [Roadmap](#roadmap)
---

## Definition

- [Definition and Settings Access](#definition-and-access)
- [Configuration](#configuration)
- [Inheritance](#inheritance)
- [Composition](#composition)
- [Hash representation](#hash-representation)
- [Smart Mixin](#smart-mixin) (`Qonfig::Configurable`)

---

### Definition and Access

- `setting(name, value = nil)` - define setting with corresponding name and value;
- `setting(name) { setting(name, value = nil); ... }` - define nested settings OR reopen existing nested setting and define some new nested settings;
- `re_setting(name, value = nil)`, `re_setting(name) { ... }` - re-define existing setting (or define new if the original does not exist);
- accessing: [access via method](#access-via-method), [access via index-method \[\]](#access-via-index-method-),
  [.dig](#dig), [.slice](#slice), [.slice_value](#slice_value), [.subset](#subset);

```ruby
# --- definition ---
class Config < Qonfig::DataSet
  # nil by default
  setting :project_id

  # nested setting
  setting :vendor_api do
    setting :host, 'vendor.service.com'
  end

  setting :enable_graphql, false

  # nested setting reopening
  setting :vendor_api do
    setting :user, 'simple_user'
  end

  # re-definition of existing setting (drop the old - make the new)
  re_setting :vendor_api do
    setting :domain, 'api.service.com'
    setting :login, 'test_user'
  end

  # deep nesting
  setting :credentials do
    setting :user do
      setting :login, 'D@iVeR'
      setting :password, 'test123'
    end
  end
end

config = Config.new # your configuration object instance
```

#### access via method

```ruby
# get option value via method
config.settings.project_id # => nil
config.settings.vendor_api.domain # => 'app.service.com'
config.settings.vendor_api.login # => 'test_user'
config.settings.enable_graphql # => false
```

#### access via index-method []

- without dot-notation:

```ruby
# get option value via index (with indifferent (string / symbol / mixed) access)
config.settings[:project_id] # => nil
config.settings[:vendor_api][:domain] # => 'app.service.com'
config.settings[:vendor_api][:login] # => 'test_user'
config.settings[:enable_graphql] # => false

# get option value via index (with indifferent (string / symbol / mixed) access)
config.settings['project_id'] # => nil
config.settings['vendor_api']['domain'] # => 'app.service.com'
config.settings['vendor_api']['login'] # => 'test_user'
config.settings['enable_graphql'] # => false

# get option value directly via index (with indifferent access)
config['project_id'] # => nil
config['enable_graphql'] # => false
config[:project_id] # => nil
config[:enable_graphql] # => false
```

- with dot-notation:

```ruby
config.settings['vendor_api.domain'] # => 'app.service.com'
config.settings['vendor_api.login'] # => 'test_user'

config['vendor_api.domain'] # => 'app.service.com'
config['vendor_api.login'] # => 'test_user'
```

#### .dig

- without dot-notation:

```ruby
# get option value in Hash#dig manner (and fail when the required key does not exist);
config.dig(:vendor_api, :domain) # => 'app.service.com' # (key exists)
config.dig(:vendor_api, :login) # => Qonfig::UnknownSettingError # (key does not exist)
```

- with dot-notation:

```ruby
config.dig('vendor_api.domain') # => 'app.service.com' # (key exists)
config.dig('vendor_api.login') # => Qonfig::UnknownSettingError # (key does not exist)
```

#### .slice

- without dot-notation:

```ruby
# get a hash slice of setting options (and fail when the required key does not exist);
config.slice(:vendor_api) # => { 'vendor_api' => { 'domain' => 'app_service', 'login' => 'test_user' } }
config.slice(:vendor_api, :login) # => { 'login' => 'test_user' }
config.slice(:project_api) # => Qonfig::UnknownSettingError # (key does not exist)
config.slice(:vendor_api, :port) # => Qonfig::UnknownSettingError # (key does not exist)
```

- with dot-notation:

```ruby
config.slice('vendor_api.login') # => { 'loign' => 'test_user' }
config.slice('vendor_api.port') # => Qonfig::UnknownSettingError # (key does not exist)
```


#### .slice_value

- without dot-notaiton:

```ruby
# get value from the slice of setting options using the given key set
# (and fail when the required key does not exist) (works in slice manner);

config.slice_value(:vendor_api) # => { 'domain' => 'app_service', 'login' => 'test_user' }
config.slice_value(:vendor_api, :login) # => 'test_user'
config.slice_value(:project_api) # => Qonfig::UnknownSettingError # (key does not exist)
config.slice_value(:vendor_api, :port) # => Qonfig::UnknownSettingError # (key does not exist)
```

- with dot-notation:

```ruby
config.slice_value('vendor_api.login') # => 'test_user'
config.slice_value('vendor_api.port') # => Qonfig::UnknownSettingError # (key does not exist)
```

#### .subset

- without dot-notation:

```ruby
# - get a subset (a set of sets) of config settings represented as a hash;
# - each key (or key set) represents a requirement of a certain setting key;

config.subet(:vendor_api, :enable_graphql)
# => { 'vendor_api' => { 'login' => ..., 'domain' => ... }, 'enable_graphql' => false }

config.subset(:project_id, [:vendor_api, :domain], [:credentials, :user, :login])
# => { 'project_id' => nil, 'domain' => 'app.service.com', 'login' => 'D@iVeR' }
```

- with dot-notation:

```ruby
config.subset('project_id', 'vendor_api.domain', 'credentials.user.login')
# => { 'project_id' => nil, 'domain' => 'app.service.com', 'login' => 'D@iVeR' }
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
```

#### configure via proc

```ruby
config.configure do |conf|
  conf.enable_middlewares = true
  conf.geo_api.provider = :yandex_maps
  conf.testing.engine = :mini_test
end
```

#### configure via settings object (by option name)

```ruby
config.settings.enable_middlewares = false
config.settings.geo_api.provider = :apple_maps
config.settings.testing.engine = :ultra_test
```

#### configure via settings object (by setting key)

```ruby
config.settings[:enable_middlewares] = true
config.settings[:geo_api][:provider] = :rambler_maps
config.settings[:testing][:engine] = :mega_test
```

#### instant configuration via proc

```ruby
config = Config.new do |conf|
  conf.enable_middlewares = false
  conf.geo_api.provider = :amazon_maps
  conf.testing.engine = :crypto_test
end
```

#### using a hash

```ruby
config = Config.new(
  testing: { engine: :mini_test, parallel: false },
  geo_api: { provider: :rambler_maps },
  enable_middlewares: true
)
config.configure(enable_middlewares: false)
```

#### using both hash and proc (proc has higher priority)

```ruby
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

### Instantiation without class definition

- without inheritance:

```ruby
config = Qonfig::DataSet.build do
  setting :user, 'D@iVeR'
  setting :password, 'test123'

  def custom_method
    'custom_result'
  end
end

config.is_a?(Qonfig::DataSet) # => true

config.settings.user # => 'D@iVeR'
config.settings.password # => 'test123'
config.custom_method # => 'custom_result'
```

- with inheritance:

```ruby
class GeneralConfig < Qonfig::DataSet
  setting :db_adapter, :postgresql
end

config = Qonfig::DataSet.build(GeneralConfig) do
  setting :web_api, 'api.google.com'
end

config.is_a?(Qonfig::DataSet) # => true

config.settings.db_adapter # => :postgresql
config.settings.web_api # => "api.google.com"
```

---

## Interaction

- [Iteration over setting keys](#iteration-over-setting-keys) (`#each_setting`, `#deep_each_setting`)
- [List of config keys](#list-of-config-keys) (`#keys`, `#root_keys`)
- [Config reloading](#config-reloading) (reload config definitions and option values)
- [Clear options](#clear-options) (set to `nil`)
- [Frozen state](#frozen-state) (`.freeze_state!`, `#freeze!`, `#frozen?`)
- [Settings as Predicates](#settings-as-predicates)
- [Setting key existence](#setting-key-existence) (`#key?`/`#option?`/`#setting?`)
- [Run arbitrary code with temporary settings](#run-arbitrary-code-with-temporary-settings)

---

### Iteration over setting keys

- `#each_setting { |key, value| }`
  - iterates over the root setting keys;
- `#deep_each_setting(yield_all: false) { |key, value| }`
  - iterates over all setting keys (deep inside);
  - key object is represented as a string of `.`-joined setting key names;
  - `yield_all:` means "yield all config objects" (end values and root setting objects those have nested settings) (`false` by default);

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
```

#### .each_setting

```ruby
config.each_setting { |key, value| { key => value } }

# result of each step:
{ 'db' => <Qonfig::Settings:0x00007ff8> }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

#### .deep_each_setting

```ruby
config.deep_each_setting { |key, value| { key => value } }

# result of each step:
{ 'db.creds.user' => 'D@iveR' }
{ 'db.creds.password' => 'test123' }
{ 'db.creds.data' => { test: false } }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

#### .deep_each_setting(yield_all: true)

```ruby
config.deep_each_setting(yield_all: true) { |key, value| { key => value } }

# result of each step:
{ 'db' => <Qonfig::Settings:0x00007ff8> } # (yield_all: true)
{ 'db.creds' => <Qonfig::Settings:0x00002ff1> } # (yield_all: true)
{ 'db.creds.user' => 'D@iVeR' }
{ 'db.creds.password' => 'test123' }
{ 'db.crds.data' => { test: false } }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

---

### List of config keys

- `#keys` - returns a list of all config keys in dot-notation format;
  - `all_variants:` - get all possible variants of the config's keys sequences (`false` by default);
  - `only_root:` - get only the root config keys (`false` by default);
- `#root_keys` - returns a list of root config keys (an alias for `#keys(only_root: true)`);

```ruby
# NOTE: suppose we have the following config

class Config < Qonfig::DataSet
  setting :credentials do
    setting :social do
      setting :service, 'instagram'
      setting :login, '0exp'
    end

    setting :admin do
      setting :enabled, true
    end
  end

  setting :server do
    setting :type, 'cloud'
    setting :options do
      setting :os, 'CentOS'
    end
  end
end

config = Config.new
```

#### Default behavior

```ruby
config.keys

# the result:
[
  "credentials.social.service",
  "credentials.social.login",
  "credentials.admin.enabled",
  "server.type",
  "server.options.os"
]
```

#### All key variants

```ruby
config.keys(all_variants: true)

# the result:
[
  "credentials",
  "credentials.social",
  "credentials.social.service",
  "credentials.social.login",
  "credentials.admin",
  "credentials.admin.enabled",
  "server",
  "server.type",
  "server.options",
  "server.options.os"
]
```

#### Only root keys

```ruby
config.keys(only_root: true)

# the result:
['credentials', 'server']
```

```ruby
config.root_keys

# the result:
['credentials', 'server']
```

---

### Config reloading

- method signature: `#reload!(configurations = {}, &configuration)`;

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

- set all config's settings to `nil`;
- method signature: `#clear!`;

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

### Frozen state

#### Instance-level

- method signature: `#freeze!`;

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

#### Definition-level

- DSL-method signature: `freeze_state!`
- indicaes that all your config instances should be frozen;
- `freeze_state!` DSL command is not inherited (your child and composed config classes will not have this declaration);

```ruby
# --- base class ---
class Config < Qonfig::DataSet
  setting :test, true
  freeze_state!
end

config = Config.new
config.frozen? # => true
config.settings.test = false # => Qonfig::FrozenSettingsError

# --- child class ---
class InheritedConfig < Config
end

inherited_config = InheritedConfig.new
config.frozen? # => false
config.settings.test = false # ok :)
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

### Setting key existence

- supports **dynamic array-like format** and **canonical dot-notation format**;
- returns `true` if the concrete key is exist;
- returns `false` if the concrete key does not exist;
- **dynamic array-like format**:
  - `#key?(*key_path)` / `#option?(*key_path)` / `#setting?(*key_path)`;
  - `*key_path` - an array of symbols and strings that represents a path to the concrete setting key;
  - (for example, `config.key?(:credentials, :user)` tries to check that `config.settings.credentials.user` is exist);
- **dot-notation format**:
  - `#key?(key)` / `#option?(key)` / `#setting?(key)`;
  - `key` - string in dot-notated format
  - (for example: `config.key?('credentials.user')` tries to check that `config.settings.crednetials.user` is exist);

```ruby
class Config < Qonfig::DataSet
  setting :credentials do
    setting :user, 'D@iVeR'
    setting :password, 'test123'
  end
end

config = Config.new

# --- array-like format ---
config.key?('credentials', 'user') # => true
config.key?('credentials', 'token') # => false (key does not exist)

# --- dot-notation format ---
config.key?('credentials.user') # => true
config.key?('credentials.token') # => false (key does not exist)

config.key?('credentials') # => true
config.key?('que_adapter') # => false (key does not exist)

# aliases
config.setting?('credentials') # => true
config.option?(:credentials, :password) # => true
config.option?('credentials.password') # => true
```

---

### Run arbitrary code with temporary settings

- provides a way to run an arbitrary code with temporarily specified settings;
- your arbitrary code can temporary change any setting too - all settings will be returned to the original state;
- (it is convenient to run code samples by this way in tests (with substitued configs));
- it is fully thread-safe `:)`;

```ruby
class Config < Qonfig::DataSet
  setting :queue do
    setting :adapter, :sidekiq
    setting :options, {}
  end
end

config = Config.new

# run a block of code with temporary queue.adapter setting
config.with(queue: { adapter: 'que' }) do
  # your changed settings
  config.settings.queue.adapter # => 'que'

  # you can temporary change settings by your code too
  config.settings.queue.options = { concurrency: 10 }

  # ...your another code...
end

# original settings has not changed :)
config.settings.queue.adapter # => :sidekiq
config.settings.queue.options # => {}
```

---

## Import settings / Export settings

- [Import config settings](#import-config-settings) (`as instance methods`)
- [Export config settings](#export-config-settings) (`as singleton methods`)

Sometimes the nesting of configs in your project is quite high, and it makes you write the rather "cumbersome" code
(`config.settings.web_api.credentials.account.auth_token` for example). Frequent access to configs in this way is inconvinient - so developers wraps
such code by methods or variables. In order to make developer's life easer `Qonfig` provides a special Import API simplifies the config importing
(gives you `.import_settings` DSL) and gives an ability to instant config setting export from a config object (gives you `#export_settings` config's method).

You can use RabbitMQ-like pattern matching in setting key names:
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

### Import config settings

- `Qonfig::Imports` - a special mixin that provides the convenient DSL to work with config import features (`.import_settings` method);
- `.import_settings` - DSL method for importing configuration settings (from a config instance) as instance methods of a class;
- (**IMPORTANT**) `import_settings` imports config settings as access methods to config's settings (creates `attr_reader`s for your config);
- signature: `.import_settings(config_object, *setting_keys, mappings: {}, prefix: '', raw: false)`
  - `config_object` - an instance of `Qonfig::DataSet` whose config settings should be imported;
  - `*setting_keys` - an array of dot-notaed config's setting keys that should be imported
    (dot-notaed key is a key that describes each part of nested setting key as a string separated by `dot`-symbol);
    - last part of dot-notated key will become a name of the setting access instance method;
  - `mappings:` - a map of keys that describes custom method names for each imported setting;
  - `prefix:` - prexifies setting access method name with custom prefix;
  - `raw:` - use nested settings as objects or hashify them (`false` by default (means "hashify nested settings"));

---

Suppose we have a config with deeply nested keys:

```ruby
# NOTE: (Qonfig::DataSet.build creates a class and instantly instantiates it)
AppConfig = Qonfig::DataSet.build do
  setting :web_api do
    setting :credentials do
      setting :account do
        setting :login, 'DaiveR'
        setting :auth_token, 'IAdkoa0@()1239uA'
      end
    end
  end

  setting :graphql_api, false
end
```

Let's see what we can to do :)

#### Import a set of setting keys (simple dot-noated key list)

- last part of dot-notated key will become a name of the setting access instance method;

```ruby
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig,
    'web_api.credentials.account.login',
    'web_api.credentials.account'
  )
end

service = ServiceObject.new

service.login # => "D@iVeR"
service.account # => { "login" => "D@iVeR", "auth_token" => IAdkoa0@()1239uA" }
```

#### Import with custom method names (mappings)

- `mappings:` defines a map of keys that describes custom method names for each imported setting;

```ruby
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig, mappings: {
    account_data: 'web_api.credentials.account', # NOTE: name access method with "account_data"
    secret_token: 'web_api.credentials.account.auth_token' # NOTE: name access method with "secret_token"
  })
end

service = ServiceObject.new

service.account_data # => { "login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA" }
service.auth_token # => "IAdkoa0@()1239uA"
```

#### Prexify method name

- `prefix:` - prexifies setting access method name with custom prefix;

```ruby
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig,
    'web_api.credentials.account',
    mappings: { secret_token: 'web_api.credentials.account.auth_token' },
    prefix: 'config_'
  )
end

service = ServiceObject.new

service.config_credentials # => { login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA" }
service.config_secret_token # => "IAdkoa0@()1239uA"
```

#### Import nested settings as raw Qonfig::Settings objects

- `raw: false` is used by default (hashify nested settings)

```ruby
# NOTE: import nested settings as raw objects (raw: true)
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig, 'web_api.credentials', raw: true)
end

service = ServiceObject.new

service.credentials # => <Qonfig::Settings:0x00007ff8>
service.credentials.account.login # => "D@iVeR"
service.credentials.account.auth_token # => "IAdkoa0@()1239uA"
```

```ruby
# NOTE: import nested settings as converted-to-hash objects (raw: false) (default behavior)
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig, 'web_api.credentials', raw: false)
end

service = ServiceObject.new

service.credentials # => { "account" => { "login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA"} }
```

#### Immport with pattern-matching

- import root keys only: `import_settings(config_object, '*')`;
- import all keys: `import_settings(config_object, '#')`;
- import the subset of keys: `import_settings(config_object, 'group.*.group.#')` (pattern-mathcing usage);

```ruby
class ServiceObject
  include Qonfig::Imports

  # import all settings from web_api.credentials subset
  import_settings(AppConfig, 'web_api.credentials.#')
  # generated instance methods:
  #   => service.account
  #   => service.login
  #   => service.auth_token

  # import only the root keys from web_api.credentials.account subset
  import_settings(AppConfig, 'web_api.credentials.account.*')
  # generated instance methods:
  #   => service.login
  #   => service.auth_token

  # import only the root keys
  import_settings(AppConfig, '*')
  # generated instance methods:
  #   => service.web_api
  #   => service.graphql_api

  # import ALL keys
  import_Settings(AppConfig, '#')
  # generated instance methods:
  #   => service.web_api
  #   => service.credentials
  #   => service.account
  #   => service.login
  #   => service.auth_token
  #   => service.graphql_api
end
```

---

### Export config settings

- all config objects can export their settings to an arbitrary object as singleton methods;
- (**IMPORTANT**) `export_settings` exports config settings as access methods to config's settings (creates `attr_reader`s for your config);
- signature: `#export_settings(exportable_object, *setting_keys, mappings: {}, prefix: '', raw: false)`:
  - `exportable_object` - an arbitrary object for exporting;
  - `*setting_keys` - an array of dot-notaed config's setting keys that should be exported
    (dot-notaed key is a key that describes each part of nested setting key as a string separated by `dot`-symbol);
    - last part of dot-notated key will become a name of the setting access instance method;
  - `mappings:` - a map of keys that describes custom method names for each exported setting;
  - `prefix:` - prexifies setting access method name with custom prefix;
  - `raw:` - use nested settings as objects or hashify them (`false` by default (means "hashify nested settings"));
- works in `.import_settings` manner [doc](#import-config-settings) (see examples and documentation above `:)`)

```ruby
class Config < Qonfig::DataSet
  setting :web_api do
    setting :credentials do
      setting :account do
        setting :login, 'DaiveR'
        setting :auth_token, 'IAdkoa0@()1239uA'
      end
    end
  end

  setting :graphql_api, false
end

class ServiceObject; end

config = Config.new
service = ServiceObject.new

service.config_account # => NoMethodError

# NOTE: export settings as access methods to config's settings
config.export_settings(service, 'web_api.credentials.account', prefix: 'config_')

service.config_account # => { "login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA" }

# NOTE: export settings with pattern matching
config.export_settings(service, '*') # export root settings

service.web_api # => { 'credentials' => { 'account' => { ... } }, 'graphql_api' => false }
service.graphql_api # => false
```

---

## Validation

- [Introduction](#introduction)
- [Key Search Pattern](#key-search-pattern)
- [Proc-based validation](#proc-based-validation)
- [Method-based validation](#method-based-validation)
- [Predefined validations](#predefined-validations)
- [Custom predefined validators](#custom-predefined-validators)
- [Validation of potential setting values](#validation-of-potential-setting-values)

---

### Introduction

Qonfig provides a lightweight DSL for defining validations and works in all cases when setting values are initialized or mutated.
Settings are validated as keys (matched with a [specific string pattern](#key-search-pattern)).
You can validate both a set of keys and each key separately.
If you want to check the config object completely you can define a custom validation.

**Features**:
- validation is invoked on any mutation of any setting:
  - during dataset instantiation;
  - when assigning new values;
  - when calling `#reload!`;
  - when calling `#clear!`;
- provides `strict` and `non-strict` behavior (`strict: true` and `strict: false` respectively):
  - `strict: false` ignores validations for settings with `nil` (allows `nil` value);
  - `strict: true` does not ignores validations for settings with `nil`;
  - `strict: false` is used by default;
- provides a special [key search pattern](#key-search-pattern) for matching setting key names;
- you can validate potential setting values without any assignment ([documentation](#validation-of-potential-setting-values))
- uses the [key search pattern](#key-search-pattern) for definging what the setting key should be validated;
- you can define your own custom validation logic and validate dataset instance completely;
- validation logic should return **truthy** or **falsy** value;
- supprots two validation techniques (**proc-based** ([documentation](#proc-based-validation)) and **dataset-method-based** ([documentation](#method-based-validation))):
  - **proc-based** (`setting validation`) ([documentation](#proc-based-validation))
    ```ruby
      validate('db.user', strict: true) do |value|
        value.is_a?(String)
      end
    ```
  - **proc-based** (`dataset validation`) ([doc](#proc-based-validation))
    ```ruby
      validate(strict: false) do
        settings.user == User[1]
      end
    ```
  - **dataset-method-based** (`setting validation`) ([documentation](#method-based-validation))
    ```ruby
      validate 'db.user', by: :check_user, strict: true

      def check_user(value)
        value.is_a?(String)
      end
    ```
  - **dataset-method-based** (`dataset validation`) ([documentation](#method-based-validation))
    ```ruby
      validate by: :check_config, strict: false

      def check_config
        settings.user == User[1]
      end
    ```
- provides a **set of standard validations** ([documentation](#predefined-validations)):
  - DSL: `validate 'key.pattern', :predefned_validator`;
  - supports `strict` behavior;
- you can define your own predefined validators (class-related and global-related) ([documentation](#custom-predefined-validators));

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
- `nil` values are ignored by default;
- set `strict: true` to disable `nil` ignorance (`strict: false` is used by default);
- how to validate setting keys:
  - define proc with attribute: `validate 'your.setting.path' do |value|; end`
  - proc will receive setting value;
- how to validate dataset instance:
  - define proc without setting key pattern: `validate do; end`;

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
  setting :token, '1a2a3a', strict: true

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

  # do not ignore `nil` (strict: true)
  validate(:token, strict: true) do
    value.is_a?(String)
  end
end

config = Config.new
config.settings.db.password = 123 # => Qonfig::ValidationError (should be a string)
config.settings.service.address = 123 # => Qonfig::ValidationError (should be a string)
config.settings.service.protocol = :http # => Qonfig::ValidationError (should be a string)
config.settings.service.creds.admin = :billikota # => Qonfig::ValidationError (should be a string)
config.settings.enabled = true # => Qonfig::ValidationError (isnt `true`)

config.settings.db.password = nil # ok, nil is ignored (non-strict behavior)
config.settings.token = nil # => Qonfig::ValidationError (nil is not ignored, strict behavior) (should be a type of string)
```

---

### Method-based validation

- method should return truthy value or falsy value;
- `nil` values are ignored by default;
- set `strict: true` to disable `nil` ignorance (`strict: false` is used by default);
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
  setting :timeout, 12345, strict: true

  # validates:
  #   - services.counts.google
  #   - services.counts.rambler
  #   - services.minimals.google
  #   - services.minimals.rambler
  validate 'services.#', by: :check_presence

  # validates:
  #   - dataset instance
  validate by: :check_state # NOTE: no setting key pattern

  # do not ignore `nil` (strict: true)
  validate :timeout, strict: true, by: :check_timeout

  def check_presence(value)
    value.is_a?(Numeric) && value > 0
  end

  def check_state
    settings.enabled.is_a?(TrueClass) || settings.enabled.is_a?(FalseClass)
  end

  def check_timeout(value)
    value.is_a?(Numeric)
  end
end

config = Config.new

config.settings.counts.google = 0 # => Qonfig::ValidationError (< 0)
config.settings.minimals.google = -1 # => Qonfig::ValidationError (< 0)
config.settings.minimals.rambler = 'no' # => Qonfig::ValidationError (should be a numeric)

config.settings.counts.rambler = nil # ok, nil is ignored (default non-strict behavior)
config.settings.enabled = nil # ok, nil is ignored (default non-strict behavior)
config.settings.timeout = nil # => Qonfig::ValidationError (nil is not ignored, strict behavior) (should be a type of numeric)
```

---

### Predefined validations

- DSL: `validate 'key.pattern', :predefned_validator`
- `nil` values are ignored by default;
- set `strict: true` to disable `nil` ignorance (`strict: false` is used by default);
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
  setting :user, 'empty'
  setting :password, 'empty'

  setting :service do
    setting :provider, :empty
    setting :protocol, :empty
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

### Custom predefined validators

- DSL: `.define_validator(name, &validation) { |value| ... }` - create your own predefined validator;
- **class-level**: define validators related only to the concrete config class;
- **global-level**: define validators related to all config classes (`Qonfig::DataSet.define_validator`);
- you can re-define any global and inherited validator (at class level);
- you can re-define any already registered global validator on `Qonfig::DataSet` (at global-level);

#### Define your own class-level validator

```ruby
class Config < Qonfig::DataSet
  # NOTE: definition
  define_validator(:user_type) { |value| value.is_a?(User) }

  setting :admin # some key

  # NOTE: usage
  validate :admin, :user_type
end
```

#### Defin new global validator

```ruby
Qonfig::DataSet.define_validator(:secured_value) do |value|
  value == '***'
end

class Config < Qonfig::DataSet
  setting :password
  validate :password, :secured_value
end
```

#### Re-definition of existing validators in child classes

```ruby
class Config < Qonfig::DataSet
  # NOTE: redefine existing :text validator only in Config class
  define_validator(:text) { |value| value.is_a?(String) }

  # NOTE: some custom validator that can be redefined in child classes
  define_validator(:user) { |value| value.is_a?(User) }
end

class SubConfig < Qonfig
  define_validator(:user) { |value| value.is_a?(AdminUser) } # NOTE: redefine inherited :user validator
end
```

#### Re-definition of existing global validators

```ruby
# NOTE: redefine already existing :numeric validator
Qonfig::DataSet.define_validator(:numeric) do |value|
  value.is_a?(Numeric) || (value.is_a?(String) && value.match?(/\A\d+\.*\d+\z/))
end
```

---

### Validation of potential setting values

- (**instance-level**) `#valid_with?(configurations = {})` - check that current config instalce will be valid with passed configurations;
- (**class-level**) `.valid_with?(configurations = {})` - check that potential config instancess will be valid with passed configurations;
- makes no assignments;

#### #valid_with? (instance-level)

```ruby
class Config < Qonfig::DataSet
  setting :enabled, false
  setting :queue do
    setting :adapter, 'sidekiq'
  end

  validate :enabled, :boolean
  validate 'queue.adapter', :string
end

config = Config.new

config.valid_with?(enabled: true, queue: { adapter: 'que' }) # => true
config.valid_with?(enabled: 123) # => false (should be a type of boolean)
config.valid_with?(enabled: true, queue: { adapter: Sidekiq }) # => false (queue.adapter should be a type of string)
```

#### .valid_with? (class-level)

```ruby
class Config < Qonfig::DataSet
  setting :enabled, false
  setting :queue do
    setting :adapter, 'sidekiq'
  end

  validate :enabled, :boolean
  validate 'queue.adapter', :string
end

Config.valid_with?(enabled: true, queue: { adapter: 'que' }) # => true
Config.valid_with?(enabled: 123) # => false (should be a type of boolean)
Config.valid_with?(enabled: true, queue: { adapter: Sidekiq }) # => false (queue.adapter should be a type of string)
```

---

## Work with files

- **Setting keys definition**
  - [Load from YAML file](#load-from-yaml-file)
  - [Expose YAML](#expose-yaml) (`Rails`-like environment-based YAML configs)
  - [Load from JSON file](#load-from-json-file)
  - [Expose JSON](#expose-json) (`Rails`-like environment-based JSON configs)
  - [Load from ENV](#load-from-env)
  - [Load from \_\_END\_\_](#load-from-__end__) (aka `load_from_self`)
  - [Expose \_\_END\_\_](#expose-__end__) (aka `expose_self`)
- **Setting values**
  - [Default setting values file](#default-setting-values-file)
  - [Load setting values from YAML file](#load-setting-values-from-yaml-file-by-instance)
  - [Load setting values from JSON file](#load-setting-values-from-json-file-by-instance)
  - [Load setting values from \_\_END\_\_](#load-setting-values-from-__end__-by-instance)
  - [Load setting values from file manually](#load-setting-values-from-file-manually-by-instance)
- **Daily work**
  - [Save to JSON file](#save-to-json-file) (`save_to_json`)
  - [Save to YAML file](#save-to-yaml-file) (`save_to_yaml`)

---

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

### Expose JSON

- load configurations from JSON file in Rails-like manner (with environments);
- works in `load_from_jsom`/`expose_yaml` manner;
- `via:` - how an environment will be determined:
    - `:file_name`
        - load configuration from JSON file that have an `:env` part in it's name;
    - `:env_key`
        - load configuration from JSON file;
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

#### Environment is defined as a root key of JSON file

```json
// config/project.json

{
  "development": {
    "api_mode_enabled": true,
    "logging": false,
    "db_driver": "sequel",
    "throttle_requests": false,
    "credentials": {}
  },
  "test": {
    "api_mode_enabled": true,
    "logging": false,
    "db_driver": "in_memory",
    "throttle_requests": false,
    "credentials": {}
  },
  "staging": {
    "api_mode_enabled": true,
    "logging": true,
    "db_driver": "active_record",
    "throttle_requests": true,
    "credentials": {}
  },
  "production": {
    "api_mode_enabled": true,
    "logging": true,
    "db_driver": "rom",
    "throttle_requests": true,
    "credentials": {}
  }
}
```

```ruby
class Config < Qonfig::DataSet
  expose_json 'config/project.json', via: :env_key, env: :production # load from production env

  # NOTE: in rails-like application you can use this:
  expose_json 'config/project.json', via: :env_key, env: Rails.env
end

config = Config.new

config.settings.api_mode_enabled # => true (from :production subset of keys)
config.settings.logging # => true (from :production subset of keys)
config.settings.db_driver # => "rom" (from :production subset of keys)
config.settings.throttle_requests # => true (from :production subset of keys)
config.settings.credentials # => {} (from :production subset of keys)
```

#### Environment is defined as a part of JSON file name

```json
// config/sidekiq.staging.json
{
  "web": {
    "username": "staging_admin",
    "password": "staging_password"
  }
}
```

```json
// config/sidekiq.production.json
{
  "web": {
    "username": "urj1o2",
    "password": "u192jd0ixz0"
  }
}
```

```ruby
class SidekiqConfig < Qonfig::DataSet
  # NOTE: file name should be described WITHOUT environment part (in file name attribute)
  expose_json 'config/sidekiq.json', via: :file_name, env: :staging # load from staging env

  # NOTE: in rails-like application you can use this:
  expose_json 'config/sidekiq.json', via: :file_name, env: Rails.env
end

config = SidekiqConfig.new

config.settings.web.username # => "staging_admin" (from sidekiq.staging.json)
config.settings.web.password # => "staging_password" (from sidekiq.staging.json)
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
- `:format` - specify the format of data placed under the `__END__` instruction:
  - `format: :yaml` - **YAML** format (by default);
  - `format: :json` - **JSON** format;
  - `format: :toml` - **TOML** format (via `toml`-plugin);

```ruby
class Config < Qonfig::DataSet
  load_from_self # on the root (format: :yaml is used by default)

  setting :nested do
    load_from_self, format: :yaml # with explicitly identified YAML format
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

### Expose \_\_END\_\_

- aka `expose_self`;
- works in `expose_json` and `expose_yaml` manner, but with `__END__` instruction of the current file;
- `env:` - your environment name (must be a type of `String`, `Symbol` or `Numeric`);
- `:format` - specify the format of data placed under the `__END__` instruction:
  - `format: :yaml` - **YAML** format (by default);
  - `format: :json` - **JSON** format;
  - `format: :toml` - **TOML** format (via `toml`-plugin);

```ruby
class Config < Qonfig::DataSet
  expose_self env: :production, format: :yaml # with explicitly identified YAML format

  # NOTE: for Rails-like applications you can use this:
  expose_self env: Rails.env
end

config = Config.new

config.settings.log # => true (from :production environment)
config.settings.api_enabled # => true (from :production environment)
config.settings.creds.user # => "D@iVeR" (from :production environment)
config.settings.creds.password # => "test123" (from :production environment)

__END__

default: &default
  log: false
  api_enabled: true
  creds:
    user: admin
    password: 1234

development:
  <<: *default
  log: true

test:
  <<: *default
  log: false

staging:
  <<: *default

production:
  <<: *default
  log: true
  creds:
    user: D@iVeR
    password: test123
```

---

### Default setting values file

- defines a file that should be used for setting values initialization for your config object;
- `.values_file(file_path, format: :dynamic, strict: false, expose: nil)`
  - `file_path` - full file path or `:self` (`:self` menas "load setting values from __END__ data");
  - `:format` - defines the format of file (`:dynamic` means "try to automatically infer the file format") (`:dynamic` by default);
    - supports `:yaml`, `:json`, `:toml` (via `Qonfig.plugin(:toml)`), `:dynamic` (automatic format detection);
  - `:strict` - rerquires that file (or __END__-data) should exist (`false` by default);
  - `:expose` - what the environment-based subset of keys should be used (`nil` means "do not use any subset of keys") (`nil` by default);
- extra keys that does not exist in your config will cause an exception `Qonfig::SettingNotFound` respectively;
- initial values will be rewritten by values defined in your file;

#### Default behavior

```yaml
# sidekiq.yml

adapter: sidekiq
options:
  processes: 10
```

```ruby
class Config < Qonfig::DataSet
  values_file 'sidekiq.yml', format: :yaml

  setting :adapter, 'que'
  setting :options do
    setting :processes, 2
    setting :threads, 5
    setting :protected, false
  end
end

config = Config.new

config.settings.adapter # => "sidekiq" (from sidekiq.yml)
config.settings.options.processes # => 10 (from sidekiq.yml)
config.settings.options.threads # => 5 (original value)
config.settings.options.protected # => false (original value)
```

#### Load values from \_\_END\_\_-data

```ruby
class Config < Qonfig::DataSet
  values_file :self, format: :yaml

  setting :user
  setting :password
  setting :enabled, true
end

config = Config.new

config.settings.user # => "D@iVeR" (from __END__ data)
config.settings.password # => "test123" (from __END__ data)
config.settings.enabled # => true (original value)

__END__

user: 'D@iVeR'
password: 'test123'
```

#### Setting values with environment separation

```yaml
# sidekiq.yml

development:
  adapter: :in_memory
  options:
    threads: 10

production:
  adapter: :sidekiq
  options:
    threads: 150
```

```ruby
class Config < Qonfig::DataSet
  values_file 'sidekiq.yml', format: :yaml, expose: :development

  setting :adapter
  setting :options do
    setting :threads
  end
end

config = Config.new

config.settings.adapter # => 'in_memory' (development keys subset)
config.settings.options.threads # => 10 (development keys subset)
```

#### File does not exist

```ruby
# non-strict behavior (default)
class Config < Qonfig::DataSet
  values_file 'sidekiq.yml'
end

config = Config.new # no error

# strict behavior (strict: true)
class Config < Qonfig::DataSet
  values_file 'sidekiq.yml', strict: true
end

config = Config.new # => Qonfig::FileNotFoundError
```

---

### Load setting values from YAML file (by instance)

- prvoides an ability to load predefined setting values from a yaml file;
- `#load_from_yaml(file_path, strict: true, expose: nil)`
  - `file_path` - full file path or `:self` (`:self` means "load setting values from __END__ data");
  - `:strict` - rerquires that file (or __END__-data) should exist (`true` by default);
  - `:expose` - what the environment-based subset of keys should be used (`nil` means "do not use any subset of keys") (`nil` by default);

#### Default behavior

```yaml
# config.yml

domain: google.ru
creds:
  auth_token: test123
```

```ruby
class Config < Qonfig::DataSet
  seting :domain, 'test.com'
  setting :creds do
    setting :auth_token, 'test'
  end
end

config = Config.new
config.settings.domain # => "test.com"
config.settings.creds.auth_token # => "test"

# load new values
config.load_from_yaml('config.yml')

config.settings.domain # => "google.ru" (from config.yml)
config.settings.creds.auth_token # => "test123" (from config.yml)
```

#### Load from \_\_END\_\_

```ruby
class Config < Qonfig::DataSet
  seting :domain, 'test.com'
  setting :creds do
    setting :auth_token, 'test'
  end
end

config = Config.new
config.settings.domain # => "test.com"
config.settings.creds.auth_token # => "test"

# load new values
config.load_from_yaml(:self)
config.settings.domain # => "yandex.ru" (from __END__-data)
config.settings.creds.auth_token # => "CK0sIdA" (from __END__-data)

__END__

domain: yandex.ru
creds:
  auth_token: CK0sIdA
```

#### Setting values with environment separation

```yaml
# config.yml

development:
  domain: dev.google.ru
  creds:
    auth_token: kekpek

production:
  domain: google.ru
  creds:
    auth_token: Asod1
```

```ruby
class Config < Qonfig::DataSet
  setting :domain, 'test.com'
  setting :creds do
    setting :auth_token
  end
end

config = Config.new

# load new values (expose development settings)
config.load_from_yaml('config.yml', expose: :development)

config.settings.domain # => "dev.google.ru" (from config.yml)
config.settings.creds.auth_token # => "kek.pek" (from config.yml)
```

---

### Load setting values from JSON file (by instance)

- prvoides an ability to load predefined setting values from a json file;
- `#load_from_yaml(file_path, strict: true, expose: nil)`
  - `file_path` - full file path or `:self` (`:self` means "load setting values from __END__ data");
  - `:strict` - rerquires that file (or __END__-data) should exist (`true` by default);
  - `:expose` - what the environment-based subset of keys should be used (`nil` means "do not use any subset of keys") (`nil` by default);

#### Default behavior

```json
// config.json

{
  "domain": "google.ru",
  "creds": {
    "auth_token": "test123"
  }
}
```

```ruby
class Config < Qonfig::DataSet
  seting :domain, 'test.com'
  setting :creds do
    setting :auth_token, 'test'
  end
end

config = Config.new
config.settings.domain # => "test.com"
config.settings.creds.auth_token # => "test"

# load new values
config.load_from_json('config.json')

config.settings.domain # => "google.ru" (from config.json)
config.settings.creds.auth_token # => "test123" (from config.json)
```

#### Load from \_\_END\_\_

```ruby
class Config < Qonfig::DataSet
  seting :domain, 'test.com'
  setting :creds do
    setting :auth_token, 'test'
  end
end

config = Config.new
config.settings.domain # => "test.com"
config.settings.creds.auth_token # => "test"

# load new values
config.load_from_json(:self)
config.settings.domain # => "yandex.ru" (from __END__-data)
config.settings.creds.auth_token # => "CK0sIdA" (from __END__-data)

__END__

{
  "domain": "yandex.ru",
  "creds": {
    "auth_token": "CK0sIdA"
  }
}
```

#### Setting values with environment separation

```json
// config.json

{
  "development": {
    "domain": "dev.google.ru",
    "creds": {
      "auth_token": "kekpek"
    }
  },
  "production": {
    "domain": "google.ru",
    "creds": {
      "auth_token": "Asod1"
    }
  }
}
```

```ruby
class Config < Qonfig::DataSet
  setting :domain, 'test.com'
  setting :creds do
    setting :auth_token
  end
end

config = Config.new

# load new values (from development subset)
config.load_from_json('config.json', expose: :development)

config.settings.domain # => "dev.google.ru" (from config.json)
config.settings.creds.auth_token # => "kek.pek" (from config.json)
```
---

### Load setting values from \_\_END\_\_ (by instance)

- prvoides an ability to load predefined setting values from `__END__` file section;
- `#load_from_self(strict: true, expose: nil)`
  - `:format` - defines the format of file (`:dynamic` means "try to automatically infer the file format") (`:dynamic` by default);
    - supports `:yaml`, `:json`, `:toml` (via `Qonfig.plugin(:toml)`), `:dynamic` (automatic format detection);
  - `:strict` - requires that __END__-data should exist (`true` by default);
  - `:expose` - what the environment-based subset of keys should be used (`nil` means "do not use any subset of keys") (`nil` by default);

#### Default behavior

```ruby
class Config < Qonfig::DataSet
  setting :account, 'test'
  setting :options do
    setting :login, '0exp'
    setting :password, 'test123'
  end
end

config = Config.new
config.settings.account # => "test" (original value)
config.settings.options.login # => "0exp" (original value)
config.settings.options.password # => "test123" (original value)

# load new values
config.load_from_self(format: :yaml)
# or config.load_from_self

config.settings.account # => "real" (from __END__-data)
config.settings.options.login # => "D@iVeR" (from __END__-data)
config.settings.options.password # => "azaza123" (from __END__-data)

__END__

account: real
options:
  login: D@iVeR
  password: azaza123
```

#### Setting values with envvironment separation

```ruby
class Config < Qonfig::DataSet
  setting :domain, 'test.google.ru'
  setting :options do
    setting :login, 'test'
    setting :password, 'test123'
  end
end

config = Config.new
config.settings.domain # => "test.google.ru" (original value)
config.settings.options.login # => "test" (original value)
config.settings.options.password # => "test123" (original value)

# load new values
config.load_from_self(format: :json, expose: :production)
# or config.load_from_self(expose: production)

config.settings.domain # => "prod.google.ru" (from __END__-data)
config.settings.options.login # => "prod" (from __END__-data)
config.settings.options.password # => "prod123" (from __END__-data)

__END__

{
  "development": {
    "domain": "dev.google.ru",
    "options": {
      "login": "dev",
      "password": "dev123"
    }
  },
  "production": {
    "domain": "prod.google.ru",
    "options": {
      "login": "prod",
      "password": "prod123"
    }
  }
}
```

---

### Load setting values from file manually (by instance)

- prvoides an ability to load predefined setting values from a file;
- works in instance-based `#load_from_yaml` / `#load_from_json` / `#load_from_self` manner;
- signature: `#load_from_file(file_path, format: :dynamic, strict: true, expose: nil)`:
  - `file_path` - full file path or `:self` (`:self` means "load setting values from __END__ data");
  - `:format` - defines the format of file (`:dynamic` means "try to automatically infer the file format") (`:dynamic` by default);
    - supports `:yaml`, `:json`, `:toml` (via `Qonfig.plugin(:toml)`), `:dynamic` (automatic format detection);
  - `:strict` - rerquires that file (or __END__-data) should exist (`true` by default);
  - `:expose` - what the environment-based subset of keys should be used (`nil` means "do not use any subset of keys") (`nil` by default);
- see examples for instance-based `#load_from_yaml` ([doc](#load-setting-values-from-yaml-by-instance)) / `#load_from_json` ([doc](#load-setting-values-from-json-by-instance)) / `#load_from_self` ([doc](#load-setting-values-from-__end__-by-instance));

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

- [toml](#plugins-toml) (provides `load_from_toml`, `save_to_toml`, `expose_toml`);
- [pretty_print](#plugins-pretty_print) (beautified/prettified console output);

---

#### Usage

- show available plugins:

```ruby
Qonfig.plugins # => ["pretty_print", "toml", ..., ...]
```

- load specific plugin:

```ruby
Qonfig.plugin(:pretty_print) # or Qonfig.plugin('pretty_print')
# -- or --
Qonfig.enable(:pretty_print) # or Qonfig.enable('pretty_print')
# -- or --
Qonfig.load(:pretty_print) # or Qonfig.load('pretty_print')
```

- show loaded plugins:

```ruby
Qonfig.loaded_plugins # => ["pretty_print"]
# -- or --
Qonfig.enabled_plugins # => ["pretty_print"]
```

---

### Plugins: toml

- adds support for `toml` format ([specification](https://github.com/toml-lang/toml));
- depends on `toml-rb` gem ([link](https://github.com/emancu/toml-rb));
- supports TOML `0.5.0` format (dependency lock);
- provides `.load_from_toml` (works in `.load_from_yaml` manner ([doc](#load-from-yaml-file)));
- provides `.expose_toml` (works in `.expose_yaml` manner ([doc](#expose-yaml)));
- provides `#save_to_toml` (works in `#save_to_yaml` manner ([doc](#save-to-yaml-file))) (`toml-rb` has no native options);
- provides `format: :toml` for `.values_file` ([doc]());
- provides `#load_from_toml` (work in `#load_from_yaml` manner ([doc](#load-setting-values-from-yaml)));

```ruby
# 1) require external dependency
require 'toml-rb'

# 2) enable plugin
Qonfig.plugin(:toml)

# 3) use toml :)
```

---

### Plugins: pretty_print

- `Qonfig.plugin(:pretty_print)`
- gives you really comfortable and beautiful console output;
- represents all setting keys in dot-notation format;

#### Example:

```ruby
class Config < Qonfig::DataSet
  setting :api do
    setting :domain, 'google.ru'
    setting :creds do
      setting :account, 'D@iVeR'
      setting :password, 'test123'
    end
  end

  setting :log_requests, true
  setting :use_proxy, true
end

config = Config.new
```

- before:

```shell
=> #<Config:0x00007f9b6c01dab0
 @__lock__=
  #<Qonfig::DataSet::Lock:0x00007f9b6c01da60
   @access_lock=#<Thread::Mutex:0x00007f9b6c01da38>,
   @arbitary_lock=#<Thread::Mutex:0x00007f9b6c01d9e8>,
   @definition_lock=#<Thread::Mutex:0x00007f9b6c01da10>>,
 @settings=
  #<Qonfig::Settings:0x00007f9b6c01d858
   @__lock__=
    #<Qonfig::Settings::Lock:0x00007f9b6c01d808
     @access_lock=#<Thread::Mutex:0x00007f9b6c01d7b8>,
     @definition_lock=#<Thread::Mutex:0x00007f9b6c01d7e0>,
     @merge_lock=#<Thread::Mutex:0x00007f9b6c01d790>>,
   @__mutation_callbacks__=
    #<Qonfig::Settings::Callbacks:0x00007f9b6c01d8d0
     @callbacks=[#<Proc:0x00007f9b6c01d8f8@/Users/daiver/Projects/qonfig/lib/qonfig/settings/builder.rb:39>],
     @lock=#<Thread::Mutex:0x00007f9b6c01d880>>,
   @__options__=
    {"api"=>
      #<Qonfig::Settings:0x00007f9b6c01d498
# ... and etc
```

- after:

```shell
=> #<Config:0x00007f9b6c01dab0
 api.domain: "google.ru",
 api.creds.account: "D@iVeR",
 api.creds.password: "test123",
 log_requests: true,
 use_proxy: true>

# -- or --

=> #<Config:0x00007f9b6c01dab0 api.domain: "google.ru", api.creds.account: "D@iVeR", api.creds.password: "test123", log_requests: true, use_proxy: true>
```

---

## Roadmap

- **Major**:
  - distributed configuration server;
  - cli toolchain;
  - support for Rails-like secrets;
  - support for persistent data storages (we want to store configs in multiple databases and files);
  - Rails reload plugin;
- **Minor**:

## Contributing

- Fork it ( https://github.com/0exp/qonfig/fork )
- Create your feature branch (`git checkout -b feature/my-new-feature`)
- Commit your changes (`git commit -am '[my-new-featre] Add some feature'`)
- Push to the branch (`git push origin feature/my-new-feature`)
- Create new Pull Request

## License

Released under MIT License.

## Authors

[Rustam Ibragimov](https://github.com/0exp)
