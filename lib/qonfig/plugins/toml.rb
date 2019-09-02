# frozen_string_literal: true

# @api private
# @since 0.12.0
class Qonfig::Plugins::TOML < Qonfig::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.12.0
    def load!
      raise(
        Qonfig::UnresolvedPluginDependencyError,
        '::TomlRB does not exist or "toml-rb" gem is not loaded'
      ) unless const_defined?('::TomlRB')

      require_relative 'toml/tomlrb_fixes'
      require_relative 'toml/loaders'
      require_relative 'toml/loaders/toml'
      require_relative 'toml/uploaders/toml'
      require_relative 'toml/commands/load_from_toml'
      require_relative 'toml/commands/expose_toml'
      require_relative 'toml/data_set'
      require_relative 'toml/dsl'
    end
  end
end
