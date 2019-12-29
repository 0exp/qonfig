# frozen_string_literal: true

# NOTE: why not `.prepend` ?
#  `prepend` in this case works incorrectly and sometimes this patch can not be correctly
#  injected to the original module and it's children ancestors (Ruby-specific behaviour of
#  module including and prepending).

# @api public
# @since 0.24.0
module PP::PPMethods
  # :nocov:
  def pp(obj)
    # If obj is a Delegator then use the object being delegated to for cycle
    # detection

    # NOTE: --- PATCH ---
    if defined?(::Delegator) and (
      begin
        (class << obj; self; end) <= ::Delegator # patch
      rescue ::TypeError
        obj.is_a?(::Delegator)
      end
    )
      obj = obj.__getobj__
    end # instead of: obj = obj.__getobj__ if defined?(::Delegator) and obj.is_a?(::Delegator)
    # NOTE:
    #  Old implementation can not be used with BasicObject instances
    #  (with Qonfig::Compacted in our case)
    # NOTE: --- PATCH ---

    if check_inspect_key(obj)
      group { obj.pretty_print_cycle self }
      return
    end

    begin
      push_inspect_key(obj)
      group { obj.pretty_print self }
    ensure
      pop_inspect_key(obj) unless PP.sharing_detection
    end
  end
  # :nocov:
end
