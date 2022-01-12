# frozen_string_literal: true

# rubocop:disable Style/SingleArgumentDig
describe 'Dot-notation' do
  let(:config) do
    Qonfig::DataSet.build do
      setting :kek do
        setting :pek do
          setting :cheburek, 'test'
        end

        setting 'foo.bar', 100_500

        setting :frek do
          setting :jek do
            setting :bek, 123_456
          end
        end
      end
    end
  end

  specify '#key? / #option? / #setting?' do
    expect(config.key?('kek.pek.cheburek')).to eq(true)
    expect(config.key?('kek.pek')).to eq(true)
    expect(config.key?('kek')).to eq(true)
    expect(config.key?('kek.foo.bar')).to eq(true)
    expect(config.key?('kek.cheburek.pek')).to eq(false)
    expect(config.key?('kek.cheburek')).to eq(false)

    expect(config.option?('kek.pek.cheburek')).to eq(true)
    expect(config.option?('kek.pek')).to eq(true)
    expect(config.option?('kek')).to eq(true)
    expect(config.option?('kek.foo.bar')).to eq(true)
    expect(config.option?('kek.cheburek.pek')).to eq(false)
    expect(config.option?('kek.cheburek')).to eq(false)

    expect(config.setting?('kek.pek.cheburek')).to eq(true)
    expect(config.setting?('kek.pek')).to eq(true)
    expect(config.setting?('kek')).to eq(true)
    expect(config.setting?('kek.foo.bar')).to eq(true)
    expect(config.setting?('kek.cheburek.pek')).to eq(false)
    expect(config.setting?('kek.cheburek')).to eq(false)
  end

  specify '#dig' do
    expect(config.dig('kek.pek.cheburek')).to eq('test')
    expect(config.dig('kek.pek')).to be_a(Qonfig::Settings)
    expect(config.dig('kek')).to be_a(Qonfig::Settings)
    expect(config.dig('kek.foo.bar')).to eq(100_500)

    expect { config.dig('kek.pek.ululek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.dig('kek.ululek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.dig('ululek') }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#subset' do
    expect(config.subset('kek', 'kek.frek')).to match(
      'kek' => {
        'frek' => { 'jek' => { 'bek' => 123456 } },
        'pek' => { 'cheburek'=>'test' },
        'foo.bar' => 100_500
      },
      'frek' => {
        'jek' => { 'bek' => 123_456 }
      }
    )

    expect do
      config.subset('kek', 'kek.frek', 'kek.lel', 'kek.foo')
    end.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#slice' do
    expect(config.slice('kek.pek')).to match('pek' => { 'cheburek' => 'test' })
    expect(config.slice('kek.frek')).to match('frek' => { 'jek' => { 'bek' => 123_456 } })

    # TODO: fix this
    # expect(config.slice('kek.foo.bar')).to match('foo.bar' => 100_500)

    expect { config.slice('lel') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice('kek.lek') }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#slice_value' do
    expect(config.slice_value('kek.pek.cheburek')).to eq('test')
    expect(config.slice_value('kek.pek')).to match('cheburek' => 'test')
    expect(config.slice_value('kek.frek')).to match('jek' => { 'bek' => 123_456 })
    expect(config.slice_value('kek.foo.bar')).to eq(100_500)

    expect { config.slice_value('kek.pek.lelek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value('kek.frek.bek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value('lel') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value('kek.foo') }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#[]' do
    expect(config['kek.pek.cheburek']).to eq('test')
    expect(config['kek.pek']).to be_a(Qonfig::Settings)
    expect(config['kek.pek']['cheburek']).to eq('test')
    expect(config['kek']['frek.jek']['bek']).to eq(123_456)
    expect(config['kek']['foo.bar']).to eq(100_500)
    expect(config['kek.foo.bar']).to eq(100_500)

    expect { config['kek.foo'] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config['kek.pek.lelek'] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config['kek.frek']['bek'] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config['lel'] }.to raise_error(Qonfig::UnknownSettingError)
  end

  describe '#to_h' do
    specify 'default behavior' do
      expect(config.to_h(dot_style: true)).to match(
        'kek.pek.cheburek' => 'test',
        'kek.foo.bar' => 100_500,
        'kek.frek.jek.bek' => 123_456
      )
    end

    specify 'with key and value transformations' do
      transformer = -> (value) { "#{value}!!" }

      # transformations: key ONLY
      hash = config.to_h(
        dot_style: true,
        key_transformer: transformer
      )
      expect(hash).to match(
        'kek.pek.cheburek!!' => 'test',
        'kek.foo.bar!!' => 100_500,
        'kek.frek.jek.bek!!' => 123_456
      )

      # transformations: value ONLY
      hash = config.to_h(
        dot_style: true,
        value_transformer: transformer
      )
      expect(hash).to match(
        'kek.pek.cheburek' => 'test!!',
        'kek.foo.bar' => '100500!!',
        'kek.frek.jek.bek' => '123456!!'
      )

      # transformations: key AND value
      hash = config.to_h(
        dot_style: true,
        key_transformer: transformer,
        value_transformer: transformer
      )
      expect(hash).to match(
        'kek.pek.cheburek!!' => 'test!!',
        'kek.foo.bar!!' => '100500!!',
        'kek.frek.jek.bek!!' => '123456!!'
      )
    end
  end
end
# rubocop:enable Style/SingleArgumentDig
