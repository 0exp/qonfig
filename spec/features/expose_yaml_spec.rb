# frozen_string_literal: true

describe 'Expose YAML file' do
  specify 'defines config object by yaml instructions and specific environment settings' do
    class ExposeYAMLConfig < Qonfig::DataSet
      yaml_file_path = SpecSupport.fixture_path('expose_yaml', 'project.yml')

      setting :file_name_based do
        setting :test_env do
          # spec/fixtures/expose_yaml/project.test.yml
          expose_yaml yaml_file_path, via: :file_name, env: :test
        end

        setting :prod_env do
          # spec/fixtures/expose_yaml/project.production.yml
          expose_yaml yaml_file_path, via: :file_name, env: :production
        end

        setting :stage_env do
          # spec/fixtures/expose_yaml/project.staging.yml
          expose_yaml yaml_file_path, via: :file_name, env: :staging
        end

        setting :dev_env do
          # spec/fixtures/expose_yaml/project.development.yml
          expose_yaml yaml_file_path, via: :file_name, env: :development
        end
      end

      setting :env_based do
        setting :test_env do
          # spec/fixtures/expose_yaml/project.yml
          expose_yaml yaml_file_path, via: :env_key, env: :test
        end

        setting :prod_env do
          # spec/fixtures/expose_yaml/project.yml
          expose_yaml yaml_file_path, via: :env_key, env: :production
        end

        setting :stage_env do
          # spec/fixtures/expose_yaml/project.yml
          expose_yaml yaml_file_path, via: :env_key, env: :staging
        end

        setting :dev_env do
          # spec/fixtures/expose_yaml/project.yml
          expose_yaml yaml_file_path, via: :env_key, env: :development
        end
      end
    end

    settings = ExposeYAMLConfig.new.settings

    # NOTE: file-name based expose
    # spec/fixtures/expose_yaml/project.test.yml
    expect(settings.file_name_based.test_env.api_mode_enabled).to eq(false)
    expect(settings.file_name_based.test_env.db_driver).to eq('in_memory')
    expect(settings.file_name_based.test_env.logging).to eq(false)
    expect(settings.file_name_based.test_env.credentials).to eq({})
    # spec/fixtures/expose_yaml/project.production.yml
    expect(settings.file_name_based.prod_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.prod_env.db_driver).to eq('rom')
    expect(settings.file_name_based.prod_env.logging).to eq(true)
    expect(settings.file_name_based.prod_env.credentials).to eq({})
    # spec/fixtures/expose_yaml/project.development.yml
    expect(settings.file_name_based.dev_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.dev_env.db_driver).to eq('sequel')
    expect(settings.file_name_based.dev_env.logging).to eq(false)
    expect(settings.file_name_based.dev_env.credentials).to eq({})
    # spec/fixtures/expose_yaml/project.staging.yml
    expect(settings.file_name_based.stage_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.stage_env.db_driver).to eq('active_record')
    expect(settings.file_name_based.stage_env.logging).to eq(true)
    expect(settings.file_name_based.stage_env.credentials).to eq({})

    # NOTE: environment based expose
    # spec/fixtures/expose_yaml/project.yml (key: 'test')
    expect(settings.env_based.test_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.test_env.db_driver).to eq('in_memory')
    expect(settings.env_based.test_env.logging).to eq(false)
    expect(settings.env_based.test_env.throttle_requests).to eq(false)
    expect(settings.env_based.test_env.credentials).to eq({})
    # spec/fixtures/expose_yaml/project.yml (key: 'production')
    expect(settings.env_based.prod_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.prod_env.db_driver).to eq('rom')
    expect(settings.env_based.prod_env.logging).to eq(true)
    expect(settings.env_based.prod_env.throttle_requests).to eq(true)
    expect(settings.env_based.prod_env.credentials).to eq({})
    # spec/fixtures/expose_yaml/project.yml (key: 'development')
    expect(settings.env_based.dev_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.dev_env.db_driver).to eq('sequel')
    expect(settings.env_based.dev_env.logging).to eq(false)
    expect(settings.env_based.dev_env.throttle_requests).to eq(false)
    expect(settings.env_based.dev_env.credentials).to eq({})
    # spec/fixtures/expose_yaml/project.yml (key: 'staging')
    expect(settings.env_based.stage_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.stage_env.db_driver).to eq('active_record')
    expect(settings.env_based.stage_env.logging).to eq(true)
    expect(settings.env_based.stage_env.throttle_requests).to eq(true)
    expect(settings.env_based.stage_env.credentials).to eq({})
  end

  specify 'support for Pathname in file path' do
    class PathnameExposeYamlCheck < Qonfig::DataSet
      expose_yaml(
        Pathname.new(SpecSupport.fixture_path('expose_yaml', 'project.yml')),
        via: :env_key, env: :development
      )
    end

    config = PathnameExposeYamlCheck.new

    expect(config.settings.api_mode_enabled).to eq(true)
    expect(config.settings.logging).to eq(false)
    expect(config.settings.db_driver).to eq('sequel')
    expect(config.settings.throttle_requests).to eq(false)
    expect(config.settings.credentials).to eq({})
  end

  describe 'failures and inconsistent situations' do
    describe 'definition level errors' do
      specify 'fails when :env attribute has non-string / non-symbol / non-numeric value' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_yaml SpecSupport.fixture_path(
              'expose_yaml', 'project.yml'
            ), via: :env_key, env: Object.new
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when :env is empty' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_yaml SpecSupport.fixture_path(
              'expose_yaml', 'project.yml'
            ), via: :env_key, env: ''
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when provided :via is not supported' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_yaml SpecSupport.fixture_path(
              'expose_yaml', 'project.yml'
            ), via: :auto, env: :production
          end
        end.to raise_error(Qonfig::ArgumentError)
      end
    end

    describe 'initialization level errors' do
      specify 'fails when env-based settings is represented as a non-hash-like data' do
        # NOTE:
        #   - file: spec/fixtures/expose_yaml/incompatible_structure.yml
        #   - :staging environment key has incorrect value (scalar)
        #   - :test environment key has correct value (hash)

        class IncompatibleEnvBasedYAMLConfig < Qonfig::DataSet
          expose_yaml SpecSupport.fixture_path(
            'expose_yaml', 'incompatible_structure.yml'
          ), via: :env_key, env: :staging
        end

        expect do
          IncompatibleEnvBasedYAMLConfig.new
        end.to raise_error(Qonfig::IncompatibleYAMLStructureError)

        class CompatibleEnvBasedYAMLConfig < Qonfig::DataSet
          expose_yaml SpecSupport.fixture_path(
            'expose_yaml', 'incompatible_structure.yml'
          ), via: :env_key, env: :test
        end

        expect { CompatibleEnvBasedYAMLConfig.new }.not_to raise_error
      end

      describe 'strict mode' do
        specify(
          'disabled (non-strict): ' \
          'file existence requirement + yaml-env-key existence requirement'
        ) do
          # NOTE: file does not exist + env key does not exist in yml file
          class NoFileNonStrictExposeYAMLConfig < Qonfig::DataSet
            setting :non_strict_by_file do
              expose_yaml SpecSupport.fixture_path(
                'expose_yaml', 'nonexistent.yml'
              ), strict: false, via: :file_name, env: :development
            end

            setting :non_strict_by_env do
              expose_yaml SpecSupport.fixture_path(
                'expose_yaml', 'nonexistent.yml'
              ), strict: false, via: :env_key, env: :development
            end
          end

          expect(NoFileNonStrictExposeYAMLConfig.new.to_h).to match(
            'non_strict_by_file' => {},
            'non_strict_by_env'  => {}
          )

          # NOTE: file is exist + env key does not exist in yml file
          class NoEnvKeyNonStrictExposeYAMLConfig < Qonfig::DataSet
            setting :non_strict_by_file do
              expose_yaml SpecSupport.fixture_path(
                'expose_yaml', 'project.yml'
              ), strict: false, via: :file_name, env: :nonexistent
            end

            setting :non_strict_by_env do
              expose_yaml SpecSupport.fixture_path(
                'expose_yaml', 'project.yml'
              ), strict: false, via: :env_key, env: :nonexistent
            end
          end

          expect(NoEnvKeyNonStrictExposeYAMLConfig.new.to_h).to match(
            'non_strict_by_file' => {},
            'non_strict_by_env'  => {}
          )
        end

        specify(
          'enabled (strict, by default): ' \
          'file existence requirement + yaml-env-key existence requirement'
        ) do
          # NOTE: file does not exist
          class StrictFileViaFileNameYAMLConfig < Qonfig::DataSet
            expose_yaml SpecSupport.fixture_path(
              'expose_yaml', 'nonexistent.yml'
            ), via: :file_name, env: :production
          end
          # NOTE: file does not exist
          class StrictFileViaEnvKeyYAMLConfig < Qonfig::DataSet
            expose_yaml SpecSupport.fixture_path(
              'expose_yaml', 'nonexistent.yml'
            ), via: :env_key, env: :production
          end

          # NOTE: file does not exist
          expect { StrictFileViaFileNameYAMLConfig.new }.to raise_error(Qonfig::FileNotFoundError)
          expect { StrictFileViaEnvKeyYAMLConfig.new }.to   raise_error(Qonfig::FileNotFoundError)

          # NOTE:
          #   - file exists but env key does not exist
          #   - file: spec/fixtures/expose_yaml/project.yml
          class NonExistentEnvKeyYAMLConfig < Qonfig::DataSet
            expose_yaml SpecSupport.fixture_path(
              'expose_yaml', 'project.yml'
            ), via: :env_key, env: :nonexistent
          end

          # NOTE: env key does not exist
          expect { NonExistentEnvKeyYAMLConfig.new }.to raise_error(Qonfig::ExposeError)
        end
      end
    end
  end
end
