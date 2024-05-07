# frozen_string_literal: true

describe 'Plugins(toml): expose TOML file', plugin: :toml do
  specify 'defines config object by toml instructions and specific environment settings' do
    class ExposeTOMLConfig < Qonfig::DataSet
      toml_file_path = SpecSupport.fixture_path('plugins', 'toml', 'expose_toml', 'project.toml')

      setting :file_name_based do
        setting :test_env do
          # spec/fixtures/plugins/toml/expose_toml/project.test.toml
          expose_toml toml_file_path, via: :file_name, env: :test
        end

        setting :prod_env do
          # spec/fixtures/plugins/toml/expose_toml/project.production.toml
          expose_toml toml_file_path, via: :file_name, env: :production
        end

        setting :stage_env do
          # spec/fixtures/plugins/toml/expose_toml/project.staging.toml
          expose_toml toml_file_path, via: :file_name, env: :staging
        end

        setting :dev_env do
          # spec/fixtures/plugins/toml/expose_toml/project.development.yml
          expose_toml toml_file_path, via: :file_name, env: :development
        end
      end

      setting :env_based do
        setting :test_env do
          # spec/fixtures/plugins/toml/expose_toml/project.toml
          expose_toml toml_file_path, via: :env_key, env: :test
        end

        setting :prod_env do
          # spec/fixtures/plugins/toml/expose_toml/project.toml
          expose_toml toml_file_path, via: :env_key, env: :production
        end

        setting :stage_env do
          # spec/fixtures/plugins/toml/expose_toml/project.toml
          expose_toml toml_file_path, via: :env_key, env: :staging
        end

        setting :dev_env do
          # spec/fixtures/plugins/toml/expose_toml/project.toml
          expose_toml toml_file_path, via: :env_key, env: :development
        end
      end
    end

    settings = ExposeTOMLConfig.new.settings

    # NOTE: file-name based expose
    # spec/fixtures/plugins/toml/expose_toml/project.test.toml
    expect(settings.file_name_based.test_env.api_mode_enabled).to eq(false)
    expect(settings.file_name_based.test_env.db_driver).to eq('in_memory')
    expect(settings.file_name_based.test_env.logging).to eq(false)
    expect(settings.file_name_based.test_env.credentials).to eq({})
    # spec/fixtures/plugins/toml/expose_toml/project.production.toml
    expect(settings.file_name_based.prod_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.prod_env.db_driver).to eq('rom')
    expect(settings.file_name_based.prod_env.logging).to eq(true)
    expect(settings.file_name_based.prod_env.credentials).to eq({})
    # spec/fixtures/plugins/toml/expose_toml/project.development.toml
    expect(settings.file_name_based.dev_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.dev_env.db_driver).to eq('sequel')
    expect(settings.file_name_based.dev_env.logging).to eq(false)
    expect(settings.file_name_based.dev_env.credentials).to eq({})
    # spec/fixtures/plugins/toml/expose_toml/project.staging.toml
    expect(settings.file_name_based.stage_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.stage_env.db_driver).to eq('active_record')
    expect(settings.file_name_based.stage_env.logging).to eq(true)
    expect(settings.file_name_based.stage_env.credentials).to eq({})

    # NOTE: environment based expose
    # spec/fixtures/plugins/toml/expose_toml/projecttoml (table: 'test')
    expect(settings.env_based.test_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.test_env.db_driver).to eq('in_memory')
    expect(settings.env_based.test_env.logging).to eq(false)
    expect(settings.env_based.test_env.throttle_requests).to eq(false)
    expect(settings.env_based.test_env.credentials).to eq({})
    # spec/fixtures/plugins/toml/expose_toml/project.toml (table: 'production')
    expect(settings.env_based.prod_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.prod_env.db_driver).to eq('rom')
    expect(settings.env_based.prod_env.logging).to eq(true)
    expect(settings.env_based.prod_env.throttle_requests).to eq(true)
    expect(settings.env_based.prod_env.credentials).to eq({})
    # spec/fixtures/plugins/toml/expose_toml/projecttoml (table: 'development')
    expect(settings.env_based.dev_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.dev_env.db_driver).to eq('sequel')
    expect(settings.env_based.dev_env.logging).to eq(false)
    expect(settings.env_based.dev_env.throttle_requests).to eq(false)
    expect(settings.env_based.dev_env.credentials).to eq({})
    # spec/fixtures/plugins/toml/expose_toml/projecttoml (table: 'staging')
    expect(settings.env_based.stage_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.stage_env.db_driver).to eq('active_record')
    expect(settings.env_based.stage_env.logging).to eq(true)
    expect(settings.env_based.stage_env.throttle_requests).to eq(true)
    expect(settings.env_based.stage_env.credentials).to eq({})
  end

  describe 'failures and inconsistent situations' do
    describe 'definition level errors' do
      specify 'fails when :env attribute has non-string / non-symbol / non-numeric value' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_toml SpecSupport.fixture_path(
              'plugins', 'toml', 'expose_toml', 'project.toml'
            ), via: :env_key, env: Object.new
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when :env is empty' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_toml SpecSupport.fixture_path(
              'plugins', 'toml', 'expose_toml', 'project.toml'
            ), via: :env_key, env: ''
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when provided :via is not supported' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_toml SpecSupport.fixture_path(
              'plugins', 'toml', 'expose_toml', 'project.toml'
            ), via: :auto, env: :production
          end
        end.to raise_error(Qonfig::ArgumentError)
      end
    end

    describe 'initialization level errors' do
      describe 'strict mode' do
        specify(
          'disabled (non-strict): ' \
          'file existence requirement + yaml-env-key existence requirement'
        ) do
          # NOTE: file does not exist + env key does not exist in toml file
          class NoFileNonStrictExposeTOMLConfig < Qonfig::DataSet
            setting :non_strict_by_file do
              expose_toml SpecSupport.fixture_path(
                'plugins', 'toml', 'expose_toml', 'nonexistent.toml'
              ), strict: false, via: :file_name, env: :development
            end

            setting :non_strict_by_env do
              expose_toml SpecSupport.fixture_path(
                'plugins', 'toml', 'expose_toml', 'nonexistent.toml'
              ), strict: false, via: :env_key, env: :development
            end
          end

          expect(NoFileNonStrictExposeTOMLConfig.new.to_h).to match(
            'non_strict_by_file' => {},
            'non_strict_by_env'  => {}
          )

          # NOTE: file is exist + env key does not exist in toml file
          class NoEnvKeyNonStrictExposeTOMLConfig < Qonfig::DataSet
            setting :non_strict_by_file do
              expose_toml SpecSupport.fixture_path(
                'plugins', 'toml', 'expose_toml', 'project.toml'
              ), strict: false, via: :file_name, env: :nonexistent
            end

            setting :non_strict_by_env do
              expose_toml SpecSupport.fixture_path(
                'plugins', 'toml', 'expose_toml', 'project.toml'
              ), strict: false, via: :env_key, env: :nonexistent
            end
          end

          expect(NoEnvKeyNonStrictExposeTOMLConfig.new.to_h).to match(
            'non_strict_by_file' => {},
            'non_strict_by_env'  => {}
          )
        end

        specify(
          'enabled (strict, by default): ' \
          'file existence requirement + yaml-env-key existence requirement'
        ) do
          # NOTE: file does not exist
          class StrictFileViaFileNameConfig < Qonfig::DataSet
            expose_toml SpecSupport.fixture_path(
              'plugins', 'toml', 'expose_toml', 'nonexistent.toml'
            ), via: :file_name, env: :production
          end

          # NOTE: file does not exist
          class StrictFileViaEnvKeyConfig < Qonfig::DataSet
            expose_toml SpecSupport.fixture_path(
              'plugins', 'toml', 'expose_toml', 'nonexistent.toml'
            ), via: :env_key, env: :production
          end

          # NOTE: file does not exist
          expect { StrictFileViaFileNameConfig.new }.to raise_error(Qonfig::FileNotFoundError)
          expect { StrictFileViaEnvKeyConfig.new }.to   raise_error(Qonfig::FileNotFoundError)

          # NOTE:
          #   - file exists but env key does not exist
          #   - file: spec/fixtures/plugins/toml/expose_toml/project.toml
          class NonExistentEnvKeyConfig < Qonfig::DataSet
            expose_toml SpecSupport.fixture_path(
              'plugins', 'toml', 'expose_toml', 'project.toml'
            ), via: :env_key, env: :nonexistent
          end

          # NOTE: env key does not exist
          expect { NonExistentEnvKeyConfig.new }.to raise_error(Qonfig::ExposeError)
        end
      end
    end
  end

  describe ':replace_on_merge mode option (when file does not exist)' do
    context 'when :replace_on_merge => true' do
      specify 'replaces the key (does not merge)' do
        class ConflictingSettings < Qonfig::DataSet
          expose_toml Pathname.new(
            SpecSupport.fixture_path('plugins', 'toml', 'conflicting_settings/expose_toml_1.toml')
          ), via: :env_key, env: :production
          expose_toml Pathname.new(
            SpecSupport.fixture_path('plugins', 'toml', 'conflicting_settings/expose_toml_2.toml')
          ), via: :env_key, env: :production
        end

        expect(ConflictingSettings.new.to_h).to eq({
          'kek' => 'zek',
          'mek' => {
            'sek' => 'tek'
          },
          'nek' => 'lek'
        })
      end
    end
  end
end
