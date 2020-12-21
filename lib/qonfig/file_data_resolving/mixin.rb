# frozen_string_literal: true

# @api public
# @since 0.26.0
module Qonfig::FileDataResolving::Mixin
  # @param scheme_name [Symbol,String]
  # @param block [Block]
  # @return [void]
  #
  # @api public
  # @since 0.26.0
  def define_resolver(scheme_name, &block)
    Qonfig::FileDataResolving::Resolver.add_resolver!(scheme_name, block)
  end

  # @param scheme_name [Symbol,String]
  # @return [void]
  #
  # @api public
  # @since 0.26.0
  def set_default_resolver(scheme_name)
    Qonfig::FileDataResolving::Resolver.set_default_resolver!(scheme_name)
  end
end
