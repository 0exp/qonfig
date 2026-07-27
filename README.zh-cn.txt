# Qonfig &middot; [![Gem Version](https://badge.fury.io/rb/qonfig.svg)](https://badge.fury.io/rb/qonfig) [![Build](https://github.com/0exp/qonfig/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/0exp/qonfig/actions)

功能强大的 Ruby 配置框架，支持多种常用的配置格式，提供多功能 API、开发者友好的 DSL 以及面向对象的行为。

- 支持：**YAML**, **TOML**, **JSON**, **ENV**, **\_\_END\_\_** 指令；
- 完全线程安全；
- 面向对象行为（配置作为对象、继承、组合等），并支持延迟实例化；
- 可插拔且可扩展的多功能 API；
- 开发者友好的 DSL :)

```
# 回顾...:

配置定义为类，使用为实例。支持继承和组合。
延迟实例化。线程安全。命令式 DSL。验证层。**点号表示法 (Dot-notation)**
以及美化打印 :) 支持 **YAML**, **TOML**, **JSON**, **\_\_END\_\_**, **ENV**。
定义极其简单。使用极其简单。这就全部了吗？**还没** :)
```

## 安装

```ruby
gem 'qonfig'
```

```shell
$ bundle install
# --- 或 ---
$ gem install 'qonfig'
```

```ruby
require 'qonfig'
```

## 使用方法

