# frozen_string_literal: true

describe 'Plugins(toml): Load from .toml (TOML)', plugin: :toml do
  specify 'defines config object by toml instructions' do
    class TomlConfig < Qonfig::DataSet
      load_from_toml SpecSupport.fixture_path('plugins', 'toml', 'toml_sample_with_all_types.toml')
    end

    TomlConfig.new.settings.tap do |conf|
      expect(conf.key_in_air).to eq('TOML Example')

      expect(conf.inline_table_of_tables).to eq([
        { 'x' => 1, 'y' => 2, 'z' => 3 },
        { 'x' => 7, 'y' => 8, 'z' => 9 },
        { 'x' => 2, 'y' => 4, 'z' => 8 }
      ])

      expect(conf.strings.simple_string).to eq('Simple String')
      expect(conf.strings.first_multi_line_string).to eq("first multiline\nstring defined")
      expect(conf.strings.second_multiline_string).to eq("second multiline\nstring defined\n")

      expect(conf.times.first_format).to eq(Time.utc(1979, 0o5, 27, 0o7, 32, 0))
      expect(conf.times.second_format).to eq(Time.new(1979, 0o5, 27, 0o0, 32, 0, '-07:00'))
      expect(conf.times.third_format).to eq(Time.new(1979, 0o5, 27, 0o0, 32, 0.999999, '-07:00'))

      expect(conf.arrays.array_of_integers).to eq([1, 2, 3])
      expect(conf.arrays.array_of_strings).to eq(%w[a b c])
      expect(conf.arrays.array_of_integer_arrays).to eq([[1, 2], [3, 4, 5]])
      expect(conf.arrays.array_of_different_string_literals).to eq(%w[azaza trazaza kek pek])
      expect(conf.arrays.array_of_multityped_arrays).to eq([[1, 2], %w[a b c]])
      expect(conf.arrays.multyline_array).to eq(%w[super puper])

      expect(conf.number_definitions.number_with_parts).to eq([8_001, 8_001, 8_002])
      expect(conf.number_definitions.number_with_idiot_parts).to eq(5_000)
      expect(conf.number_definitions.simple_float).to eq(3.12138)
      expect(conf.number_definitions.epic_float).to eq(5e+22)
      expect(conf.number_definitions.haha_float).to eq(1e6)
      expect(conf.number_definitions.wow_float).to eq(-2E-2)

      expect(conf.booleans.boolean_true).to eq(true)
      expect(conf.booleans.boolean_false).to eq(false)

      expect(conf.nesteds.first.ip).to    eq('10.0.0.1')
      expect(conf.nesteds.first.host).to  eq('google.sru')
      expect(conf.nesteds.second.ip).to   eq('10.0.0.2')
      expect(conf.nesteds.second.host).to eq('poogle.fru')

      expect(conf.deep_nesteds).to eq([
        {
          'name'   => 'apple',
          'first'  => { 'model' => 'iphone xs', 'color' => 'white' },
          'second' => [{ 'model' => 'iphone x' }],
          'third'  => [{ 'model' => 'iphone se' }]
        },
        {
          'name'=>'xiaomi',
          'fourth'=>[{ 'model' => 'mi8 explorer edition' }]
        }
      ])
    end
  end

  specify 'support for Pathname in filepath' do
    class PathnameTomlLoadCheckConfig < Qonfig::DataSet
      load_from_toml Pathname.new(SpecSupport.fixture_path('plugins', 'toml', 'mini_file.toml'))
    end

    config = PathnameTomlLoadCheckConfig.new

    expect(config.settings.enabled).to eq(false)
    expect(config.settings.adapter).to eq('sidekiq')
    expect(config.settings.credentials.user).to eq('0exp')
    expect(config.settings.credentials.timeout).to eq(123)
  end

  describe ':strict mode option (when file does not exist)' do
    context 'when :strict => true (by default)' do
      specify 'fails with corresponding error' do
        # check default behaviour (strict: true)
        class FailingTomlConfig < Qonfig::DataSet
          load_from_toml 'no_file.toml'
        end

        expect { FailingTomlConfig.new }.to raise_error(Qonfig::FileNotFoundError)

        class ExplicitlyStrictTomlConfig < Qonfig::DataSet
          load_from_toml 'no_file.toml', strict: true
        end

        expect { ExplicitlyStrictTomlConfig.new }.to raise_error(Qonfig::FileNotFoundError)
      end
    end

    context 'when :strict => false' do
      specify 'does not fail - empty config' do
        class NonFailingTomlConfig < Qonfig::DataSet
          load_from_toml 'no_file.toml', strict: false

          setting :nested do
            load_from_toml 'no_file.toml', strict: false
          end
        end

        expect { NonFailingTomlConfig.new }.not_to raise_error
        expect(NonFailingTomlConfig.new.to_h).to eq('nested' => {})
      end
    end
  end

  describe ':replace_on_merge mode option (when file does not exist)' do
    context 'when :replace_on_merge => true' do
      specify 'replaces the key (does not merge)' do
        class ConflictingSettings < Qonfig::DataSet
          load_from_toml Pathname.new(
            SpecSupport.fixture_path('plugins', 'toml', 'conflicting_settings/toml_1.toml')
          )
          load_from_toml Pathname.new(
            SpecSupport.fixture_path('plugins', 'toml', 'conflicting_settings/toml_2.toml')
          ), replace_on_merge: true
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
