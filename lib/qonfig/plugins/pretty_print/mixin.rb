# frozen_string_literal: true

# @api private
# @since 0.19.0
module Qonfig::Plugins::PrettyPrint::Mixin
  # @param pp [?] Suitable for Ruby's PP module
  # @return [void]
  #
  # @api public
  # @since 0.19.0
  def pretty_print(pp)
    pp.object_address_group(self) do
      pp.seplist(keys, proc { pp.text(',') }) do |key|
        pp.breakable(' ')
        pp.group(1) do
          pp.text(key)
          pp.text(':')
          pp.breakable
          pp.pp(self[key])
        end
      end
    end
  end
end
