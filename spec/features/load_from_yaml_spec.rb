# frozen_string_literal: true

describe 'Load from YAML' do
  specify 'defines config object by yaml instructions' do
    class CISettings < Qonfig::DataSet
      load_from_yaml File.expand_path(
        File.join('..', '..', 'fixtures', 'shared_settings_with_aliases.yml'),
        Pathname.new(__FILE__).realpath
      )

      setting 'travis' do
        load_from_yaml File.expand_path(
          File.join('..', '..', 'fixtures', 'travis_settings.yml'),
          Pathname.new(__FILE__).realpath
        )
      end

      setting 'rubocop' do
        load_from_yaml File.expand_path(
          File.join('..', '..', 'fixtures', 'rubocop_settings.yml'),
          Pathname.new(__FILE__).realpath
        )
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
    end
  end

  specify 'fails when yaml settings is not represented as a hash' do
    class IncompatibleYAMLConfig < Qonfig::DataSet
      load_from_yaml File.expand_path(
        File.join('..', '..', 'fixtures', 'array_settings.yml'),
        Pathname.new(__FILE__).realpath
      )
    end

    expect { IncompatibleYAMLConfig.new }.to raise_error(Qonfig::IncompatibleYAMLError)
  end
end
