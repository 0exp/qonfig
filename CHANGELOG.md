# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Instant configuration via block `config = Config.new { |conf| <<your configuration code>> }`;
- `.load_from_yaml` command - an ability to define config settings by loading them from a yaml file;
- `.load_from_self` command - an ability to load config definitions form the YAML
  instructions written in the file where the config class is defined (`__END__` section);
- `#reload!` - an ability to reload config isntance after any config class changes and updates;
- Support for ERB instructions in YAML;
- Support for `HashWithIndifferentAccess`-like behaviour;
- Full thread-safe implementation;

### Changed
- Superclass of `Qonfig::FrozenSettingsError` (it was `Qonfig::Error` before):
  - `ruby >= 2.5` - inherited from `::FrozenError`;
  - `ruby < 2.5` - inherited from `::RuntimeError`;

### Fixed
- Recoursive hash representation with deep nested `Qonfig::Settings` values (infinite loop);
- Fixed re-assigning of options with nested options (losing the nested options
  due to the instance configuration). Now it causes `Qonfig::AmbigousSettingValueError`.

## [0.1.0] - 2018-05-18
- Release :)
