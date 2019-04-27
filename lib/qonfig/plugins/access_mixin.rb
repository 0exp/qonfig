# frozen_string_literal: true

# @api private
# @since 0.4.0
module Qonfig::Plugins::AccessMixin
  # @param plugin_name [Symbol, String]
  # @return [void]
  #
  # @see Qonfig::Plugins
  #
  # @api public
  # @since 0.4.0
  def plugin(plugin_name)
    Qonfig::Plugins.load(plugin_name)
  end

  # @return [Array<String>]
  #
  # @see Qonfig::Plugins
  #
  # @api public
  # @since 0.4.0
  def plugins
    Qonfig::Plugins.names
  end
end
