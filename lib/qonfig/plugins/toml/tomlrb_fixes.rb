# frozen_string_literal: true

# NOTE:
#   - dumper sorts settins keys as a collection of string or symbols only
#   - settings values like { a: 1, 'b' => 2 } will fail on comparison errors (Symbol with String)
#   - problem is located in TomlRB::Dumper#sort_pairs(hash) method
#   - problem code: `hash.keys.sort.map` (failed on `.sort` part)
#   - we can patch this code by explicit `.map(&:to_s)` before `.sort`

# @api private
# @since 0.12.0
module TomlRB::Dumper::SortFixPatch
  private

  def sort_pairs(hash)
    nested_pairs = []
    simple_pairs = []
    table_array_pairs = []

    # NOTE: our fix (original code: `hash.keys.sort`) (for details see notes above)
    fixed_keys_sort(hash).each do |key|
      val = hash[key]
      element = [key, val]

      if val.is_a? Hash
        nested_pairs << element
      elsif val.is_a?(Array) && val.first.is_a?(Hash)
        table_array_pairs << element
      else
        simple_pairs << element
      end
    end

    [simple_pairs, nested_pairs, table_array_pairs]
  end

  # NOTE: our fix (for detales see notes above)
  def fixed_keys_sort(hash)
    hash.keys.sort_by(&:to_s)
  end
end

# NOTE:
#   - dumper uses ultra primitive way to conver objects to toml format
#   - dumper represents nil values as a simple strings without quots,
#     but should not represent them at all
#   - dumper can not validate invalid structures
#     (for example: [1, [2,3], nil] (invalid, cuz arrays should contain values of one type))
module TomlRB::Dumper::ObjectConverterFix
  private

  def dump_simple_pairs(simple_pairs)
    simple_pairs.each do |key, val|
      key = quote_key(key) unless bare_key? key
      # NOTE: our fix (original code: `@toml_str << "#{key} = #{to_toml(val)}\n"`)
      fixed_toml_value_append(key, val)
    end
  end

  # NOTE: our fix
  def fixed_toml_value_append(key, val)
    @toml_str << "#{key} = #{fixed_to_toml(val)}\n" unless val.nil?
  end

  # NOTE our fix
  def fixed_to_toml(object)
    # NOTE: original code of #toml(obj):
    #  if object.is_a? Time
    #    object.strftime('%Y-%m-%dT%H:%M:%SZ')
    #  else
    #    object.inspect
    #  end

    case object
    when Time, DateTime, Date
      object.strftime('%Y-%m-%dT%H:%M:%SZ')
    else
      # NOTE: validate result value via value parsing before dump
      object.inspect.tap { |value| ::TomlRB.parse("sample = #{value}") }
    end
  end
end

# @since 0.12.0
TomlRB::Dumper.prepend(TomlRB::Dumper::SortFixPatch)
# @since 0.12.0
TomlRB::Dumper.prepend(TomlRB::Dumper::ObjectConverterFix)
