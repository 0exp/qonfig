# frozen_string_literal: true

require_relative '../../load_setting_values_from_file/by_macros_examples'

fdescribe 'Plugins(toml): Load setting values from file', :plugin do
  before do
    require 'toml-rb'
    Qonfig.plugin(:toml)
  end

  describe 'DSL macros' do
    it_behaves_like(
      'load setting values from file by macros',
      file_name: SpecSupport.fixture_path(
        'plugins', 'toml', 'values_file', 'without_env.toml'
      ),
      file_with_env_name: SpecSupport.fixture_path(
        'plugins', 'toml', 'values_file', 'with_env.toml'
      ),
      file_format: :toml
    )
  end
end
