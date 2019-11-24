# frozen_string_literal: true

# @api private
# @since 0.19.0
module Qonfig::Plugins::PrettyPrint::Mixin
  # @param pp [Pry::ColorPrinter] In some cases this is a Pry::ControlPrinter ¯\_(ツ)_/¯
  # @return [void]
  #
  # @api public
  # @since 0.19.0
  def pretty_print(pp)
    if method(:inspect).owner != Qonfig::DataSet.instance_method(:inspect).owner
      super
    else
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
end
