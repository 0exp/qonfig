# frozen_string_literal: true

require_relative '../../../load_setting_values_from_file/by_macros_examples'
require_relative '../../../load_setting_values_from_file/by_instance_method_examples'

fdescribe 'Plugins(toml): Load setting values from file', :plugin do
  before do
    require 'toml-rb'
    Qonfig.plugin(:toml)
  end

  describe 'DSL macros (Qonfig::DataSet.values_file)' do
    it_behaves_like(
      'load setting values from file by macros',
      file_name: SpecSupport.fixture_path('plugins', 'toml', 'values_file', 'without_env.toml'),
      file_with_env_name: SpecSupport.fixture_path('plugins', 'toml', 'values_file', 'with_env.toml'),
      file_format: :toml
    )
  end

  describe 'Instance methods (Qonfig::DataSet#load_from_file/.load_from_toml' do
    it_behaves_like(
      'load setting values from file by instance methods',
      file_name: SpecSupport.fixture_path('plugins', 'toml', 'values_file', 'without_env.toml'),
      file_with_env_name: SpecSupport.fixture_path('plugins', 'toml', 'values_file', 'with_env.toml'),
      load_by: :load_from_toml,
      file_format: :toml
    )
  end
end
