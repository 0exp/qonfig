# frozen_string_literal: true

# @api private
# @since 0.13.0
class Qonfig::Settings::KeyMatcher
  # @return [String]
  #
  # @api private
  # @since 0.13.0
  SCOPE_SPLITTER = '.'

  # @return [String]
  #
  # @api private
  # @since 0.13.0
  MATCHER_SCOPE_SPLITTER = '\.'

  # @return [String]
  #
  # @api private
  # @since 0.13.0
  GENERIC_PART_PATTERN = '*'

  # @return [String]
  #
  # @api private
  # @since 0.13.0
  GENERIC_REGEXP_PATTERN = '[^\.]+\.'

  # @return [String]
  #
  # @api private
  # @since 0.13.0
  INFINITE_PART_PATTERN = '#'

  # @return [String]
  #
  # @api private
  # @since 0.13.0
  INFINITE_REGEXP_PATTERN = '\.*.*'

  # @param scope_pattern [String]
  # @return [void]
  #
  # @raise [Qonfig::ArgumentError]
  #
  # @api private
  # @since 0.13.0
  def initialize(scope_pattern)
    raise Qonfig::ArgumentError unless scope_pattern.is_a?(String)

    @scope_pattern      = scope_pattern
    @scope_pattern_size = count_scope_pattern_size(scope_pattern)
    @pattern_matcher    = build_pattern_matcher(scope_pattern)
  end

  # @param setting_key_pattern [String]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def match?(setting_key_pattern)
    return false unless comparable_event_scopes?(setting_key_pattern)
    !!pattern_matcher.match(setting_key_pattern)
  end

  private

  # @return [Regexp]
  #
  # @api private
  # @since 0.13.0
  attr_reader :pattern_matcher

  # @return [String]
  #
  # @api private
  # @since 0.13.0
  attr_reader :scope_pattern

  # @return [Integer, Float::INFINITY]
  #
  # @api private
  # @since 0.13.0
  attr_reader :scope_pattern_size

  # @param scope_pattern [String]
  # @return [Integer, Float::INFINITY]
  #
  # @api private
  # @since 0.13.0
  def count_scope_pattern_size(scope_pattern)
    return Float::INFINITY if scope_pattern == INFINITE_PART_PATTERN
    return Float::INFINITY if scope_pattern.include?('.#')
    return Float::INFINITY if scope_pattern.include?('#.')
    return Float::INFINITY if scope_pattern.include?('.#.')

    scope_pattern.split(SCOPE_SPLITTER).size
  end

  # @param setting_key_pattern [String]
  # @return [Integer]
  #
  # @api private
  # @since 0.13.0
  def count_setting_key_pattern_size(setting_key_pattern)
    setting_key_pattern.split(SCOPE_SPLITTER).size
  end

  # @param setting_key_pattern [String]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def comparable_event_scopes?(setting_key_pattern)
    # NOTE: Integer#finite?, Integer#infinite?, Float#finite?, Float#nfinite?
    #   Cant be used (backward compatability with old ruby versions)
    return true if scope_pattern_size == Float::INFINITY
    scope_pattern_size == count_setting_key_pattern_size(setting_key_pattern)
  end

  # @param pattern [String, NilClass]
  # @return [Boolean]
  #
  # @api private
  # @since 0.13.0
  def non_generic_pattern?(pattern = nil)
    return false unless pattern
    pattern != GENERIC_REGEXP_PATTERN && pattern != INFINITE_REGEXP_PATTERN
  end

  # "\.test\.created\.today\." => "test\.created\.today"
  #
  # @param regexp_string [String]
  # @option left [Boolean]
  # @option right [Boolean]
  # @return [String]
  #
  # @api private
  # @since 0.13.0
  def strip_regexp_string(regexp_string, left: false, right: false)
    pattern = regexp_string
    pattern = pattern[2..-1] if left && pattern[0..1] == MATCHER_SCOPE_SPLITTER
    pattern = pattern[0..-3] if right && pattern[-2..-1] == MATCHER_SCOPE_SPLITTER
    pattern
  end

  # @param scope_pattern [String]
  # @return [Regexp]
  #
  # @api private
  # @since 0.13.0
  def build_pattern_matcher(scope_pattern)
    routing_parts = scope_pattern.split(SCOPE_SPLITTER)

    regexp_string = routing_parts.each_with_object([]) do |routing_part, regexp_parts|
      case routing_part
      when GENERIC_PART_PATTERN
        regexp_parts << GENERIC_REGEXP_PATTERN
      when INFINITE_PART_PATTERN
        if non_generic_pattern?(regexp_parts.last)
          regexp_parts[-1] = strip_regexp_string(regexp_parts.last, right: true)
        end

        regexp_parts << INFINITE_REGEXP_PATTERN
      else
        regexp_parts << (Regexp.escape(routing_part) + MATCHER_SCOPE_SPLITTER)
      end
    end.join

    regexp_string = strip_regexp_string(regexp_string, left: true, right: true)

    Regexp.new('\A' + regexp_string + '\z')
  end
end
