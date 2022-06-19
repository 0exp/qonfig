# Changelog
All notable changes to this project will be documented in this file.

## [0.28.0]
### Changed
- Support for the new `toml-rb` release (`2.1`);
- Updated dev-dependencies;
- Adopt the code to the new rubocop cops;

## [0.27.0] - 2022-01-12
### Changed
- Drop Ruby 2.5 support.
- Fix YAML loading in Psych v4 (#132).

## [0.26.0] - 2021-07-01
### Added
- Support `ERB` in `load_from_json` method;

## [0.25.0] - 2020-09-15
### Added
- Support for **Vault** config provider:
  - realized as a plugin (`Qonfig.plugin(:vault)`);
  - provides `#load_from_vault`, `#expose_vault` methods and works in `#*_yaml`-like manner);
  - depends on `gem vault (>= 0.1)`
- `Qonfig::Settings#[]` behave like `Qonfig::Settings#__dig__`;
- An ability to represent the config hash in dot-notated style (all config keys are represented in dot-notated format):
  - works via `#to_h(dot_style: true)`;
  - `key_transformer:` and `value_transfomer:` options are supported too;

```ruby
class Config << Qonfig::DataSet
  setting :database do
    setting :host, 'localhost'
    setting :port, 6432
  end

  setting :api do
    setting :rest_enabled, true
    setting :rpc_enabled, false
  end
end

Config.new.to_h(dot_style: true)
# =>
{
  'database.host' => 'localhost',
  'database.port' => 6432,
  'api.rest_enabled' => true,
  'api.rpc_enabled' => false,
}
```

## [0.24.1] - 2020-03-10
### Changed
- Enhanced dot-notated key resolving algorithm: now it goes through the all dot-notated key parts
  until it finds the required setting key (or fails with `Qonfig::UnknowSettingKeyError`);

### Fixed
- (**Pretty-Print Plugin**):
  - dot-noted setting keys can not be pretty-printed (they raise `Qonfig::UnknownSettingKeyError`);
  - added `set` and `pp` as preloaded dependencies;

## [0.24.0] - 2019-12-29
### Added
- Support for **Ruby@2.7**;

## [0.23.0] - 2019-12-12
### Added
- Support for `Pathname` file path in `.load_from_json`, `.load_from_yaml`, `.load_from_toml`, `.expose_yaml`, `.expose_json`, `.expose_toml`;

## [0.22.0] - 2019-12-12
### Added
- Support for `Pathname` file path in `.values_file`, `#load_from_file`, `#load_from_yaml`, `#load_from_json` and `#load_from_toml`;

## [0.21.0] - 2019-12-12
### Added
- Brand new type of config objects `Qonfig::Compacted`:
  - represents the compacted config object with setting readers and setting writers only;
  - setting keys are represented as direct instace methods (`#settings` invokation does not need);
  - no any other useful instance-based functionality;
  - full support of `Qonfig::DataSet` DSL commands (`.setting`, `.validate`, `.add_validator`, `.load_from_x`/`.expose_x` and etc);
  - can be instantiated by:
    - by existing config object: `Qonfig::DataSet#compacted` or `Qonfig::Compacted.build_from(config, &configuration)`
    - by direct instantiation: `Qonfig::Compacted.new(settings_values = {}, &configuration)`;
    - by implicit instance building without explicit class definition `Qonfig::Compacted.build(&dsl_commands) # => instance of Qonfig::Compacted`;
- Added `Qonfig::DataSet.build_compacted` method: works in `Qonfig::DataSet.build` manner but returns compacted config object (`Qonfig::Compacted`);
- Added missing `#[]=(key, value)` accessor-method for `Qonfig::DataSet` objects;
- Added support for `do |config|` configuration block in `#load_from_self` / `#load_from_yaml` / `#load_from_json` / `#load_from_toml`
  values-loading methods;
- **Plugins** `pretty_print`:
  - added missing beautification logic for `Qonfig::Settings` objects;
  - added support for `Qonfig::Compacted` beautification;
- `#valid_with?` now supports configuration block (`do |config|`);
- `Import API`: support for predicate methods;

### Changed
- `.load_from_self`: default format was changed from `:yaml` to `:dynamic`;
- `.expose_self`: default format was changed from `:yaml` to `:dynamic`;
- Minor `Qonfig::DataSet` and `Qonfig::Settings::Builder` refactorings;

### Fixed
- Configs without any setting key can not be imported and exported by generic key patterns (`*` and `#`);

## [0.20.0] - 2019-12-01
### Added
- Extended **Validation API**: you can define your own predefined validators via `.define_validator(name, &validation)` directive;
- `re_setting` - a special DSL command method that fully redefines existing settings (redefines existing settings instead of reopening them);

## [0.19.1] - 2019-11-29
### Changed
- Support for Ruby 2.3 has ended.

