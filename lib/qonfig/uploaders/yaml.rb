# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::YAML < Qonfig::Uploaders::File
  class << self
    # @param settings [Qonfig::Settings]
    # @param options [Hash<Symbol,Any>]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(settings, call_procs:, **options)
      settings_hash = settings.__to_hash__(call_procs: call_procs)
      ::YAML.dump(settings_hash, **options)
    end
  end
end
