# frozen_string_literal: true

# @api public
# @since 0.24.0
module PP::PPMethods
  def pp(obj)
    # If obj is a Delegator then use the object being delegated to for cycle
    # detection

    # NOTE: --- PATCH ---
    if defined?(::Delegator) and (
      begin
        (class << obj; self; end) <= ::Delegator
      rescue TypeError
        obj.is_a?(::Delegator)
      end
    )
      obj = obj.__getobj__
    end # instead of: obj = obj.__getobj__ if defined?(::Delegator) and obj.is_a?(::Delegator)
    # NOTE: --- PATCH ---

    if check_inspect_key(obj)
      group {obj.pretty_print_cycle self}
      return
    end

    begin
      push_inspect_key(obj)
      group {obj.pretty_print self}
    ensure
      pop_inspect_key(obj) unless PP.sharing_detection
    end
  end
end