### Fixed
- Invalid default values for `#export_settings` method attributes (invalid `mappings:` value);

## [0.19.0] - 2019-11-26
### Added
- **FINALY**: support for dot-notation in `#key?`, `#option?`, `#setting?`, `#dig`, `#subset`, `#slice`, `#slice_value`, `[]`;
- `freeze_state!` DSL directive (all your configs becomes frozen after being instantiated immediately);
- Global `Qonfig::FrozenError` error for `frozen`-based exceptions;
- explicit validation of potential setting values:
  - `#valid_with?(configurations = {})` - check that current config instalce will be valid with passed configurations;
  - `.valid_with?(configurations = {})` - check that potential config instancess will be valid with passed configurations;
- `#pretty_print` plugin :) (`Qonfig.plugin(:pretty_print)`);
- `Qonfig.loaded_plugins`/`Qonfig.enabled_plugins` - show loaded plugins;

### Changed
- `Qonfig::FrozenSettingsError` now inherits `Qonfig::FrozenError` type;

## [0.18.1] - 2019-11-05
### Added
- New `yield_all:` attribute for `#deep_each_setting` method (`#deep_each_setting(yield_all: false, &block)`))
  - `yield_all:` means "yield all config objects" (end values and root setting objects those have nested settings) (`false` by default)

### Fixed
- `#keys(all_variants: true)` returns incorrect set of keys when some of keys has name in dot-notated format;

## [0.18.0] - 2019-11-04
### Added
- `#keys` - returns a list of all config keys in dot-notation format;
- `#root_keys` - returns a list of root config keys;
- Inroduce `Import API`:
  - `.import_settings` - DSL method for importing configuration settings (from a config instance) as instance methods of a class;
  - `#export_settings` - config's instance method that exports config settings to an arbitrary object as singelton methods;

## [0.17.0] - 2019-10-30
### Added
- Introduce `strict` validations: `strict: false` option ignores `nil` values and used by default;
- Setting's key existence check methods: `#key?(*key_path)`, `#setting?(*key_path)`, `#option?(*key_path)`;
- `#with(temporary_configurations = {}, &arbitary_code)` - run arbitary code with temporary settings;
- `TOML` plugin: support for TOML version 0.5.0;
- Introduce instance-level file loading methods that specifies a file with setting values for your defined settings:
  - `.values_file` - define a file that will be used during instantiation process;
  - `#load_from_file`, `#load_from_self`, `#load_from_yaml`, `#load_from_json`, `#load_from_toml` (toml plugin) -
    instance methods for loading setting values on your config instance directly from a file;

### Changed
- `Qonfig::DataSet.build` now supports a Qonfig::DataSet-class attribute that should be inherited (`self` is used by default):
  - new signature: `Qonfig::DataSet.build(base_config_klass = self, &config_class_definitions)`;
- Refacored DSL commands: introduce `Qonfig::Commands::Definition` commands and `Qonfig::Commands::Instantiation` commands;
- Updated runtime (`toml-rb` `1` -> `2`) and development dependencies;

## [0.16.0] - 2019-09-13
### Added
- `Qonfig::DataSet.build(&config_klass_definitions)` - build config instance immidietly without `Qonfig::DataSet`-class definition;
- `#subset` - get a subset of config settings represented as a hash;

## [0.15.0] - 2019-09-02
### Added
- `:format`-option for `load_from_self` and `expose_self` commands that identifies which data format
  should be chosen for parsing;

## [0.14.0] - 2019-08-28
### Added
- `expose_json`
  - a command that provides an ability to define config settings by loading them from a json file
    where the concrete settings depends on the chosen environment;
  - works in `expose_yaml` manner;
- `expose_self`
  - a command that provides an ability to define config settings by loading them from the current file
    where `__END__` instruction is defined (concrete settings dependes on the chosen environment);
  - works with `YAML` format;

### Changed
- `Qonfig::Settings::Callbacks` is thread safe now;
- Minor refactorings;

## [0.13.0] - 2019-08-13
### Added
- Iteration over setting keys (`#each_setting { |key, value| }`, `#deep_each_setting { |key, value| }`);
- Brand new `Validation API`;

### Changed
- Actualized development dependencies;

## [0.12.0] - 2019-07-19
### Added
- Support for **TOML** (`.toml`) format
  - realized as a plugin (`Qonfig.plugin(:toml)`);
  - provides `#save_to_toml`, `#load_from_toml`, `#expose_toml` methods and works in `#*_yaml`-like manner);
  - depends on `gem toml-rb (>= 1)`
- Custom `bin/rspec` command:
  - `bin/rspec -n` - run tests without plugin tests;
  - `bin/rspec -w` - run all tests;
- Added more convinient aliases for `Qonfig::DataSet` instances:
  - `#save_to_yaml` => `#dump_to_yaml`;
  - `#save_to_json` => `#dump_to_json`;
  - `#save_to_toml` => `#dump_to_toml`;
