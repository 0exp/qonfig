# frozen_string_literal: true

module SpecSupport
  extend self

  # @return [String]
  ARTIFACTS_PATH = File.expand_path(File.join('..', 'artifacts'), __dir__).freeze
  # @return [String]
  FIXTURES_PATH = File.expand_path(File.join('..', 'fixtures'), __dir__).freeze

  # @param parts [Array<String>]
  # @return [String]
  def fixture_path(*parts)
    File.join(FIXTURES_PATH, *parts)
  end

  # @params [Array<String>]
  # @return [String]
  def artifact_path(*parts)
    File.join(ARTIFACTS_PATH, *parts)
  end

  # @return [Boolean]
  def test_plugins?
    !!ENV['TEST_PLUGINS']
  end

  # @param object [Any]
  # @return [String]
  def from_object_id_space_to_value_space(object)
    # NOTE: see Object#object_id source code for comments
    # NOTE: it does not work on Ruby >= 2.7.0 (works on Ruby < 2.7.0 only)
    value_space = format('%x', (object.object_id << 1)) # rubocop:disable Style/FormatStringToken
    alignment = '0' * (16 - value_space.size)
    "#{alignment}#{value_space}"
  end
end
