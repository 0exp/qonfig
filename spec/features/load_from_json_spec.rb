# frozen_string_literal: true

describe 'Load from JSON' do
  specify 'defines config object by json instructions' do
    class JSONBasedConfig < Qonfig::DataSet
      load_from_json SpecSupport.fixture_path('json_object_sample.json')

      setting :nested do
        load_from_json SpecSupport.fixture_path('json_object_sample.json')
      end

      setting :with_empty_objects do
        load_from_json SpecSupport.fixture_path('json_with_empty_object.json')
      end

      setting :with_erb do
        load_from_json SpecSupport.fixture_path('json_with_erb.json')
      end
    end

    JSONBasedConfig.new.settings.tap do |conf|
      expect(conf.user).to eq('D@iVeR')
      expect(conf.maxAuthCount).to eq(55)
      expect(conf.rubySettings.allowedVersions).to eq(['2.3', '2.4.2', '1.9.8'])
      expect(conf.rubySettings.gitLink).to eq(nil)
      expect(conf.rubySettings.withAdditionals).to eq(false)

      expect(conf.nested.user).to eq('D@iVeR')
      expect(conf.nested.maxAuthCount).to eq(55)
      expect(conf.nested.rubySettings.allowedVersions).to eq(['2.3', '2.4.2', '1.9.8'])
      expect(conf.nested.rubySettings.gitLink).to eq(nil)
      expect(conf.nested.rubySettings.withAdditionals).to eq(false)

      expect(conf.with_empty_objects.requirements).to eq({})
      expect(conf.with_empty_objects.credentials.excluded).to eq({})

      expect(conf.with_erb.count).to eq(10_000)
      expect(conf.with_erb.credentials.excluded).to eq('some string here')
    end
  end

  specify 'fails when json object has non-hash-like structure' do
    class IncompatibleJSONConfig < Qonfig::DataSet
      load_from_json SpecSupport.fixture_path('json_array_sample.json')
    end

    expect { IncompatibleJSONConfig.new }.to raise_error(Qonfig::IncompatibleJSONStructureError)
  end

  specify 'support for Pathname in file path' do
    class PathnameJSONLoadCheckConfig < Qonfig::DataSet
      load_from_json Pathname.new(SpecSupport.fixture_path('json_object_sample.json'))
    end

    config = PathnameJSONLoadCheckConfig.new

    expect(config.settings.user).to eq('D@iVeR')
    expect(config.settings.maxAuthCount).to eq(55)
    expect(config.settings.rubySettings.allowedVersions).to eq(['2.3', '2.4.2', '1.9.8'])
    expect(config.settings.rubySettings.gitLink).to eq(nil)
    expect(config.settings.rubySettings.withAdditionals).to eq(false)
  end

  describe ':strict mode option (when file doesnt exist)' do
    context 'when :strict => true (by default)' do
      specify 'fails with corresponding error' do
        # check default behaviour (strict: true)
        class FailingJSONConfig < Qonfig::DataSet
          load_from_json 'no_file.json'
        end

        expect { FailingJSONConfig.new }.to raise_error(Qonfig::FileNotFoundError)

        class ExplicitlyStrictJSONConfig < Qonfig::DataSet
          load_from_json 'no_file.json', strict: true
        end

        expect { ExplicitlyStrictJSONConfig.new }.to raise_error(Qonfig::FileNotFoundError)
      end
    end

    context 'when :strict => false' do
      specify 'does not fail - empty config' do
        class NonFailingJSONConfig < Qonfig::DataSet
          load_from_json 'no_file.json', strict: false

          setting :nested do
            load_from_json 'no_file.json', strict: false
          end
        end

        expect { NonFailingJSONConfig.new }.not_to raise_error
        expect(NonFailingJSONConfig.new.to_h).to eq('nested' => {})
      end
    end
  end

  describe ':replace_on_merge mode option (when file does not exist)' do
    context 'when :replace_on_merge => true' do
      specify 'replaces the key (does not merge)' do
        class ConflictingSettings < Qonfig::DataSet
          load_from_json Pathname.new(SpecSupport.fixture_path('conflicting_settings/json_1.json'))
          load_from_json Pathname.new(SpecSupport.fixture_path('conflicting_settings/json_2.json')),
                         replace_on_merge: true
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
