# frozen_string_literal: true

# @api private
# @since 0.12.0
class Qonfig::Plugins::TOMLFormat < Qonfig::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.12.0
    def load!
      raise(
        Qonfig::UnresolvedPuginDependencyError,
        '::TomlRB does not exist or not loeaded (gem "toml-rb")'
      ) unless const_defined?('::TomlRB')

      require_relative 'toml_format/tomlrb_fixes'
      require_relative 'toml_format/loaders/toml'
      require_relative 'toml_format/uploaders/toml'
      require_relative 'toml_format/commands/load_from_toml'
      require_relative 'toml_format/commands/expose_toml'
      require_relative 'toml_format/data_set'
      require_relative 'toml_format/dsl'
    end
  end
end
