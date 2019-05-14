# frozen_string_literal: true

describe 'Load from YAML' do
  specify 'defines config object by yaml instructions' do
    class CISettings < Qonfig::DataSet
      load_from_yaml SpecSupport.fixture_path('shared_settings_with_aliases.yml')

      setting :travis do
        load_from_yaml SpecSupport.fixture_path('travis_settings.yml')
      end

      setting :rubocop do
        load_from_yaml SpecSupport.fixture_path('rubocop_settings.yml')
      end

      setting :with_erb do
        load_from_yaml SpecSupport.fixture_path('with_erb_instructions.yml')
      end

      setting :with_empty_hash do
        load_from_yaml SpecSupport.fixture_path('with_empty_hash.yml')
      end
    end

    CISettings.new.settings.tap do |conf|
      # shared_settings_with_aliases.yml
      expect(conf.enable_api).to eq(false)
      expect(conf.run_sidekiq).to eq(true)
      expect(conf.default.test).to eq(true)
      expect(conf.default.engine).to eq('rspec')
      expect(conf.staging.test).to eq(true)
      expect(conf.staging.engine).to eq('minitest')

      # travis_settings.yml
      expect(conf.travis.language).to eq('ruby')
      expect(conf.travis.rvm).to contain_exactly('2.5.1', 'ruby-head', 'jruby-head')
      expect(conf.travis.sudo).to eq(false)

      # rubocop_settings.yml
      expect(conf['rubocop']['require']).to eq('rubocop-rspec')
      expect(conf['rubocop']['AllCops']['Include']).to contain_exactly('lib/**/*', 'spec/**/*')
      expect(conf['rubocop']['AllCops']['Exclude']).to contain_exactly('bin/**/*', 'Gemfile')
      expect(conf['rubocop']['Metrics/LineLength']['Max']).to eq(100)

      # with_erb_instructions.yml
      expect(conf['with_erb']['user']).to eq('D@iVeR')
      expect(conf['with_erb']['max_auth_count']).to eq(2)
      expect(conf['with_erb']['ruby_version']).to eq(RUBY_VERSION)

      # with_empty_hash.yml
      expect(conf['with_empty_hash']['settings']).to eq({})
      expect(conf['with_empty_hash']['another_settings']['option_a']).to eq({})
      expect(conf['with_empty_hash']['another_settings']['option_b']).to eq(1)
    end
  end

  specify 'fails when yaml settings is not represented as a hash' do
    class IncompatibleYAMLConfig < Qonfig::DataSet
      load_from_yaml SpecSupport.fixture_path('array_settings.yml')
    end

    expect { IncompatibleYAMLConfig.new }.to raise_error(Qonfig::IncompatibleYAMLStructureError)
  end

  describe ':strict mode option (when file does not exist)' do
    context 'when :strict => true (by default)' do
      specify 'fails with corresponding error' do
        # check default behaviour (strict: true)
        class FailingYAMLConfig < Qonfig::DataSet
          load_from_yaml 'no_file.yml'
        end

        expect { FailingYAMLConfig.new }.to raise_error(Qonfig::FileNotFoundError)

        class ExplicitlyStrictedYAMLConfig < Qonfig::DataSet
          load_from_yaml 'no_file.yml', strict: true
        end

        expect { ExplicitlyStrictedYAMLConfig.new }.to raise_error(Qonfig::FileNotFoundError)
      end
    end

    context 'when :strict => false' do
      specify 'does not fail - empty config' do
        class NonFailingYAMLConfig < Qonfig::DataSet
          load_from_yaml 'no_file.yml', strict: false

          setting :nested do
            load_from_yaml 'no_file.yml', strict: false
          end
        end

        expect { NonFailingYAMLConfig.new }.not_to raise_error
        expect(NonFailingYAMLConfig.new.to_h).to eq('nested' => {})
      end
    end
  end
end
