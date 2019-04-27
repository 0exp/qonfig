# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::YAML < Qonfig::Uploaders::File
  class << self
    # @param settings [Qonfig::Settings]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(settings)
      settings_hash = settings.__to_hash__(process_procs: true)
      ::YAML.dump(settings_hash)
    end
  end
end