- [定义](#definition)
  - [定义与设置访问](#definition-and-access)
    - [通过方法访问](#access-via-method)
    - [通过索引方法 \[\] 访问](#access-via-index-method-)
    - [.dig](#dig)
    - [.slice](#slice)
    - [.slice_value](#slice_value)
    - [.subset](#subset)
  - [配置](#configuration)
    - [通过 proc 配置](#configure-via-proc)
    - [通过设置对象配置（按选项名称）](#configure-via-settings-object-by-option-name)
    - [通过设置对象配置（按设置键）](#configure-via-settings-object-by-setting-key)
    - [通过 proc 即时配置](#instant-configuration-via-proc)
    - [使用 Hash](#using-a-hash)
    - [同时使用 Hash 和 proc（proc 优先级更高）](#using-both-hash-and-proc-proc-has-higher-priority)
  - [继承](#inheritance)
  - [组合](#composition)
  - [Hash 表示](#hash-representation)
    - [默认行为（无选项）](#default-behavior-without-options)
    - [带转换](#with-transformations)
    - [点号风格格式](#dot-style-format)
  - [智能 Mixin](#smart-mixin) (`Qonfig::Configurable`)
  - [无需类定义的实例化](#instantiation-without-class-definition) (`Qonfig::DataSet.build(&definitions)`)
- [紧凑型配置 (Compacted config)](#compacted-config)
  - [定义与实例化](#definition-and-instantiation)
    - [通过原始初始化](#by-raw-initialization)
    - [通过现有的 Qonfig::DataSet 类](#by-existing-qonfigdataset-class)
    - [通过现有的 Qonfig::DataSet 实例](#by-existing-qonfigdataset-instance)
    - [无需类定义的实例化](#instantiation-without-class-definition-1)
    - [验证 API](#validation-api-see-full-documentation)
  - [设置读取器和写入器](#setting-readers-and-writers)
    - [读取](#reading-by-setting-name-and-index-method-with-dot-notation-support-and-indifferent-access)
    - [写入](#writing-by-setting-name-and-index-method-with-dot-notation-support-and-indifferent-access)
    - [谓词 (#predicates)](#precitaes)
- [交互](#interaction)
  - [遍历设置键](#iteration-over-setting-keys) (`#each_setting`, `#deep_each_setting`)
  - [配置键列表](#list-of-config-keys) (`#keys`, `#root_keys`)
  - [配置重载](#config-reloading) (重载配置定义和选项值)
  - [清除选项](#clear-options) (设置为 `nil`)
  - [冻结状态](#frozen-state) (`.freeze_state!`, `#freeze!`, `#frozen?`)
  - [设置作为谓词](#settings-as-predicates)
  - [设置键是否存在](#setting-key-existence) (`#key?`/`#option?`/`#setting?`)
  - [使用临时设置运行任意代码](#run-arbitrary-code-with-temporary-settings) (`#with(configs = {}, &arbitrary_code)`)
- [导入设置 / 导出设置](#import-settings--export-settings)
  - [导入配置设置](#import-config-settings) (`作为实例方法`)
    - [导入一组设置键（简单点号键列表）](#import-a-set-of-setting-keys-simple-dot-noated-key-list)
    - [使用自定义方法名导入（映射）](#import-with-custom-method-names-mappings)
    - [前缀化方法名](#prexify-method-name)
    - [将嵌套设置导入为原始 Qonfig::Settings 对象](#import-nested-settings-as-raw-qonfigsettings-objects)
    - [使用模式匹配导入](#import-with-pattern-matching)
    - [支持谓词类方法](#support-for-predicate-like-methods)
  - [导出配置设置](#export-config-settings) (`作为单例方法`)
- [验证](#validation)
  - [介绍](#introduction)
  - [键搜索模式](#key-search-pattern)
  - [基于 Proc 的验证](#proc-based-validation)
  - [基于方法的验证](#method-based-validation)
  - [预定义验证](#predefined-validations)
  - [自定义预定义验证器](#custom-predefined-validators)
  - [潜在设置值的验证](#validation-of-potential-setting-values)
- [文件操作](#work-with-files)
  - **设置键定义**
    - `(通过读取文件动态定义设置键的 DSL 方法)`
    - [从 YAML 文件加载](#load-from-yaml-file)
    - [公开 YAML](#expose-yaml) (`Rails` 式的基于环境的 YAML 配置)
    - [从 JSON 文件加载](#load-from-json-file)
    - [公开 JSON](#expose-json) (`Rails` 式的基于环境的 JSON 配置)
    - [从 ENV 加载](#load-from-env)
    - [从 \_\_END\_\_ 加载](#load-from-__end__) (即 `.load_from_self`)
    - [公开 \_\_END\_\_](#expose-__end__) (即 `.expose_self`)
  - **设置值**
    - `(将设置值从文件加载到已有定义键的配置对象的实例方法)`
    - [默认设置值文件](#default-setting-values-file)
    - [从 YAML 文件加载设置值](#load-setting-values-from-yaml-file-by-instance)
    - [从 JSON 文件加载设置值](#load-setting-values-from-json-file-by-instance)
    - [从 \_\_END\_\_ 加载设置值](#load-setting-values-from-__end__-by-instance)
    - [手动从文件加载设置值](#load-setting-values-from-file-manually-by-instance)
  - **日常操作**
    - [保存到 JSON 文件](#save-to-json-file) (`#save_to_json`)
    - [保存到 YAML 文件](#save-to-yaml-file) (`#save_to_yaml`)
- [插件](#plugins)
  - [toml](#plugins-toml) (支持 `TOML` 格式)
  - [pretty_print](#plugins-pretty_print) (美化控制台输出)
  - [vault](#plugins-vault) (支持 `Vault` 存储)
- [路线图](#roadmap)
- [构建](#build)
---

## 定义

- [定义与设置访问](#definition-and-access)
- [配置](#configuration)
- [继承](#inheritance)
- [组合](#composition)
- [Hash 表示](#hash-representation)
- [智能 Mixin](#smart-mixin) (`Qonfig::Configurable`)

---

### 定义与访问

- `setting(name, value = nil)` - 定义具有相应名称和值的设置；
- `setting(name) { setting(name, value = nil); ... }` - 定义嵌套设置，或重新打开现有的嵌套设置并定义新的嵌套设置；
- `re_setting(name, value = nil)`, `re_setting(name) { ... }` - 重新定义现有设置（或在原设置不存在时定义新设置）；
- 访问方式：[通过方法访问](#access-via-method), [通过索引方法 \[\] 访问](#access-via-index-method-),
  [.dig](#dig), [.slice](#slice), [.slice_value](#slice_value), [.subset](#subset);

```ruby
# --- 定义 ---
class Config < Qonfig::DataSet
  # 默认值为 nil
  setting :project_id

  # 嵌套设置
  setting :vendor_api do
    setting :host, 'vendor.service.com'
  end

  setting :enable_graphql, false

  # 重新打开嵌套设置
  setting :vendor_api do
    setting :user, 'simple_user'
  end

  # 重新定义现有设置 (舍弃旧的 - 创建新的)
  re_setting :vendor_api do
    setting :domain, 'api.service.com'
    setting :login, 'test_user'
  end

  # 深度嵌套
  setting :credentials do
    setting :user do
      setting :login, 'D@iVeR'
      setting :password, 'test123'
    end
  end
end

config = Config.new # 你的配置对象实例
```

#### 通过方法访问

```ruby
# 通过方法获取选项值
config.settings.project_id # => nil
config.settings.vendor_api.domain # => 'app.service.com'
config.settings.vendor_api.login # => 'test_user'
config.settings.enable_graphql # => false
```

#### 通过索引方法 [] 访问

- 不使用点号表示法：

```ruby
# 通过索引获取选项值（支持不区分类型 (string / symbol / mixed) 的访问）
config.settings[:project_id] # => nil
config.settings[:vendor_api][:domain] # => 'app.service.com'
config.settings[:vendor_api][:login] # => 'test_user'
config.settings[:enable_graphql] # => false

# 通过索引获取选项值（支持不区分类型 (string / symbol / mixed) 的访问）
config.settings['project_id'] # => nil
config.settings['vendor_api']['domain'] # => 'app.service.com'
config.settings['vendor_api']['login'] # => 'test_user'
config.settings['enable_graphql'] # => false

# 深入挖掘至值
config.settings[:vendor_api, :domain] # => 'app.service.com'
config.settings[:vendor_api, 'login'] # => 'test_user'

# 直接通过索引获取选项值（支持不区分类型访问）
config['project_id'] # => nil
config['enable_graphql'] # => false
config[:project_id] # => nil
config[:enable_graphql] # => false
```

- 使用点号表示法：

```ruby
config.settings['vendor_api.domain'] # => 'app.service.com'
config.settings['vendor_api.login'] # => 'test_user'

config['vendor_api.domain'] # => 'app.service.com'
config['vendor_api.login'] # => 'test_user'
```

#### .dig

- 不使用点号表示法：

```ruby
# 以 Hash#dig 的方式获取选项值（当所需键不存在时失败）；
config.dig(:vendor_api, :domain) # => 'app.service.com' # (键存在)
config.dig(:vendor_api, :login) # => Qonfig::UnknownSettingError # (键不存在)
```

- 使用点号表示法：

```ruby
config.dig('vendor_api.domain') # => 'app.service.com' # (键存在)
config.dig('vendor_api.login') # => Qonfig::UnknownSettingError # (键不存在)
```

#### .slice

- 不使用点号表示法：

```ruby
# 获取设置选项的 Hash 切片（当所需键不存在时失败）；
config.slice(:vendor_api) # => { 'vendor_api' => { 'domain' => 'app_service', 'login' => 'test_user' } }
config.slice(:vendor_api, :login) # => { 'login' => 'test_user' }
config.slice(:project_api) # => Qonfig::UnknownSettingError # (键不存在)
config.slice(:vendor_api, :port) # => Qonfig::UnknownSettingError # (键不存在)
```

- 使用点号表示法：

```ruby
config.slice('vendor_api.login') # => { 'loign' => 'test_user' }
config.slice('vendor_api.port') # => Qonfig::UnknownSettingError # (键不存在)
```

#### .slice_value

- 不使用点号表示法：

```ruby
# 使用给定的键集从设置选项切片中获取值
# (当所需键不存在时失败) (按切片方式工作)；

config.slice_value(:vendor_api) # => { 'domain' => 'app_service', 'login' => 'test_user' }
config.slice_value(:vendor_api, :login) # => 'test_user'
config.slice_value(:project_api) # => Qonfig::UnknownSettingError # (键不存在)
config.slice_value(:vendor_api, :port) # => Qonfig::UnknownSettingError # (键不存在)
```

- 使用点号表示法：

```ruby
config.slice_value('vendor_api.login') # => 'test_user'
config.slice_value('vendor_api.port') # => Qonfig::UnknownSettingError # (键不存在)
```

#### .subset

- 不使用点号表示法：

```ruby
# - 获取配置设置的子集（一组集合），表示为 Hash；
# - 每个键（或键集）代表对某个特定设置键的要求；

config.subset(:vendor_api, :enable_graphql)
# => { 'vendor_api' => { 'login' => ..., 'domain' => ... }, 'enable_graphql' => false }

config.subset(:project_id, [:vendor_api, :domain], [:credentials, :user, :login])
# => { 'project_id' => nil, 'domain' => 'app.service.com', 'login' => 'D@iVeR' }
```

- 使用点号表示法：

```ruby
config.subset('project_id', 'vendor_api.domain', 'credentials.user.login')
# => { 'project_id' => nil, 'domain' => 'app.service.com', 'login' => 'D@iVeR' }
```

---

### 配置

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

#### 通过 proc 配置

```ruby
config.configure do |conf|
  conf.enable_middlewares = true
  conf.geo_api.provider = :yandex_maps
  conf.testing.engine = :mini_test
end
```

#### 通过设置对象配置（按选项名称）

```ruby
config.settings.enable_middlewares = false
config.settings.geo_api.provider = :apple_maps
config.settings.testing.engine = :ultra_test
```

#### 通过设置对象配置（按设置键）

```ruby
config.settings[:enable_middlewares] = true
config.settings[:geo_api][:provider] = :rambler_maps
config.settings[:testing][:engine] = :mega_test
```

#### 通过 proc 即时配置

```ruby
config = Config.new do |conf|
  conf.enable_middlewares = false
  conf.geo_api.provider = :amazon_maps
  conf.testing.engine = :crypto_test
end
```

#### 使用 Hash

```ruby
config = Config.new(
  testing: { engine: :mini_test, parallel: false },
  geo_api: { provider: :rambler_maps },
  enable_middlewares: true
)
config.configure(enable_middlewares: false)
```

#### 同时使用 Hash 和 proc（proc 优先级更高）

```ruby
config = Config.new(enable_middlewares: true) do |conf|
  conf.testing.parallel = true
end

config.configure(geo_api: { provider: nil }) do |conf|
  conf.testing.engine = :rspec
end
```

---

### 继承

```ruby
class CommonConfig < Qonfig::DataSet
  setting :uploader, :fog
end

class ProjectConfig < CommonConfig
  setting :auth_provider, :github
end

project_config = ProjectConfig.new

# 继承的设置
project_config.settings.uploader # => :fog

# 自身的设置
project_config.settings.auth_provider # => :github
```

---

### 组合

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

# 来自 SharedConfig 的字段
project_config.settings.logger # => #<Logger:0x66f57048>

# 来自 ServerConfig 的字段
project_config.settings.server.port # => 12345
project_config.settings.server.address # => '0.0.0.0'

# 来自 DatabaseConfig 的字段
project_config.settings.db.user # => 'test'
project_config.settings.db.password # => 'testpaswd'
```

---

### Hash 表示

- 通过 `#to_h` 和 `#to_hash` 工作；
- 支持的选项：
  - `key_transformer:` - 可选的 proc，接收设置键并进行自定义转换；
  - `value_transformer:` - 可选的 proc，接收设置值并进行自定义转换；
  - `dot_style:` - (默认 `false`) 使用点号表示法表示设置键（同样支持转换）；

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
```

#### 默认行为（无选项）

```ruby
Config.new.to_h
# =>
{
  "serializers": {
    "json" => { "engine" => :ok },
    "hash" => { "engine" => :native },
  },
  "adapter" => { "default" => :memory_sync },
  "logger" => #<Logger:0x4b0d79fc>
}
```

#### 带转换

- 使用 `key_transformer` 和/或 `value_transformer`；

```ruby
key_transformer = -> (key) { "#{key}!!" }
value_transformer = -> (value) { "#{value}??" }

Config.new.to_h(key_transformer: key_transformer, value_transformer: value_transformer)
# =>
{
  "serializers!!": {
    "json!!" => { "engine!!" => "ok??" },
    "hash!!" => { "engine!!" => "native??" },
  },
  "adapter!!" => { "default!!" => "memory_sync??" },
  "logger!!" => "#<Logger:0x00007fcde799f158>??"
}
```

#### 点号风格格式

- 同样支持转换 (`key_transformer` 和 `value_transformer`)；

```ruby
Config.new.to_h(dot_style: true)
# =>
{
  "serializers.json.engine" => :ok,
  "serializers.hash.engine" => :native,
  "adapter.default" => :memory_sync,
  "logger" => #<Logger:0x4b0d79fc>,
}
```

```ruby
transformer = -> (value) { "$$#{value}$$" }

Config.new.to_h(dot_style: true, key_transformer: transformer, value_transformer: transformer)

# =>
{
  "$$serializers.json.engine$$" => "$$ok$$",
  "$$serializers.hash.engine$$" => "$$native$$",
  "$$adapter.default$$" => "$$memory_sync$$",
  "$$logger$$" => "$$#<Logger:0x00007fcde799f158>$$",
}
```

---

### 智能 Mixin

- 类级别：
  - `.configuration` - 设置定义；
  - `.configure` - 配置；
  - `.config` - 配置对象；
  - 设置定义是可继承的；
- 实例级别：
  - `#configure` - 配置；
  - `#config` - 配置对象；
  - `#shared_config` - 类级别的配置对象；

```ruby
# --- 使用方法 ---

class Application
  # 使其可配置
  include Qonfig::Configurable

  configuration do
    setting :user
    setting :password
  end
end

app = Application.new

# 类级别配置
Application.config.settings.user # => nil
Application.config.settings.password # => nil

# 实例级别配置
app.config.settings.user # => nil
app.config.settings.password # => nil

# 从实例访问类级别配置
app.shared_config.settings.user # => nil
app.shared_config.settings.password # => nil

# 类级别配置
Application.configure do |conf|
  conf.user = '0exp'
  conf.password = 'test123'
end

# 实例级别配置
app.configure do |conf|
  conf.user = 'admin'
  conf.password = '123test'
end

# 类拥有自己的配置对象
Application.config.settings.user # => '0exp'
Application.config.settings.password # => 'test123'

# 实例拥有自己的配置对象
app.config.settings.user # => 'admin'
app.config.settings.password # => '123test'

# 从实例访问类级别配置
app.shared_config.settings.user # => '0exp'
app.shared_config.settings.password # => 'test123'

# 等等... (所有与 Qonfig 相关的特性)
```

```ruby
# --- 继承 ---

class BasicApplication
  # 使其可配置
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
  # 扩展继承的定义
  configuration do
    setting :db do
      setting :adapter
    end
  end

  configure do |conf|
    conf.user = '0exp' # .user 继承自 BasicApplication
    conf.pswd = '123test' # .pswd 继承自 BasicApplication
    conf.db.adapter = 'pg'
  end
end

BasicApplication.config.to_h
{ 'user' => 'admin', 'pswd' => 'admin' }

GeneralApplication.config.to_h
{ 'user' => '0exp', 'pswd' => '123test', 'db' => { 'adapter' => 'pg' } }

# 等等... (所有与 Qonfig 相关的特性)
```

---

### 无需类定义的实例化

- 无继承：

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

- 带继承：

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

## 紧凑型配置 (Compacted config)

- [定义与实例化](#definition-and-instantiation)
  - [通过原始初始化](#by-raw-initialization)
  - [通过现有的 Qonfig::DataSet 类](#by-existing-qonfigdataset-class)
  - [通过现有的 Qonfig::DataSet 实例](#by-existing-qonfigdataset-instance)
  - [无需类定义的实例化](#instantiation-without-class-definition-1)
  - [验证 API](#validation-api-see-full-documentation)
- [设置读取器和写入器](#setting-readers-and-writers)
  - [读取](#reading-by-setting-name-and-index-method-with-dot-notation-support-and-indifferent-access)
  - [写入](#writing-by-setting-name-and-index-method-with-dot-notation-support-and-indifferent-access)
  - [谓词](#precitaes)

---

- `Qonfig::Compacted`：代表一个紧凑的配置对象，仅包含设置读取器、设置写入器和设置谓词 - 没有其他基于实例的功能：
- 设置键直接表示为实例方法（无需调用 `#settings`）；
- 支持索引式访问方法 (`[]`, `[]=`)；
- 完全支持 `Qonfig::DataSet` 定义 DSL 命令：
  - `setting`, `re_setting` [文档](#definition-and-access)
  - `validate`, `add_validator` [文档](#validation)
  - `load_from_self` [文档](#load-from-__end__), `load_from_yaml` [文档](#load-from-yaml-file), `load_from_json` [文档](#load-from-json-file), `load_from_toml` [文档](#plugins-toml);
  - `expose_self` [文档](#expose-__end__), `expose_yaml` [文档](#expose-yaml), `expose_json` [文档](#expose-json), `expose_toml` [文档](#plugins-toml)
  - `values_file` [文档](#default-setting-values-file)
- 支持潜在设置值的验证 `.valid_with?` [文档](#validation-of-potential-setting-values);
- 可以通过以下方式实例化：
  - 通过现有配置对象：`Qonfig::DataSet#compacted` 或 `Qonfig::Compacted.build_from(config, &configuration)`;
  - 从现有 `Qonfig::DataSet` 类：`Qonfig::DataSet.build_compacted`;
  - 通过直接实例化：`Qonfig::Compacted.new(settings_values = {}, &configuration)`;
  - 通过隐式实例构建（无需显式类定义）：`Qonfig::Compacted.build(&dsl_commands)`;
- 你也可以定义自己的实例方法；

---

### 定义与实例化

#### 通过原始初始化

```ruby
class Config < Qonfig::Compacted
  setting :api, 'google.com'
  setting :enabled, true
  setting :queue do
    setting :engine, :sidekiq
  end
end

config = Config.new(api: 'yandex.ru') do |conf|
  conf.enabled = false
end

config.api # => 'yandex.ru'
config.enabled # => false
config.queue.engine # => :sidekiq
```

#### 通过现有的 Qonfig::DataSet 类

```ruby
class Config < Qonfig::DataSet
  setting :api, 'google.com'
  setting :enabled, true
end

config = Config.build_compacted # 构建 Qonfig::Compacted 实例

config.api # => 'google.com'
config.enabled # => true
```

#### 通过现有的 Qonfig::DataSet 实例

- `Qonfig::DataSet#compacted`
- (或) `Qonfig::Compacted.build_from(config)`

```ruby
class Config < Qonfig::DataSet
  setting :api, 'google.com'
  setting :enabled, true
end

config = Config.new

compacted_config = config.compacted
# --- 或 ---
compacted_config = Qonfig::Compacted.build_from(config)

compacted_config.api # => 'google.com'
compacted_config.enabled # => true
```

#### 无需类定义的实例化

```ruby
config = Qonfig::Compacted.build do
  setting :api, 'google.ru'
  setting :enabled, true
end

config.api # => 'google.ru'
config.enabled # => true
```

#### 验证 API (见 [完整文档](#validation)):

```ruby
# 自定义验证器
Qonfig::Compacted.define_validator(:version_check) do |value|
  value.is_a?(Integer) && value < 100
end

class Config < Qonfig::Compacted
  setting :api, 'google.ru'
  setting :enabled, true
  setting :version, 2
  setting :queue { setting :engine, :sidekiq }

  # 完全支持原始验证 API
  validate :api, :string, strict: true
  validate :enabled, :boolean, strict: true
  validate :version, :version_check # 自定义验证器
  validate 'queue.#', :symbol
end

# 潜在值验证
Config.valid_with?(api: :yandex) # => false
Config.valid_with?(enabled: nil) # => false
Config.valid_with?(version: nil) # => false
Config.valid_with?(api: 'yandex.ru', enabled: false, version: 3) # => true

config = Config.new

# 实例验证
config.api = :yandex # => Qonfig::ValidationError (应为 string 类型)
config.version = nil # => Qonfig::ValidationError (不能为空)
config.queue.engine = 'sneakers' # => Qonfig::ValidationError (应为 symbol 类型)
```

---

### 设置读取器和写入器

```ruby
class Config < Qonfig::Compcated
  setting :api, 'google.ru'
  setting :enabled, true
  setting :queue do
    setting :engine, :sidekiq
    setting :workers_count, 10
  end
end

config = Config.new
```

#### 读取（通过设置名称和索引方法，支持点号表示法和不区分类型访问）

```ruby
# 通过设置名称
config.api # => 'google.ru'
config.enabled # => true
config.queue.engine # => :sidekiq
config.queue.workers_count # => 10

# 通过索引方法，支持点号表示法和不区分类型访问
config[:api] # => 'google.ru'
config['enabled'] # => true
config[:queue][:engine] # => :sidekiq
config['queue.workers_count'] # => 10
```

#### 写入（通过设置名称和索引方法，支持点号表示法和不区分类型访问）

```ruby
# 通过设置名称
config.api = 'yandex.ru'
config.queue.engine = :sidekiq
# 等等

# 通过索引方法，支持点号表示法和不区分类型访问
config['api'] = 'yandex.ru'
config['queue.engine'] = :sidekiq
config[:queue][:workers_count] = 5
```

#### 谓词 ([见完整文档](#settings-as-predicates))

```ruby
class Config < Qonfig::Compcated
  setting :enabled, true
  setting :api, 'yandex.ru'
  setting :queue do
    setting :engine, :sidekiq
  end
end

config = Config.new

config.enabled? # => true
config.enabled = nil
config.enabled? # => false

config.queue.engine? # => true
config.queue.engine =  nil
config.queue.engine? # => false

config.queue? # => true
```

---

## 交互

- [遍历设置键](#iteration-over-setting-keys) (`#each_setting`, `#deep_each_setting`)
- [配置键列表](#list-of-config-keys) (`#keys`, `#root_keys`)
- [配置重载](#config-reloading) (重载配置定义和选项值)
- [清除选项](#clear-options) (设置为 `nil`)
- [冻结状态](#frozen-state) (`.freeze_state!`, `#freeze!`, `#frozen?`)
- [设置作为谓词](#settings-as-predicates)
- [设置键是否存在](#setting-key-existence) (`#key?`/`#option?`/`#setting?`)
- [使用临时设置运行任意代码](#run-arbitrary-code-with-temporary-settings)

---

### 遍历设置键

- `#each_setting { |key, value| }`
  - 遍历根设置键；
- `#deep_each_setting(yield_all: false) { |key, value| }`
  - 遍历所有设置键（深度遍历）；
  - 键对象表示为用 `.` 连接的设置键名称字符串；
  - `yield_all:` 表示“产出所有配置对象”（包含最终值以及具有嵌套设置的根设置对象） (默认 `false`)；

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

# 每步结果：
{ 'db' => <Qonfig::Settings:0x00007ff8> }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

#### .deep_each_setting

```ruby
config.deep_each_setting { |key, value| { key => value } }

# 每步结果：
{ 'db.creds.user' => 'D@iVeR' }
{ 'db.creds.password' => 'test123' }
{ 'db.creds.data' => { test: false } }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

#### .deep_each_setting(yield_all: true)

```ruby
config.deep_each_setting(yield_all: true) { |key, value| { key => value } }

# 每步结果：
{ 'db' => <Qonfig::Settings:0x00007ff8> } # (yield_all: true)
{ 'db.creds' => <Qonfig::Settings:0x00002ff1> } # (yield_all: true)
{ 'db.creds.user' => 'D@iVeR' }
{ 'db.creds.password' => 'test123' }
{ 'db.crds.data' => { test: false } }
{ 'telegraf_url' => 'udp://localhost:8094' }
{ 'telegraf_prefix' => 'test' }
```

---

### 配置键列表

- `#keys` - 返回所有配置键的列表，采用点号表示法格式；
  - `all_variants:` - 获取配置键序列的所有可能变体 (默认 `false`)；
  - `only_root:` - 仅获取根配置键 (默认 `false`)；
- `#root_keys` - 返回根配置键列表 (是 `#keys(only_root: true)` 的别名)；

```ruby
# 注意：假设我们有以下配置

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

#### 默认行为

```ruby
config.keys

# 结果：
[
  "credentials.social.service",
  "credentials.social.login",
  "credentials.admin.enabled",
  "server.type",
  "server.options.os"
]
```

#### 所有键变体

```ruby
config.keys(all_variants: true)

# 结果：
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

#### 仅根键

```ruby
config.keys(only_root: true)

# 结果：
['credentials', 'server']
```

```ruby
config.root_keys

# 结果：
['credentials', 'server']
```

---

### 配置重载

- 方法签名：`#reload!(configurations = {}, &configuration)`;

```ruby
# -- 配置示例 ---

class Config < Qonfig::DataSet
  setting :db do
    setting :adapter, 'postgresql'
  end

  setting :logger, Logger.new(STDOUT)
end

config = Config.new

config.settings.db.adapter # => 'postgresql'
config.settings.logger # => #<Logger:0x00007ff9>
```

```ruby
# --- 重新定义某些设置 (或添加新设置) --

config.configure { |conf| conf.logger = nil } # 重新定义某些设置 (将被重载)

# 重新定义并追加设置
class Config
  setting :db do
    setting :adapter, 'mongoid' # 重新定义默认值
  end

  setting :enable_api, false # 追加新设置
end
```

```ruby
# --- 重载 ---

# 重载设置
config.reload!

config.settings.db.adapter # => 'mongoid'
config.settings.logger # => #<Logger:0x00007ff9> (从默认值重载)
config.settings.enable_api # => false (新设置)

# 带即时配置的重载
config.reload!(db: { adapter: 'oracle' }) do |conf|
  conf.enable_api = true # 即时更改
end

config.settings.db.adapter # => 'oracle'
config.settings.logger # => #<Logger:0x00007ff9>
config.settings.enable_api # => true # 来自即时更改的值
```

---

### 清除选项

- 将所有配置设置设为 `nil`；
- 方法签名：`#clear!`;

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

# 清除所有选项
config.clear!

config.settings.database.user # => nil
config.settings.database.password # => nil
config.settings.web_api.endpoint # => nil
```

---

### 冻结状态

#### 实例级别

- 方法签名：`#freeze!`;

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

#### 定义级别

- DSL 方法签名：`freeze_state!`
- 表示所有配置实例都应被冻结；
- `freeze_state!` DSL 命令不可继承（子类和组合的配置类将不会拥有此声明）；

```ruby
# --- 基类 ---
class Config < Qonfig::DataSet
  setting :test, true
  freeze_state!
end

config = Config.new
config.frozen? # => true
config.settings.test = false # => Qonfig::FrozenSettingsError

# --- 子类 ---
class InheritedConfig < Config
end

inherited_config = InheritedConfig.new
config.frozen? # => false
config.settings.test = false # 正常 :)
```

---

### 设置作为谓词

- 谓词形式：设置名称末尾带有 `?`；
- `nil` 和 `false` 设置值表示 `false`；
- 其他设置值表示 `true`；
- 设置根节点始终返回 `true`；

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

# 谓词
config.settings.database.user? # => false (nil => false)
config.settings.database.host? # => true ('google.com' => true)
config.settings.database.engine.driver? # => true ('postgres' => true)

# 设置根节点始终返回 true
config.settings.database? # => true
config.settings.database.engine? # => true

config.configure do |conf|
  conf.database.user = '0exp'
  conf.database.host = false
  conf.database.engine.driver = true
end

# 谓词
config.settings.database.user? # => true ('0exp' => true)
config.settings.database.host? # => false (false => false)
config.settings.database.engine.driver? # => true (true => true)
```

---

### 设置键是否存在

- 支持 **动态类数组格式** 和 **规范点号表示法格式**；
- 如果具体键存在，则返回 `true`；
- 如果具体键不存在，则返回 `false`；
- **动态类数组格式**：
  - `#key?(*key_path)` / `#option?(*key_path)` / `#setting?(*key_path)`;
  - `*key_path` - 一个由 symbol 和 string 组成的数组，表示指向具体设置键的路径；
  - (例如，`config.key?(:credentials, :user)` 尝试检查 `config.settings.credentials.user` 是否存在)；
- **点号表示法格式**：
  - `#key?(key)` / `#option?(key)` / `#setting?(key)`;
  - `key` - 点号表示法格式的字符串；
  - (例如：`config.key?('credentials.user')` 尝试检查 `config.settings.crednetials.user` 是否存在)；

```ruby
class Config < Qonfig::DataSet
  setting :credentials do
    setting :user, 'D@iVeR'
    setting :password, 'test123'
  end
end

config = Config.new

# --- 类数组格式 ---
config.key?('credentials', 'user') # => true
config.key?('credentials', 'token') # => false (键不存在)

# --- 点号表示法格式 ---
config.key?('credentials.user') # => true
config.key?('credentials.token') # => false (键不存在)

config.key?('credentials') # => true
config.key?('que_adapter') # => false (键不存在)

# 别名
config.setting?('credentials') # => true
config.option?(:credentials, :password) # => true
config.option?('credentials.password') # => true
```

---

### 使用临时设置运行任意代码

- 提供一种方式，在临时指定设置的情况下运行任意代码；
- 你的任意代码也可以临时更改任何设置 - 所有设置随后将恢复到原始状态；
- (这在测试中运行代码示例非常方便（通过替换配置）)；
- 它是完全线程安全的 `:)`；

```ruby
class Config < Qonfig::DataSet
  setting :queue do
    setting :adapter, :sidekiq
    setting :options, {}
  end
end

config = Config.new

# 使用临时 queue.adapter 设置运行一段代码块
config.with(queue: { adapter: 'que' }) do
  # 你更改后的设置
  config.settings.queue.adapter # => 'que'

  # 你的代码也可以临时更改设置
  config.settings.queue.options = { concurrency: 10 }

  # ...你的其他代码...
end

# 原始设置未改变 :)
config.settings.queue.adapter # => :sidekiq
config.settings.queue.options # => {}
```

---

## 导入设置 / 导出设置

- [导入配置设置](#import-config-settings) (`作为实例方法`)
- [导出配置设置](#export-config-settings) (`作为单例方法`)

有时项目中配置的嵌套层级较高，会导致代码写起来相当“冗长”
(例如 `config.settings.web_api.credentials.account.auth_token`)。以这种方式频繁访问配置很不方便 - 因此开发者通常用方法或变量来封装此类代码。为了让开发者的生活更轻松，`Qonfig` 提供了一个特殊的导入 API 来简化配置导入 (提供 `.import_settings` DSL)，并允许从配置对象即时导出配置设置 (提供 `#export_settings` 配置方法)。

你可以在设置键名称中使用类 RabbitMQ 的模式匹配：
  - 如果当前嵌套级别的设置键名称不重要 - 使用 `*`；
  - 如果设置键名称和嵌套级别都不重要 - 使用 `#`
  - 示例：
    - `db.settings.user` - 匹配 `db.settings.user` 设置；
    - `db.settings.*` - 匹配 `db.settings` 设置组内的所有设置键；
    - `db.*.user` - 匹配 `db` 设置组第一层级的所有 `user` 设置键；
    - `#.user` - 匹配所有 `user` 设置键；
    - `service.#.password` - 匹配 `service` 设置组所有层级中的所有 `password` 设置键；
    - `#` - 匹配所有设置键；
    - `*` - 匹配根级别的所有设置键；
    - 等等；

---

### 导入配置设置

- `Qonfig::Imports` - 一个特殊的 mixin，提供了便捷的 DSL 来处理配置导入功能 (`.import_settings` 方法)；
- `.import_settings` - 将配置设置 (来自配置实例) 导入为类实例方法的 DSL 方法；
- (**重要**) `import_settings` 将配置设置导入为访问配置设置的访问方法 (为你的配置创建 `attr_reader`)；
- 生成的方法可以用作谓词 (在末尾带 `?` 符号)；
- 你可以通过指定 `accessor: true` 选项来生成 `attr_accessor`
  (请小心：当你尝试给具有嵌套设置的配置选项赋值时，可能会出现 `Qonfig::AmbiguousSettingValueError`)；
- 签名：`.import_settings(config_object, *setting_keys, mappings: {}, prefix: '', raw: false)`
  - `config_object` - 一个 `Qonfig::DataSet` 实例，其配置设置将被导入；
  - `*setting_keys` - 一个点号表示法的配置设置键数组，需要被导入
    (点号表示的键是用 `dot` 符号分隔的描述嵌套设置键各部分的字符串)；
    - 点号表示键的最后一部分将成为设置访问实例方法的名称；
  - `mappings:` - 一个键映射表，为每个导入的设置描述自定义方法名；
  - `prefix:` - 为设置访问方法名添加自定义前缀；
  - `raw:` - 使用嵌套设置作为对象或将其 Hash 化 (`false` 为默认值 (意味着“Hash 化嵌套设置”))；
  - `accessor:` - 为导入的配置设置生成 `attr_accessor` (`false` 为默认值 (意味着“仅生成 `attr_reader`”))；
---

假设我们有一个带有深度嵌套键的配置：

```ruby
# 注意：(Qonfig::DataSet.build 创建一个类并立即实例化它)
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

让我们看看能做什么 :)

- [导入一组设置键（简单点号键列表）](#import-a-set-of-setting-keys-simple-dot-noated-key-list)
- [使用自定义方法名导入（映射）](#import-with-custom-method-names-mappings)
- [前缀化方法名](#prexify-method-name)
- [将嵌套设置导入为原始 Qonfig::Settings 对象](#import-nested-settings-as-raw-qonfigsettings-objects)
- [使用模式匹配导入](#import-with-pattern-matching)
- [支持谓词类方法](#support-for-predicate-like-methods)

#### 导入一组设置键（简单点号键列表）

- 点号表示键的最后一部分将成为设置访问实例方法的名称；

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

#### 使用自定义方法名导入（映射）

- `mappings:` 定义了一个键映射表，为每个导入的设置描述自定义方法名；

```ruby
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig, mappings: {
    account_data: 'web_api.credentials.account', # 注意：访问方法命名为 "account_data"
    secret_token: 'web_api.credentials.account.auth_token' # 注意：访问方法命名为 "secret_token"
  })
end

service = ServiceObject.new

service.account_data # => { "login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA" }
service.auth_token # => "IAdkoa0@()1239uA"
```

#### 前缀化方法名

- `prefix:` - 为设置访问方法名添加自定义前缀；

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

service.config_account # => { login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA" }
service.config_secret_token # => "IAdkoa0@()1239uA"
```

#### 支持谓词类方法

- 生成的方法可以用作谓词 (在末尾带 `?` 符号)；

```ruby
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig,
    'web_api.credentials.account',
    mappings: { secret_token: 'web_api.credentials.account.auth_token' },
  )
end

service = ServiceObject.new

service.account? # => true
service.secret_token? # => true
```

#### 将嵌套设置导入为原始 Qonfig::Settings 对象

- `raw: false` 是默认值 (Hash 化嵌套设置)

```ruby
# 注意：将嵌套设置导入为原始对象 (raw: true)
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
# 注意：将嵌套设置导入为转换后的 Hash 对象 (raw: false) (默认行为)
class ServiceObject
  include Qonfig::Imports

  import_settings(AppConfig, 'web_api.credentials', raw: false)
end

service = ServiceObject.new

service.credentials # => { "account" => { "login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA"} }
```

#### 使用模式匹配导入

- 仅导入根键：`import_settings(config_object, '*')`;
- 导入所有键：`import_settings(config_object, '#')`;
- 导入键的子集：`import_settings(config_object, 'group.*.group.#')` (使用模式匹配)；

```ruby
class ServiceObject
  include Qonfig::Imports

  # 导入 web_api.credentials 子集中的所有设置
  import_settings(AppConfig, 'web_api.credentials.#')
  # 生成的实例方法：
  #   => service.account
  #   => service.login
  #   => service.auth_token

  # 仅导入 web_api.credentials.account 子集的根键
  import_settings(AppConfig, 'web_api.credentials.account.*')
  # 生成的实例方法：
  #   => service.login
  #   => service.auth_token

  # 仅导入根键
  import_settings(AppConfig, '*')
  # 生成的实例方法：
  #   => service.web_api
  #   => service.graphql_api

  # 导入所有键
  import_settings(AppConfig, '#')
  # 生成的实例方法：
  #   => service.web_api
  #   => service.credentials
  #   => service.account
  #   => service.login
  #   => service.auth_token
  #   => service.graphql_api
end
```

---

### 导出配置设置

- 工作方式与 `.import_settings` 相同 [文档](#import-config-settings) (见上述示例和文档 `:)`)
- 所有配置对象都可以将其设置导出到任意对象中作为单例方法；
- (**重要**) `export_settings` 将配置设置导出为访问配置设置的访问方法 (为你的配置创建 `attr_reader`)；
- 生成的方法可以用作谓词 (在末尾带 `?` 符号)；
- 你可以通过指定 `accessor: true` 选项来生成 `attr_accessor`
  (请小心：当你尝试给具有嵌套设置的配置选项赋值时，可能会出现 `Qonfig::AmbiguousSettingValueError`)；
- 签名：`#export_settings(exportable_object, *setting_keys, mappings: {}, prefix: '', raw: false)`:
  - `exportable_object` - 一个用于导出的任意对象；
  - `*setting_keys` - 一个点号表示法的配置设置键数组，需要被导出
    (点号表示的键是用 `dot` 符号分隔的描述嵌套设置键各部分的字符串)；
    - 点号表示键的最后一部分将成为设置访问实例方法的名称；
  - `mappings:` - 一个键映射表，为每个导出的设置描述自定义方法名；
  - `prefix:` - 为设置访问方法名添加自定义前缀；
  - `raw:` - 使用嵌套设置作为对象或将其 Hash 化 (`false` 为默认值 (意味着“Hash 化嵌套设置”))；
 - `accessor:` - 为导入的配置设置生成 `attr_accessor` (`false` 为默认值 (意味着“仅生成 `attr_reader`”))；

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
```

```ruby
# 注意：将设置导出为访问配置设置的方法
config.export_settings(service, 'web_api.credentials.account', prefix: 'config_')

service.config_account # => { "login" => "D@iVeR", "auth_token" => "IAdkoa0@()1239uA" }
```

```ruby
# 注意：使用模式匹配导出设置
config.export_settings(service, '*') # 导出根设置

service.web_api # => { 'credentials' => { 'account' => { ... } }, 'graphql_api' => false }
service.graphql_api # => false
```

```ruby
# 注意：谓词
config.export_settings(service, '*')

config.web_api? # => true
config.graphql_api? # => false
```

---

## 验证

- [介绍](#introduction)
- [键搜索模式](#key-search-pattern)
- [基于 Proc 的验证](#proc-based-validation)
- [基于方法的验证](#method-based-validation)
- [预定义验证](#predefined-validations)
- [自定义预定义验证器](#custom-predefined-validators)
- [潜在设置值的验证](#validation-of-potential-setting-values)

---

### 介绍

Qonfig 提供了一个轻量级的 DSL 用于定义验证，并在设置值被初始化或更改的所有情况下生效。
设置被视为键进行验证（与[特定字符串模式](#key-search-pattern)匹配）。
你可以验证一组键，也可以单独验证每个键。
如果你想完全检查配置对象，可以定义自定义验证。

**特性**:
- 验证在任何设置变更时被调用：
  - 在数据集实例化期间；
  - 在赋值新值时；
  - 在调用 `#reload!` 时；
  - 在调用 `#clear!` 时；
- 提供 `strict` 和 `non-strict` 行为 (分别由 `strict: true` 和 `strict: false` 控制)：
  - `strict: false` 忽略值为 `nil` 的设置验证 (允许 `nil` 值)；
  - `strict: true` 不忽略值为 `nil` 的设置验证；
  - 默认使用 `strict: false`；
- 提供特殊的[键搜索模式](#key-search-pattern)用于匹配设置键名称；
- 你可以在不进行任何赋值的情况下验证潜在的设置值 ([文档](#validation-of-potential-setting-values))
- 使用[键搜索模式](#key-search-pattern)定义哪些设置键应该被验证；
- 你可以定义自己的自定义验证逻辑并完全验证数据集实例；
- 验证逻辑应返回 **truthy** 或 **falsy** 值；
- 支持两种验证技术 (**基于 proc** ([文档](#proc-based-validation)) 和 **基于数据集方法** ([文档](#method-based-validation))):
  - **基于 proc** (`设置验证`) ([文档](#proc-based-validation))
    ```ruby
      validate('db.user', strict: true) do |value|
        value.is_a?(String)
      end
    ```
  - **基于 proc** (`数据集验证`) ([文档](#proc-based-validation))
    ```ruby
      validate(strict: false) do
        settings.user == User[1]
      end
    ```
  - **基于数据集方法** (`设置验证`) ([文档](#method-based-validation))
    ```ruby
      validate 'db.user', by: :check_user, strict: true

      def check_user(value)
        value.is_a?(String)
      end
    ```
  - **基于数据集方法** (`数据集验证`) ([文档](#method-based-validation))
    ```ruby
      validate by: :check_config, strict: false

      def check_config
        settings.user == User[1]
      end
    ```
- 提供**一套标准验证** ([文档](#predefined-validations)):
  - DSL: `validate 'key.pattern', :predefned_validator`;
  - 支持 `strict` 行为；
- 你可以定义自己的预定义验证器 (类相关的和全局相关的) ([文档](#custom-predefined-validators));

---

### 键搜索模式

**键搜索模式**遵循以下规则：

- 采用类 `RabbitMQ` 的键模式规则；
- 采用字符串格式；
- 嵌套配置由一组用 `.` 符号分隔的键定义；
- 如果当前嵌套级别的设置键名称不重要 - 使用 `*`；
- 如果设置键名称和嵌套级别都不重要 - 使用 `#`
- 示例：
  - `db.settings.user` - 匹配 `db.settings.user` 设置；
  - `db.settings.*` - 匹配 `db.settings` 设置组内的所有设置键；
  - `db.*.user` - 匹配 `db` 设置组第一层级的所有 `user` 设置键；
  - `#.user` - 匹配所有 `user` 设置键；
  - `service.#.password` - 匹配 `service` 设置组所有层级中的所有 `password` 设置键；
  - `#` - 匹配所有设置键；
  - `*` - 匹配根级别的所有设置键；
  - 等等；

---

### 基于 Proc 的验证

- 你的 proc 应返回 truthy 或 falsy 值；
- 默认忽略 `nil` 值；
- 设置 `strict: true` 以禁用对 `nil` 的忽略 (默认 `strict: false`)；
- 如何验证设置键：
  - 定义带属性的 proc：`validate 'your.setting.path' do |value|; end`
  - proc 将接收设置值；
- 如何验证数据集实例：
  - 定义不带设置键模式的 proc：`validate do; end`;

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

  # 验证:
  #   - db.password
  validate 'db.password' do |value|
    value.is_a?(String)
  end

  # 验证:
  #   - service.address
  #   - service.protocol
  #   - service.creds.user
  validate 'service.#' do |value|
    value.is_a?(String)
  end

  # 验证:
  #   - 数据集实例
  validate do # 注意：没有设置键模式
    settings.enabled == false
  end

  # 不忽略 `nil` (strict: true)
  validate(:token, strict: true) do
    value.is_a?(String)
  end
end

config = Config.new
config.settings.db.password = 123 # => Qonfig::ValidationError (应为 string)
config.settings.service.address = 123 # => Qonfig::ValidationError (应为 string)
config.settings.service.protocol = :http # => Qonfig::ValidationError (应为 string)
config.settings.service.creds.admin = :billikota # => Qonfig::ValidationError (应为 string)
config.settings.enabled = true # => Qonfig::ValidationError (并非 `true`)

config.settings.db.password = nil # 正常, nil 被忽略 (non-strict 行为)
config.settings.token = nil # => Qonfig::ValidationError (nil 不被忽略, strict 行为) (应为 string 类型)
```

---

### 基于方法的验证

- 方法应返回 truthy 或 falsy 值；
- 默认忽略 `nil` 值；
- 设置 `strict: true` 以禁用对 `nil` 的忽略 (默认 `strict: false`)；
- 如何验证设置键：
  - 定义验证：`validate 'db.*.user', by: :your_custom_method`;
  - 定义带属性的方法：`def your_custom_method(setting_value); end`
- 如何验证配置实例
  - 定义验证：`validate by: :your_custom_method`
  - 定义不带属性的方法：`def your_custom_method; end`

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

  # 验证:
  #   - services.counts.google
  #   - services.counts.rambler
  #   - services.minimals.google
  #   - services.minimals.rambler
  validate 'services.#', by: :check_presence

  # 验证:
  #   - 数据集实例
  validate by: :check_state # 注意：没有设置键模式

  # 不忽略 `nil` (strict: true)
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
config.settings.minimals.rambler = 'no' # => Qonfig::ValidationError (应为数值)

config.settings.counts.rambler = nil # 正常, nil 被忽略 (默认 non-strict 行为)
config.settings.enabled = nil # 正常, nil 被忽略 (默认 non-strict 行为)
config.settings.timeout = nil # => Qonfig::ValidationError (nil 不被忽略, strict 行为) (应为数值类型)
```

---

### 预定义验证

- DSL: `validate 'key.pattern', :predefned_validator`
- 默认忽略 `nil` 值；
- 设置 `strict: true` 以禁用对 `nil` 的忽略 (默认 `strict: false`)；
- 预定义验证器：
  - `:not_nil`
  - `:integer`
  - `:float`
  - `:numeric`
  - `:big_decimal`
  - `:array`
  - `:hash`
  - `:string`
  - `:symbol`
  - `:text` (`string` 或 `symbol`)
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
end # 注意：全部正确 :)

config.settings.ignorance = nil # => Qonfig::ValidationError (不能为空)
```

---

### 自定义预定义验证器

- DSL: `.define_validator(name, &validation) { |value| ... }` - 创建你自己的预定义验证器；
- **类级别**: 定义仅与具体配置类相关的验证器；
- **全局级别**: 定义与所有配置类相关的验证器 (`Qonfig::DataSet.define_validator`)；
- 你可以在类级别重新定义任何全局和继承的验证器；
- 你可以在全局级别重新定义 `Qonfig::DataSet` 上任何已注册的全局验证器；

#### 定义你自己的类级别验证器

```ruby
class Config < Qonfig::DataSet
  # 注意：定义
  define_validator(:user_type) { |value| value.is_a?(User) }

  setting :admin # 某个键

  # 注意：使用
  validate :admin, :user_type
end
```

#### 定义新的全局验证器

```ruby
Qonfig::DataSet.define_validator(:secured_value) do |value|
  value == '***'
end

class Config < Qonfig::DataSet
  setting :password
  validate :password, :secured_value
end
```

#### 在子类中重新定义现有验证器

```ruby
class Config < Qonfig::DataSet
  # 注意：仅在 Config 类中重新定义现有的 :text 验证器
  define_validator(:text) { |value| value.is_a?(String) }

  # 注意：可以在子类中重新定义的某种自定义验证器
  define_validator(:user) { |value| value.is_a?(User) }
end

class SubConfig < Qonfig
  define_validator(:user) { |value| value.is_a?(AdminUser) } # 注意：重新定义继承的 :user 验证器
end
```

#### 重新定义现有全局验证器

```ruby
# 注意：重新定义已经存在的 :numeric 验证器
Qonfig::DataSet.define_validator(:numeric) do |value|
  value.is_a?(Numeric) || (value.is_a?(String) && value.match?(/\A\d+\.*\d+\z/))
end
```

---

### 潜在设置值的验证

- (**实例级别**) `#valid_with?(setting_values = {}, &configuration)` - 检查当前配置实例在使用传入配置后是否有效；
- (**类级别**) `.valid_with?(setting_values = {}, &configuration)` - 检查潜在配置实例在使用传入配置后是否有效；
- 不执行实际赋值；

#### #valid_with? (实例级别)

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
config.valid_with?(enabled: 123) # => false (应为 boolean 类型)
config.valid_with?(enabled: true, queue: { adapter: Sidekiq }) # => false (queue.adapter 应为 string 类型)

# 同样支持 do-config 表示法
config.valid_with?(enabled: true) do |conf|
  conf.queue.adapter = :sidekiq
end
# => false (queue.adapter 应为 string 类型)
```

#### .valid_with? (类级别)

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
Config.valid_with?(enabled: 123) # => false (应为 boolean 类型)
Config.valid_with?(enabled: true, queue: { adapter: Sidekiq }) # => false (queue.adapter 应为 string 类型)

# 同样支持 do-config 表示法
Config.valid_with?(enabled: true) do |config|
  config.queue.adapter = :sidekiq
end
# => false (queue.adapter 应为 string 类型)
```

---

## 文件操作

- **设置键定义**
  - [从 YAML 文件加载](#load-from-yaml-file)
  - [公开 YAML](#expose-yaml) (`Rails` 式的基于环境的 YAML 配置)
  - [从 JSON 文件加载](#load-from-json-file)
  - [公开 JSON](#expose-json) (`Rails` 式的基于环境的 JSON 配置)
  - [从 ENV 加载](#load-from-env)
  - [从 \_\_END\_\_ 加载](#load-from-__end__) (即 `load_from_self`)
  - [公开 \_\_END\_\_](#expose-__end__) (即 `expose_self`)
- **设置值**
  - [默认设置值文件](#default-setting-values-file)
  - [从 YAML 文件加载设置值](#load-setting-values-from-yaml-file-by-instance)
  - [从 JSON 文件加载设置值](#load-setting-values-from-json-file-by-instance)
  - [从 \_\_END\_\_ 加载设置值](#load-setting-values-from-__end__-by-instance)
  - [手动从文件加载设置值](#load-setting-values-from-file-manually-by-instance)
- **日常操作**
  - [保存到 JSON 文件](#save-to-json-file) (`save_to_json`)
  - [保存到 YAML 文件](#save-to-yaml-file) (`save_to_yaml`)

---

### 从 YAML 文件加载

- 支持 `ERB`；
- `:strict` 模式 (当所需的 yaml 文件不存在时的失败行为)：
  - `true` (默认) - 导致 `Qonfig::FileNotFoundError`；
  - `false` - 不执行任何操作，忽略当前命令；
- `:replace_on_merge` - 发生键冲突时是否应被替换，否则将进行深度合并 (默认行为)；

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
# --- 严格模式 ---
class Config < Qonfig::DataSet
  setting :nonexistent_yaml do
    load_from_yaml 'nonexistent_yaml.yml', strict: true # 默认为 true
  end

  setting :another_key
end

Config.new # => Qonfig::FileNotFoundError

# --- 非严格模式 ---
class Config < Qonfig::DataSet
  settings :nonexistent_yaml do
    load_from_yaml 'nonexistent_yaml.yml', strict: false
  end

  setting :another_key
end

Config.new.to_h # => { "nonexistent_yaml" => {}, "another_key" => nil }
```

---

### 公开 YAML

- 以 Rails 式的方式（带有环境）从 YAML 文件加载配置；
- 工作方式与 `load_from_yaml` 相同；
- `via:` - 如何确定环境：
    - `:file_name`
        - 从文件名中包含 `:env` 部分的 YAML 文件加载配置；
    - `:env_key`
        - 从 YAML 文件加载配置；
        - 具体配置应定义在名为 `:env` 的根键下；
- `env:` - 你的环境名称 (必须是 `String`, `Symbol` 或 `Numeric` 类型)；
- `strict:` - 要求使用环境的文件和/或键必须存在：
    - `true`:
        - 文件必须存在；
        - (如果使用 `via: :env_key`) 根键 `:env` 必须存在；
        - 如果文件不包含所需的 env 键 (如果使用 `via: :env` 键)，则抛出 `Qonfig::ExposeError`；
        - 如果所需文件不存在，则抛出 `Qonfig::FileNotFoundError`；
    - `false`:
        - 文件非必须；
        - (如果使用 `via: :env_key`) 根键 `:env` 非必须；
- `:replace_on_merge` - 发生键冲突时是否应被替换，否则将进行深度合并 (默认行为)；

#### 环境定义为 YAML 文件的根键

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
  expose_yaml 'config/project.yml', via: :env_key, env: :production # 从 production 环境加载

  # 注意：在类 rails 应用程序中，你可以使用：
  expose_yaml 'config/project.yml', via: :env_key, env: Rails.env
end

config = Config.new

config.settings.enable_api_mode # => true (来自 :production 键子集)
config.settings.google_key # => asd1-39sd-55aI-O92x (来自 :production 键子集)
config.settings.window.width # => 50 (来自 :production 键子集)
config.settings.window.height # => 150 (来自 :production 键子集)
```

#### 环境定义为 YAML 文件名的一部分

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
  # 注意：文件名属性应描述为不含环境部分的形式
  expose_yaml 'config/sidekiq.yml', via: :file_name, env: :staging # 从 staging 环境加载

  # 注意：在类 rails 应用程序中，你可以使用：
  expose_yaml 'config/sidekiq.yml', via: :file_name, env: Rails.env
end

config = SidekiqConfig.new

config.settings.web.username # => staging_admin (来自 sidekiq.staging.yml)
config.settings.web.password # => staging_password (来自 sidekiq.staging.yml)
```

---

### 从 JSON 文件加载

- 支持 `ERB`；
- `:strict` 模式 (当所需的 yaml 文件不存在时的失败行为)：
  - `true` (默认) - 导致 `Qonfig::FileNotFoundError`；
  - `false` - 不执行任何操作，忽略当前命令；
- `:replace_on_merge` - 发生键冲突时是否应被替换，否则将进行深度合并 (默认行为)；

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
# --- 严格模式 ---
class Config < Qonfig::DataSet
  setting :nonexistent_json do
    load_from_json 'nonexistent_json.json', strict: true # 默认为 true
  end

  setting :another_key
end

Config.new # => Qonfig::FileNotFoundError

# --- 非严格模式 ---
class Config < Qonfig::DataSet
  settings :nonexistent_json do
    load_from_json 'nonexistent_json.json', strict: false
  end

  setting :another_key
end

Config.new.to_h # => { "nonexistent_json" => {}, "another_key" => nil }
```

---

### 公开 JSON

- 以 Rails 式的方式（带有环境）从 JSON 文件加载配置；
- 工作方式与 `load_from_jsom`/`expose_yaml` 相同；
- `via:` - 如何确定环境：
    - `:file_name`
        - 从文件名中包含 `:env` 部分的 JSON 文件加载配置；
    - `:env_key`
        - 从 JSON 文件加载配置；
        - 具体配置应定义在名为 `:env` 的根键下；
- `env:` - 你的环境名称 (必须是 `String`, `Symbol` 或 `Numeric` 类型)；
- `strict:` - 要求使用环境的文件和/或键必须存在：
    - `true`:
        - 文件必须存在；
        - (如果使用 `via: :env_key`) 根键 `:env` 必须存在；
        - 如果文件不包含所需的 env 键 (如果使用 `via: :env` 键)，则抛出 `Qonfig::ExposeError`；
        - 如果所需文件不存在，则抛出 `Qonfig::FileNotFoundError`；
    - `false`:
        - 文件非必须；
        - (如果使用 `via: :env_key`) 根键 `:env` 非必须；
- `:replace_on_merge` - 发生键冲突时是否应被替换，否则将进行深度合并 (默认行为)；

#### 环境定义为 JSON 文件的根键

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
  expose_json 'config/project.json', via: :env_key, env: :production # 从 production 环境加载

  # 注意：在类 rails 应用程序中，你可以使用：
  expose_json 'config/project.json', via: :env_key, env: Rails.env
end

config = Config.new

config.settings.api_mode_enabled # => true (来自 :production 键子集)
config.settings.logging # => true (来自 :production 键子集)
config.settings.db_driver # => "rom" (来自 :production 键子集)
config.settings.throttle_requests # => true (来自 :production 键子集)
config.settings.credentials # => {} (来自 :production 键子集)
```

#### 环境定义为 JSON 文件名的一部分

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
  # 注意：文件名属性应描述为不含环境部分的形式
  expose_json 'config/sidekiq.json', via: :file_name, env: :staging # 从 staging 环境加载

  # 注意：在类 rails 应用程序中，你可以使用：
  expose_json 'config/sidekiq.json', via: :file_name, env: Rails.env
end

config = SidekiqConfig.new

config.settings.web.username # => "staging_admin" (来自 sidekiq.staging.json)
config.settings.web.password # => "staging_password" (来自 sidekiq.staging.json)
```

---

### 从 ENV 加载

- `:convert_values` (默认 `false`)：
  - `'t'`, `'T'`, `'true'`, `'TRUE'` - 转换为 `true`；
  - `'f'`, `'F'`, `'false'`, `'FALSE'` - 转换为 `false`；
  - `1`, `23` 等 - 转换为 `Integer`；
  - `1.25`, `0.26` 等 - 转换为 `Float`；
  - `1, 2, test`, `FALSE,Qonfig` (包含至少一个逗号且未加引号的字符串) -
    转换为递归转换后的 `Array`；
  - `'"please, test"'`, `"'test, please'"` (带引号的字符串) - 转换为去掉引号的 `String`；
- `:prefix` - 加载以指定前缀开头的 ENV 变量：
  - `nil` (默认) - 空前缀；
  - `Regexp` - 匹配正则模式的名称；
  - `String` - 以传入字符串开头的名称；
- `:trim_prefix` (默认 `false`)；

```ruby
# 一些环境变量
ENV['QONFIG_BOOLEAN'] = 'true'
ENV['QONFIG_INTEGER'] = '0'
ENV['QONFIG_STRING'] = 'none'
ENV['QONFIG_ARRAY'] = '1, 2.5, t, f, TEST'
ENV['QONFIG_MESSAGE'] = '"Hello, Qonfig!"'
ENV['RUN_CI'] = '1'

class Config < Qonfig::DataSet
  # 嵌套
  setting :qonfig do
    load_from_env convert_values: true, prefix: 'QONFIG' # 或 /\Aqonfig.*\z/i
  end

  setting :trimmed do
    load_from_env convert_values: true, prefix: 'QONFIG_', trim_prefix: true # 去掉前缀
  end

  # 在根部
  load_from_env
end

config = Config.new

# 自定义
config.settings['qonfig']['QONFIG_BOOLEAN'] # => true ('true' => true)
config.settings['qonfig']['QONFIG_INTEGER'] # => 0 ('0' => 0)
config.settings['qonfig']['QONFIG_STRING'] # => 'none'
config.settings['qonfig']['QONFIG_ARRAY'] # => [1, 2.5, true, false, 'TEST']
config.settings['qonfig']['QONFIG_MESSAGE'] # => 'Hello, Qonfig!'
config.settings['qonfig']['RUN_CI'] # => Qonfig::UnknownSettingError

# 去前缀 (且自定义)
config.settings['trimmed']['BOOLEAN'] # => true ('true' => true)
config.settings['trimmed']['INTEGER'] # => 0 ('0' => 0)
config.settings['trimmed']['STRING'] # => 'none'
config.settings['trimmed']['ARRAY'] # => [1, 2.5, true, false, 'TEST']
config.settings['trimmed']['MESSAGE'] # => 'Hello, Qonfig!'
config.settings['trimmed']['RUN_CI'] # => Qonfig::UnknownSettingError

# 默认
config.settings['QONFIG_BOOLEAN'] # => 'true'
config.settings['QONFIG_INTEGER'] # => '0'
config.settings['QONFIG_STRING'] # => 'none'
config.settings['QONFIG_ARRAY'] # => '1, 2.5, t, f, TEST'
config.settings['QONFIG_MESSAGE'] # => '"Hello, Qonfig!"'
config.settings['RUN_CI'] # => '1'
```

---

### 从 \_\_END\_\_ 加载

- 别名为 `load_from_self`
- `:format` - 指定放置在 `__END__` 指令下的数据格式：
  - `format: :dynamic` (默认) - 自动解析格式；
  - `format: :yaml` - **YAML** 格式；
  - `format: :json` - **JSON** 格式；
  - `format: :toml` - **TOML** 格式 (通过 `toml` 插件)；
- `:replace_on_merge` - 发生键冲突时是否应被替换，否则将进行深度合并 (默认行为)；

```ruby
class Config < Qonfig::DataSet
  load_from_self # 在根部 (默认使用 :dynamic 格式)

  setting :nested do
    load_from_self, format: :yaml # 显式指定 YAML 格式
  end
end

config = Config.new

# 在根部
config.settings.ruby_version # => '2.5.1'
config.settings.secret_key # => 'top-mega-secret'
config.settings.api_host # => 'super.puper-google.com'
config.settings.connection_timeout.seconds # => 10
config.settings.connection_timeout.enabled # => false

# 嵌套
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

### 公开 \_\_END\_\_

- 别名为 `expose_self`；
- 工作方式与 `expose_json` 和 `expose_yaml` 相同，但使用当前文件的 `__END__` 指令；
- `env:` - 你的环境名称 (必须是 `String`, `Symbol` 或 `Numeric` 类型)；
- `:format` - 指定放置在 `__END__` 指令下的数据格式：
  - `format: :dynamic` (默认) - 自动解析格式；
  - `format: :yaml` - **YAML** 格式；
  - `format: :json` - **JSON** 格式；
  - `format: :toml` - **TOML** 格式 (通过 `toml` 插件)；
- `:replace_on_merge` - 发生键冲突时是否应被替换，否则将进行深度合并 (默认行为)；

```ruby
class Config < Qonfig::DataSet
  expose_self env: :production, format: :yaml # 显式指定 YAML 格式

  # 注意：对于类 Rails 应用程序，你可以使用：
  expose_self env: Rails.env
end

config = Config.new

config.settings.log # => true (来自 :production 环境)
config.settings.api_enabled # => true (来自 :production 环境)
config.settings.creds.user # => "D@iVeR" (来自 :production 环境)
config.settings.creds.password # => "test123" (来自 :production 环境)

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

### 默认设置值文件

- 定义一个用于配置对象设置值初始化的文件；
- `.values_file(file_path, format: :dynamic, strict: false, expose: nil)`
  - `file_path` - 完整文件路径或 `:self` (`:self` 表示“从 __END__ 数据加载设置值”)；
  - `:format` - 定义文件格式 (`:dynamic` 表示“尝试自动推断文件格式”) (默认 `:dynamic`)；
    - 支持 `:yaml`, `:json`, `:toml` (通过 `Qonfig.plugin(:toml)`), `:dynamic` (自动格式检测)；
  - `:strict` - 要求文件 (或 __END__ 数据) 必须存在 (默认 `false`)；
  - `:expose` - 应使用哪个基于环境的键子集 (`nil` 表示“不使用任何键子集”) (默认 `nil`)；
- 配置中不存在的额外键将分别导致 `Qonfig::SettingNotFound` 异常；
- 初始值将被文件中定义的值覆盖；

#### 默认行为

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

config.settings.adapter # => "sidekiq" (来自 sidekiq.yml)
config.settings.options.processes # => 10 (来自 sidekiq.yml)
config.settings.options.threads # => 5 (原始值)
config.settings.options.protected # => false (原始值)
```

#### 从 \_\_END\_\_-数据加载值

```ruby
class Config < Qonfig::DataSet
  values_file :self, format: :yaml

  setting :user
  setting :password
  setting :enabled, true
end

config = Config.new

config.settings.user # => "D@iVeR" (来自 __END__ 数据)
config.settings.password # => "test123" (来自 __END__ 数据)
config.settings.enabled # => true (原始值)

__END__

user: 'D@iVeR'
password: 'test123'
```

#### 带有环境分离的设置值

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

config.settings.adapter # => 'in_memory' (development 键子集)
config.settings.options.threads # => 10 (development 键子集)
```

#### 文件不存在

```ruby
# 非严格行为 (默认)
class Config < Qonfig::DataSet
  values_file 'sidekiq.yml'
end

config = Config.new # 无错误

# 严格行为 (strict: true)
class Config < Qonfig::DataSet
  values_file 'sidekiq.yml', strict: true
end

config = Config.new # => Qonfig::FileNotFoundError
```

---

### 从 YAML 文件加载设置值 (通过实例)

- 提供从 yaml 文件加载预定义设置值的能力；
- `#load_from_yaml(file_path, strict: true, expose: nil, &configurations)`
  - `file_path` - 完整文件路径或 `:self` (`:self` 表示“从 __END__ 数据加载设置值”)；
  - `:strict` - 要求文件 (或 __END__ 数据) 必须存在 (默认 `true`)；
  - `:expose` - 应使用哪个基于环境的键子集 (`nil` 表示“不使用任何键子子集”) (默认 `nil`)；
  - `&configurations` - `do |config|` 能力 :)

#### 默认行为

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

# 加载新值
config.load_from_yaml('config.yml')

config.settings.domain # => "google.ru" (来自 config.yml)
config.settings.creds.auth_token # => "test123" (来自 config.yml)
```

#### 从 \_\_END\_\_ 加载

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

# 加载新值
config.load_from_yaml(:self)
config.settings.domain # => "yandex.ru" (来自 __END__ 数据)
config.settings.creds.auth_token # => "CK0sIdA" (来自 __END__ 数据)

__END__

domain: yandex.ru
creds:
  auth_token: CK0sIdA
```

#### 带有环境分离的设置值

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

# 加载新值 (公开 development 设置)
config.load_from_yaml('config.yml', expose: :development)

config.settings.domain # => "dev.google.ru" (来自 config.yml)
config.settings.creds.auth_token # => "kek.pek" (来自 config.yml)
```

---

### 从 JSON 文件加载设置值 (通过实例)

- 提供从 json 文件加载预定义设置值的能力；
- `#load_from_json(file_path, strict: true, expose: nil, &configurations)`
  - `file_path` - 完整文件路径或 `:self` (`:self` 表示“从 __END__ 数据加载设置值”)；
  - `:strict` - 要求文件 (或 __END__ 数据) 必须存在 (默认 `true`)；
  - `:expose` - 应使用哪个基于环境的键子集 (`nil` 表示“不使用任何键子集”) (默认 `nil`)；
  - `&configurations` - `do |config|` 能力 :)

#### 默认行为

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

# 加载新值
config.load_from_json('config.json')

config.settings.domain # => "google.ru" (来自 config.json)
config.settings.creds.auth_token # => "test123" (来自 config.json)
```

#### 从 \_\_END\_\_ 加载

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

# 加载新值
config.load_from_json(:self)
config.settings.domain # => "yandex.ru" (来自 __END__ 数据)
config.settings.creds.auth_token # => "CK0sIdA" (来自 __END__ 数据)

__END__

{
  "domain": "yandex.ru",
  "creds": {
    "auth_token": "CK0sIdA"
  }
}
```

#### 带有环境分离的设置值

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

# 加载新值 (来自 development 子集)
config.load_from_json('config.json', expose: :development)

config.settings.domain # => "dev.google.ru" (来自 config.json)
config.settings.creds.auth_token # => "kek.pek" (来自 config.json)
```
---

### 从 \_\_END\_\_ 加载设置值 (通过实例)

- 提供从 `__END__` 文件部分加载预定义设置值的能力；
- `#load_from_self(strict: true, expose: nil, &configurations)`
  - `:format` - 定义文件的格式 (`:dynamic` 表示“尝试自动推断文件格式”) (默认 `:dynamic`)；
    - 支持 `:yaml`, `:json`, `:toml` (通过 `Qonfig.plugin(:toml)`), `:dynamic` (自动格式检测)；
  - `:strict` - 要求 __END__ 数据必须存在 (默认 `true`)；
  - `:expose` - 应使用哪个基于环境的键子集 (`nil` 表示“不使用任何键子集”) (默认 `nil`)；
  - `&configurations` - `do |config|` 能力 :)

#### 默认行为

```ruby
class Config < Qonfig::DataSet
  setting :account, 'test'
  setting :options do
    setting :login, '0exp'
    setting :password, 'test123'
  end
end

config = Config.new
config.settings.account # => "test" (原始值)
config.settings.options.login # => "0exp" (原始值)
config.settings.options.password # => "test123" (原始值)

# 加载新值
config.load_from_self(format: :yaml)
# 或 config.load_from_self

config.settings.account # => "real" (来自 __END__ 数据)
config.settings.options.login # => "D@iVeR" (来自 __END__ 数据)
config.settings.options.password # => "azaza123" (来自 __END__ 数据)

__END__

account: real
options:
  login: D@iVeR
  password: azaza123
```

#### 带有环境分离的设置值

```ruby
class Config < Qonfig::DataSet
  setting :domain, 'test.google.ru'
  setting :options do
    setting :login, 'test'
    setting :password, 'test123'
  end
end

config = Config.new
config.settings.domain # => "test.google.ru" (原始值)
config.settings.options.login # => "test" (原始值)
config.settings.options.password # => "test123" (原始值)

# 加载新值
config.load_from_self(format: :json, expose: :production)
# 或 config.load_from_self(expose: production)

config.settings.domain # => "prod.google.ru" (来自 __END__ 数据)
config.settings.options.login # => "prod" (来自 __END__ 数据)
config.settings.options.password # => "prod123" (来自 __END__ 数据)

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

### 手动从文件加载设置值 (通过实例)

- 提供从文件加载预定义设置值的能力；
- 工作方式与基于实例的 `#load_from_yaml` / `#load_from_json` / `#load_from_self` 相同；
- 签名：`#load_from_file(file_path, format: :dynamic, strict: true, expose: nil, &configurations)`:
  - `file_path` - 完整文件路径或 `:self` (`:self` 表示“从 __END__ 数据加载设置值”)；
  - `:format` - 定义文件格式 (`:dynamic` 表示“尝试自动推断文件格式”) (默认 `:dynamic`)；
    - 支持 `:yaml`, `:json`, `:toml` (通过 `Qonfig.plugin(:toml)`), `:dynamic` (自动格式检测)；
  - `:strict` - 要求文件 (或 __END__ 数据) 必须存在 (默认 `true`)；
  - `:expose` - 应使用哪个基于环境的键子集 (`nil` 表示“不使用任何键子集”) (默认 `nil`)；
  - `&configurations` - `do |config|` 能力 :)
- 详见基于实例的 `#load_from_yaml` ([文档](#load-setting-values-from-yaml-by-instance)) / `#load_from_json` ([文档](#load-setting-values-from-json-by-instance)) / `#load_from_self` ([文档](#load-setting-values-from-__end__-by-instance)) 的示例；

---

### 保存到 JSON 文件

- `#save_to_json` - 将配置对象表示为 json 结构并保存到文件：
  - 底层使用原生 `::JSON.generate`；
  - 写入新文件 (或覆盖现有文件)；
  - 属性：
    - `:path` - (必需) - 文件路径；
    - `:options` - (可选) - 原生 `::JSON.generate` 选项 (来自标准库)：
      - `:indent` - 默认为 `" "`；
      - `:space` - 默认为 `" "`；
      - `:object_nl` - 默认为 `"\n"`；
    - `&value_preprocessor` - (可选) - 值预处理器；

#### 无值预处理 (标准用法)

```ruby
class AppConfig < Qonfig::DataSet
  setting :server do
    setting :address, 'localhost'
    setting :port, 12_345
  end

  setting :enabled, true
end

config = AppConfig.new

# 注意：保存到 json 文件
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

#### 带值预处理和自定义选项

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

# 注意：使用自定义选项保存到 json 文件 (无空格 / 无换行 / 无缩进；调用 proc)
config.save_to_json(path: 'config.json', options: { indent: '', space: '', object_nl: '' }) do |value|
  value.is_a?(Proc) ? value.call : value
end
```

```json
// 无空格 / 无换行 / 无缩进 / 计算后的 "dynamic" 设置键
{"sentry":{"address":"localhost","port":12345},"enabled":true,"dynamic":3}
```

---

### 保存到 YAML 文件

- `#save_to_yaml` - 将配置对象表示为 yaml 结构并保存到文件：
  - 底层使用原生 `::Psych.dump`；
  - 写入新文件 (或覆盖现有文件)；
  - 属性：
    - `:path` - (必需) - 文件路径；
    - `:options` - (可选) - 原生 `::Psych.dump` 选项 (来自标准库)：
      - `:indentation` - 默认为 `2`；
      - `:line_width` - 默认为 `-1`；
      - `:canonical` - 默认为 `false`；
      - `:header` - 默认为 `false`；
      - `:symbolize_keys` - (非原生选项) - 默认为 `false`；
    - `&value_preprocessor` - (可选) - 值预处理器；

#### 无值预处理 (标准用法)

```ruby
class AppConfig < Qonfig::DataSet
  setting :server do
    setting :address, 'localhost'
    setting :port, 12_345
  end

  setting :enabled, true
end

config = AppConfig.new

# 注意：保存到 yaml 文件
config.save_to_yaml(path: 'config.yml')
```

```yaml
---
server:
  address: localhost
  port: 12345
enabled: true
```

#### 带值预处理和自定义选项

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

# 注意：使用自定义选项保存到 yaml 文件 (添加 yaml 版本头；调用 proc)
config.save_to_yaml(path: 'config.yml', options: { header: true }) do |value|
  value.is_a?(Proc) ? value.call : value
end
```

```yaml
# yaml 版本头 / 计算后的 "dynamic" 设置键
%YAML 1.1
---
server:
  address: localhost
  port: 12345
enabled: true
dynamic: 10
```

---

### 插件

- [toml](#plugins-toml) (提供 `load_from_toml`, `save_to_toml`, `expose_toml`)；
- [pretty_print](#plugins-pretty_print) (美化控制台输出)；
- [vault](#plugins-vault) (提供 `load_from_vault`, `expose_vault`)

---

#### 使用方法

- 显示可用插件：

```ruby
Qonfig.plugins # => ["pretty_print", "toml", ..., ...]
```

- 加载特定插件：

```ruby
Qonfig.plugin(:pretty_print) # 或 Qonfig.plugin('pretty_print')
# -- 或 --
Qonfig.enable(:pretty_print) # 或 Qonfig.enable('pretty_print')
# -- 或 --
Qonfig.load(:pretty_print) # 或 Qonfig.load('pretty_print')
```

- 显示已加载插件：

```ruby
Qonfig.loaded_plugins # => ["pretty_print"]
# -- 或 --
Qonfig.enabled_plugins # => ["pretty_print"]
```

---

### 插件: toml

- `Qonfig.plugin(:toml)`
- 添加对 `toml` 格式的支持 ([规范](https://github.com/toml-lang/toml))；
- 依赖于 `toml-rb` gem ([链接](https://github.com/emancu/toml-rb)) (已在 `>= 2.0` 版本上测试)；
- 支持 TOML `0.5.0` 格式 (依赖锁定) (`toml-rb >= 2.0`)；
- 提供 `.load_from_toml` (工作方式与 `.load_from_yaml` 相同 ([文档](#load-from-yaml-file)))；
- 提供 `.expose_toml` (工作方式与 `.expose_yaml` 相同 ([文档](#expose-yaml)))；
- 提供 `#save_to_toml` (工作方式与 `#save_to_yaml` 相同 ([文档](#save-to-yaml-file))) (`toml-rb` 没有原生选项)；
- 为 `.values_file` 提供 `format: :toml` ([文档]());
- 提供 `#load_from_toml` (工作方式与 `#load_from_yaml` 相同 ([文档](#load-setting-values-from-yaml)))；

```ruby
# 1) 引入外部依赖
require 'toml-rb'

# 2) 启用插件
Qonfig.plugin(:toml)

# 3) 使用 toml :)
```

---

### 插件: pretty_print

- `Qonfig.plugin(:pretty_print)`
- 为你提供非常舒适且美观的控制台输出；
- 所有设置键均以点号表示法格式显示；

#### 示例：

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

- 之前：

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
# ... 等等
```

- 之后：

```shell
=> #<Config:0x00007f9b6c01dab0
 api.domain: "google.ru",
 api.creds.account: "D@iVeR",
 api.creds.password: "test123",
 log_requests: true,
 use_proxy: true>

# -- 或 --

=> #<Config:0x00007f9b6c01dab0 api.domain: "google.ru", api.creds.account: "D@iVeR", api.creds.password: "test123", log_requests: true, use_proxy: true>
```

---

### 插件: vault

- `Qonfig.plugin(:vault)`
- 添加对 `vault kv store` 的支持，[更多信息](https://www.vaultproject.io/docs/secrets/kv/kv-v2)
- 依赖于 `vault` gem ([链接](https://github.com/hashicorp/vault-ruby)) (已在 `>= 0.1` 版本上测试)；
- 提供 `.load_from_vault` (工作方式与 `.load_from_yaml` 相同 ([文档](#load-from-yaml-file)))；
- 提供 `.expose_vault` (工作方式与 `.expose_yaml` 相同 ([文档](#expose-yaml)))；

```ruby
# 1) 引入外部依赖
require 'vault'

# 2) 设置 vault 客户端

Vault.address = 'http://localhost:8200'
Vault.token = 'super-duper-token-here'

# 3) 启用插件
Qonfig.plugin(:vault)

# 4) 使用 vault :)
```

---

## 路线图

- **主要 (Major)**:
  - `on_change` 钩子 (为了提供诸如“在每次 redis 配置更改时重新初始化 redis 连接池”等可能性)；
  - 运行时配置 (带有内存缓存)；
  - 支持类似 Rails 的 secrets；
  - 支持持久化数据存储 (希望将配置存储在多个数据库和文件中)；
  - rails 插件；
  - 支持模式匹配；
  - 支持类型检查 (通过 `rbs`, `typeprof`, `steep`)；
  - 控制台实用工具；
- **次要 (Minor)**:
  - 能够将 `Qonfig::Configurable` 的配置对象标记为 `compacted` (`Qonfig::Compacted`)；
  - `Vault` 插件的基于实例的行为，同时使用 `Vault` 客户端实例而不是 `Singleton`；
  - 带有导入 API 的外部验证类，以便更好地进行自定义验证；
  - 设置值更改追踪 (类似于 `anyway_config` 的方式)；
  - 实例化和重载回调；
  - 文件生成器 (预填代码的 .rb 文件 (以及 (可能) 预生成的 yaml/json/etc 文件))；
  - 设置值更改订阅和回调；
  - CI 重构 (新配置, 新步骤, 无奇怪依赖)；
  - CI: 为 `thruffleruby` 编写线程安全规格测试；

## 构建

```shell
bin/rspec -w # 测试核心功能和插件
bin/rspec -n # 仅测试核心功能
```

## 贡献

- Fork 它 ( https://github.com/0exp/qonfig/fork )
- 创建你的特性分支 (`git checkout -b feature/my-new-feature`)
- 提交你的更改 (`git commit -am '[my-new-featre] Add some feature'`)
- 推送到分支 (`git push origin feature/my-new-feature`)
- 创建新的 Pull Request

## 许可证

基于 MIT 许可证发布。

## 作者

[Rustam Ibragimov](https://github.com/0exp)
