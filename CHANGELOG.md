# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]
### Added
- Instant configuration via block `config = Config.new { |conf| <<your configuration code>> }`;
- `.load_from_yaml` command - an ability to define config settings by loading them from a yaml file;
- `.load_from_self` command - an ability to load config definitions form the YAML
  instructions written in the file where your config class is defined;
- `#reload!` - an ability to reload config isntance after any config class changes and updates;

### Fixed
- Recoursive hash representation with deep nested `Qonfig::Settings` values (does not work);

## [0.1.0] - 2018-05-18
- Release :)
