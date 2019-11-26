# frozen_string_literal: true

# @api private
# @since 0.4.0
class Qonfig::Plugins::Abstract
  class << self
    # @param child_klass [Class]
    # @return [void]
    #
    # @api private
    # @since 0.19.0
    def inherited(child_klass)
      child_klass.instance_variable_set(:@loaded, false)
      super
    end

    # @return [void]
    #
    # @api private
    # @since 0.4.0
    def load!
      @loaded = true
      install!
    end

    # @return [Boolean]
    #
    # @api private
    # @since 0.19.0
    def loaded?
      @loaded
    end

    private

    # @return [void]
    #
    # @api private
    # @since 0.19.0
    def install!; end
  end
end
