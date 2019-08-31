# frozen_string_literal: true

# @api private
# @since 0.15.0
module Qonfig::Loaders::EndData
  class << self
    # @param caller_location [String]
    # @return [String]
    #
    # @raise [Qonfig::SelfDataNotFoundError]
    #
    # @api private
    # @since 0.15.0
    def extract(caller_location)
      caller_file = caller_location.split(':').first

      raise(
        Qonfig::SelfDataNotFoundError,
        "Caller file does not exist! (location: #{caller_location})"
      ) unless File.exist?(caller_file)

      data_match = IO.read(caller_file).match(/\n__END__\n(?<end_data>.*)/m)
      raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless data_match

      end_data = data_match[:end_data]
      raise Qonfig::SelfDataNotFoundError, '__END__ data not found!' unless end_data

      end_data
    end
  end
end
