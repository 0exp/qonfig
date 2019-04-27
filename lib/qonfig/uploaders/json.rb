# frozen_string_literal: true

# @api private
# @since 0.11.0
class Qonfig::Uploaders::JSON < Qonfig::Uploaders::File
  class << self
    # @param data_set [Qonfig::DataSet]
    # @return [String]
    #
    # @api private
    # @since 0.11.0
    def represent_settings(data_set)
      settings_hash = data_set.to_h(process_procs: true)
      ::JSON.generate(settings_hash)
    end
  end
end
