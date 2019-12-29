# frozen_string_literal: true

# @api private
# @since 0.19.0
class Qonfig::Plugins::PrettyPrint < Qonfig::Plugins::Abstract
  class << self
    # @return [void]
    #
    # @api private
    # @since 0.19.0
    # @version 0.24.0
    def install!
      # :nocov:
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7.0')
        require_relative 'pretty_print/ruby_2_7_basic_object_pp_patch'
      end
      # :nocov:

      require_relative 'pretty_print/mixin'
      require_relative 'pretty_print/data_set'
      require_relative 'pretty_print/settings'
      require_relative 'pretty_print/compacted'
    end
  end
end
