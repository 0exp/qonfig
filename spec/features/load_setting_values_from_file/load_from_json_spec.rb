# frozen_string_literal: true

require_relative 'by_macros_examples'
require_relative 'by_instance_method_examples'

describe 'Load setting values from JSON file' do
  describe 'DSL macros (Qonfig::DataSet.values_file)' do
    it_behaves_like 'load setting values from file by macros',
                    file_name: SpecSupport.fixture_path('values_file', 'without_env.json'),
                    file_with_env_name: SpecSupport.fixture_path('values_file', 'with_env.json'),
                    file_format: :json
  end

  describe 'Instance methods (Qonfig::DataSet#load_from_file/.load_from_json' do
    it_behaves_like 'load setting values from file by instance methods',
                    file_name: SpecSupport.fixture_path('values_file', 'without_env.json'),
                    file_with_env_name: SpecSupport.fixture_path('values_file', 'with_env.json'),
                    load_by: :load_from_json,
                    file_format: :json
  end
end
