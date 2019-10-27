# frozen_string_literal: true

require_relative 'load_setting_values_from_file/by_macros_examples'

describe 'Load setting values from file' do
  describe 'DSL macros' do
    it_behaves_like 'load setting values from file by macros',
                    file_name: SpecSupport.fixture_path('values_file', 'without_env.yml'),
                    file_with_env_name: SpecSupport.fixture_path('values_file', 'with_env.yml'),
                    file_format: :yml

    it_behaves_like 'load setting values from file by macros',
                    file_name: SpecSupport.fixture_path('values_file', 'without_env.json'),
                    file_with_env_name: SpecSupport.fixture_path('values_file', 'with_env.json'),
                    file_format: :json
  end
end