### Changed
- Actualized development dependencies;

## [0.11.0] - 2019-05-15
### Added
- `#save_to_json` - save configurations to a json file (uses native `::JSON.generate` under the hood);
- `#save_to_yaml` - save configurations to a yaml file (uses native `::Psych.dump` under the hood);

### Changed
- new `#to_h` signature: `#to_h(key_transformer:, value_transformer:)`
  - `:key_transformer` - proc object used for key pre-processing (`-> (key) { key }` by default);
  - `:value_transformer` - proc object used for value pre-processing (`-> (value) { value }` by default);

## [0.10.0] - 2019-02-26
### Added
- `#slice_value` - get a slice of config options as a hash set and fetch the required value using the given key set;

## [0.9.0] - 2018-11-28
### Added
- `#slice` - get a slice of config options as a hash set (works in a `#dig` manner);

## [0.8.0] - 2018-11-21
### Changed
- `expose_yaml`, `load_from_yaml`, `load_from_json` and `load_from_self` treats empty hash (`{}`)
  as an option with empty hash value (previously treated as a nested setting without options);

## [0.7.0] - 2018-10-20
### Added
- `expose_yaml` - a command that provides an ability to define config settings
  by loading them from a yaml file where the concrete settings depends on the chosen environment;

## [0.6.0] - 2018-08-22
### Added
- `#shared_config` - instance method that provides an access to the class level config
  object from `Qonfig::Configurable` instances;

## [0.5.0] - 2018-07-27
### Added
- `load_from_json`- a command that provides an ability to define config settings
  by loading them from a json file (in `load_from_yaml` manner);

### Changed
- Support for Ruby 2.2 has ended;

## [0.4.0] - 2018-06-24
### Added
- Introduce Plugin Ecosystem (`Qonfig::Plugins`):
  - load plugin: `Qonfig.plugin('plugin_name')` or `Qonfig.plugin(:plugin_name)`;
  - get registered plugins: `Qonfig.plugins #=> array of strings`

## [0.3.0] - 2018-06-13
### Added
- Improved configuration process: `#configure` can take a hash as a configuration `[option key => option]`
  map of values;

### Changed
- `#clear!` causes `Qonfig::FrozenSettingsError` if config object is frozen;

## [0.2.0] - 2018-06-07
### Added
- Instant configuration via block `config = Config.new { |conf| <<your configuration code>> }`;
- `.load_from_env` command - an ability to define config settings by loading them from ENV variable;
- `.load_from_yaml` command - an ability to define config settings by loading them from a yaml file;
- `.load_from_self` command - an ability to load config definitions form the YAML
  instructions written in the file where the config class is defined (`__END__` section);
- `#reload!` - an ability to reload config isntance after any config class changes and updates;
- `#clear!` - an ability to set all options to `nil`;
- `#dig` - an ability to fetch setting values in `Hash#dig` manner
  (fails with `Qonfig::UnknownSettingError` when the required key does not exist);
- Settings as Predicates - an ability to check the boolean nature of the config setting by appending
  the question mark symbol (`?`) at the end of setting name:
  - `nil` and `false` setting values indicates `false`;
  - other setting values indicates `true`;
  - setting roots always returns `true`;
  - examples:
    - `config.settings.database.user # => nil`;
    - `config.settings.database.user? # => false`;
    - `config.settings.database.host # => 'google.com'`;
    - `config.settings.database.host? # => true`;
    - `config.settings.database? # => true (setting with nested option (setting root))`
- Support for ERB instructions in YAML;
- Support for `HashWithIndifferentAccess`-like behaviour;
- `Qonfig::Settings` instance method redefinition protection: the setting key can not
  have a name that matches an any instance method name of `Qonfig::Settings`;
- Added `Qonfig::Configurable` mixin - configuration behaviour for any classes and modules
  and their instances:
  - all `Qonfig`-related features;
  - different class-level and instance-level config objects;
  - working class-level inheritance :);
- Full thread-safe implementation;

### Changed
- Superclass of `Qonfig::FrozenSettingsError` (it was `Qonfig::Error` before):
  - `ruby >= 2.5` - inherited from `::FrozenError`;
  - `ruby < 2.5` - inherited from `::RuntimeError`;
- `.setting` will raise exceptions immediately:
  - `.setting(key, ...) { ... }` - if setting key has incompatible type;
  - `.compose(config_class)`- if composed config class is not a subtype of `Qonfig::DataSet`;

### Fixed
- Recoursive hash representation with deep nested `Qonfig::Settings` values (infinite loop);
- Fixed re-assignment of the options with nested options (losing the nested options
  due to the instance configuration). Now it causes `Qonfig::AmbigousSettingValueError`.

## [0.1.0] - 2018-05-18
- Release :)
