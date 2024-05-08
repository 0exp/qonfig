# frozen_string_literal: true

describe 'Expose JSON file' do
  specify 'defines config object by json instructions and specific environment settings' do
    class ExposeJSONConfig < Qonfig::DataSet
      json_file_path = SpecSupport.fixture_path('expose_json', 'project.json')

      setting :file_name_based do
        setting :test_env do
          # spec/fixtures/expose_json/project.test.json
          expose_json json_file_path, via: :file_name, env: :test
        end

        setting :prod_env do
          # spec/fixtures/expose_json/project.production.json
          expose_json json_file_path, via: :file_name, env: :production
        end

        setting :stage_env do
          # spec/fixtures/expose_json/project.staging.json
          expose_json json_file_path, via: :file_name, env: :staging
        end

        setting :dev_env do
          # spec/fixtures/expose_json/project.development.json
          expose_json json_file_path, via: :file_name, env: :development
        end
      end

      setting :env_based do
        setting :test_env do
          # spec/fixtures/expose_json/project.json
          expose_json json_file_path, via: :env_key, env: :test
        end

        setting :prod_env do
          # spec/fixtures/expose_json/project.json
          expose_json json_file_path, via: :env_key, env: :production
        end

        setting :stage_env do
          # spec/fixtures/expose_json/project.json
          expose_json json_file_path, via: :env_key, env: :staging
        end

        setting :dev_env do
          # spec/fixtures/expose_json/project.json
          expose_json json_file_path, via: :env_key, env: :development
        end
      end
    end

    settings = ExposeJSONConfig.new.settings

    # NOTE: file-name based expose
    # spec/fixtures/expose_json/project.test.json
    expect(settings.file_name_based.test_env.api_mode_enabled).to eq(false)
    expect(settings.file_name_based.test_env.db_driver).to eq('in_memory')
    expect(settings.file_name_based.test_env.logging).to eq(false)
    expect(settings.file_name_based.test_env.credentials).to eq({})
    # spec/fixtures/expose_json/project.production.json
    expect(settings.file_name_based.prod_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.prod_env.db_driver).to eq('rom')
    expect(settings.file_name_based.prod_env.logging).to eq(true)
    expect(settings.file_name_based.prod_env.credentials).to eq({})
    # spec/fixtures/expose_json/project.development.json
    expect(settings.file_name_based.dev_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.dev_env.db_driver).to eq('sequel')
    expect(settings.file_name_based.dev_env.logging).to eq(false)
    expect(settings.file_name_based.dev_env.credentials).to eq({})
    # spec/fixtures/expose_json/project.staging.json
    expect(settings.file_name_based.stage_env.api_mode_enabled).to eq(true)
    expect(settings.file_name_based.stage_env.db_driver).to eq('active_record')
    expect(settings.file_name_based.stage_env.logging).to eq(true)
    expect(settings.file_name_based.stage_env.credentials).to eq({})

    # NOTE: environment based expose
    # spec/fixtures/expose_json/project.json (key: 'test')
    expect(settings.env_based.test_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.test_env.db_driver).to eq('in_memory')
    expect(settings.env_based.test_env.logging).to eq(false)
    expect(settings.env_based.test_env.throttle_requests).to eq(false)
    expect(settings.env_based.test_env.credentials).to eq({})
    # spec/fixtures/expose_json/project.json (key: 'production')
    expect(settings.env_based.prod_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.prod_env.db_driver).to eq('rom')
    expect(settings.env_based.prod_env.logging).to eq(true)
    expect(settings.env_based.prod_env.throttle_requests).to eq(true)
    expect(settings.env_based.prod_env.credentials).to eq({})
    # spec/fixtures/expose_json/project.json (key: 'development')
    expect(settings.env_based.dev_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.dev_env.db_driver).to eq('sequel')
    expect(settings.env_based.dev_env.logging).to eq(false)
    expect(settings.env_based.dev_env.throttle_requests).to eq(false)
    expect(settings.env_based.dev_env.credentials).to eq({})
    # spec/fixtures/expose_json/project.json (key: 'staging')
    expect(settings.env_based.stage_env.api_mode_enabled).to eq(true)
    expect(settings.env_based.stage_env.db_driver).to eq('active_record')
    expect(settings.env_based.stage_env.logging).to eq(true)
    expect(settings.env_based.stage_env.throttle_requests).to eq(true)
    expect(settings.env_based.stage_env.credentials).to eq({})
  end

  specify 'support for Pathname in file path' do
    class PathnameExposeJSONCheck < Qonfig::DataSet
      expose_json(
        Pathname.new(SpecSupport.fixture_path('expose_json', 'project.json')),
        via: :env_key, env: :development
      )
    end

    config = PathnameExposeJSONCheck.new

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
            expose_json SpecSupport.fixture_path(
              'expose_json', 'project.json'
            ), via: :env_key, env: Object.new
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when :env is empty' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_json SpecSupport.fixture_path(
              'expose_json', 'project.json'
            ), via: :env_key, env: ''
          end
        end.to raise_error(Qonfig::ArgumentError)
      end

      specify 'fails when provided :via is not supported' do
        expect do
          Class.new(Qonfig::DataSet) do
            expose_json SpecSupport.fixture_path(
              'expose_json', 'project.json'
            ), via: :auto, env: :production
          end
        end.to raise_error(Qonfig::ArgumentError)
      end
    end

    describe 'initialization level errors' do
      specify 'fails when env-based settings is represented as a non-hash-like data' do
        # NOTE:
        #   - file: spec/fixtures/expose_json/incompatible_structure.json
        #   - :staging environment key has incorrect value (scalar)
        #   - :test environment key has correct value (hash)

        class IncompatibleEnvBasedJSONConfig < Qonfig::DataSet
          expose_json SpecSupport.fixture_path(
            'expose_json', 'incompatible_structure.json'
          ), via: :env_key, env: :staging
        end

        expect do
          IncompatibleEnvBasedJSONConfig.new
        end.to raise_error(Qonfig::IncompatibleJSONStructureError)

        class CompatibleEnvBasedJSONConfig < Qonfig::DataSet
          expose_json SpecSupport.fixture_path(
            'expose_json', 'incompatible_structure.json'
          ), via: :env_key, env: :test
        end

        expect { CompatibleEnvBasedJSONConfig.new }.not_to raise_error
      end

      specify 'fails when json structure is represented as a non-hash-like data in the root' do
        # NOTE:
        #  - file: spec/fixtures/expose_json/incompatible_root_structure.json
        #  - in the root: array
        #  - inside array: correct json object with "staging" and "test" environments"
        #  - expected behaviour: exception (because of the root is an array)

        class IncompatibleEnvBasedRootStructureJSONConfig < Qonfig::DataSet
          expose_json SpecSupport.fixture_path(
            'expose_json', 'incompatible_root_structure.json'
          ), via: :env_key, env: :test
        end

        expect do
          IncompatibleEnvBasedRootStructureJSONConfig.new
        end.to raise_error(Qonfig::IncompatibleJSONStructureError)
      end

      describe 'strict mode' do
        specify(
          'disabled (non-strict): ' \
          'file existence requirement + json-env-key existence requirement'
        ) do
          # NOTE: file does not exist + env key does not exist in json file
          class NoFileNonStrictExposeJSONConfig < Qonfig::DataSet
            setting :non_strict_by_file do
              expose_json SpecSupport.fixture_path(
                'expose_json', 'nonexistent.json'
              ), strict: false, via: :file_name, env: :development
            end

            setting :non_strict_by_env do
              expose_json SpecSupport.fixture_path(
                'expose_json', 'nonexistent.json'
              ), strict: false, via: :env_key, env: :development
            end
          end

          expect(NoFileNonStrictExposeJSONConfig.new.to_h).to match(
            'non_strict_by_file' => {},
            'non_strict_by_env'  => {}
          )

          # NOTE: file is exist + env key does not exist in json file
          class NoEnvKeyNonStrictExposeJSONConfig < Qonfig::DataSet
            setting :non_strict_by_file do
              expose_json SpecSupport.fixture_path(
                'expose_json', 'project.json'
              ), strict: false, via: :file_name, env: :nonexistent
            end

            setting :non_strict_by_env do
              expose_json SpecSupport.fixture_path(
                'expose_json', 'project.json'
              ), strict: false, via: :env_key, env: :nonexistent
            end
          end

          expect(NoEnvKeyNonStrictExposeJSONConfig.new.to_h).to match(
            'non_strict_by_file' => {},
            'non_strict_by_env'  => {}
          )
        end

        specify(
          'enabled (strict, by default): ' \
          'file existence requirement + json-env-key existence requirement'
        ) do
          # NOTE: file does not exist
          class StrictFileViaFileNameJSONConfig < Qonfig::DataSet
            expose_json SpecSupport.fixture_path(
              'expose_json', 'nonexistent.json'
            ), via: :file_name, env: :production
          end

          # NOTE: file does not exist
          class StrictFileViaEnvKeyJSONConfig < Qonfig::DataSet
            expose_json SpecSupport.fixture_path(
              'expose_json', 'nonexistent.json'
            ), via: :env_key, env: :production
          end

          # NOTE: file does not exist
          expect { StrictFileViaFileNameJSONConfig.new }.to raise_error(Qonfig::FileNotFoundError)
          expect { StrictFileViaEnvKeyJSONConfig.new }.to   raise_error(Qonfig::FileNotFoundError)

          # NOTE:
          #   - file exists but env key does not exist
          #   - file: spec/fixtures/expose_json/project.json
          class NonExistentEnvKeyJSONConfig < Qonfig::DataSet
            expose_json SpecSupport.fixture_path(
              'expose_json', 'project.json'
            ), via: :env_key, env: :nonexistent
          end

          # NOTE: env key does not exist
          expect { NonExistentEnvKeyJSONConfig.new }.to raise_error(Qonfig::ExposeError)
        end
      end
    end
  end

  describe ':replace_on_merge mode option (when file does not exist)' do
    context 'when :replace_on_merge => true' do
      specify 'replaces the key (does not merge)' do
        class ExposeJSONConflict < Qonfig::DataSet
          expose_json Pathname.new(
            SpecSupport.fixture_path('conflicting_settings/expose_json_1.json')
          ),
                      via: :env_key, env: :production
          expose_json Pathname.new(
            SpecSupport.fixture_path('conflicting_settings/expose_json_2.json')
          ),
                      via: :env_key, env: :production,
                      replace_on_merge: true
        end

        expect(ExposeJSONConflict.new.to_h).to eq({
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
