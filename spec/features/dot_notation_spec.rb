# frozen_string_literal: true

describe 'Dot-notation' do
  let(:config) do
    Qonfig::DataSet.build do
      setting :kek do
        setting :pek do
          setting :cheburek, 'test'
        end

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
    expect(config.key?('kek.cheburek.pek')).to eq(false)
    expect(config.key?('kek.cheburek')).to eq(false)

    expect(config.option?('kek.pek.cheburek')).to eq(true)
    expect(config.option?('kek.pek')).to eq(true)
    expect(config.option?('kek')).to eq(true)
    expect(config.option?('kek.cheburek.pek')).to eq(false)
    expect(config.option?('kek.cheburek')).to eq(false)

    expect(config.setting?('kek.pek.cheburek')).to eq(true)
    expect(config.setting?('kek.pek')).to eq(true)
    expect(config.setting?('kek')).to eq(true)
    expect(config.setting?('kek.cheburek.pek')).to eq(false)
    expect(config.setting?('kek.cheburek')).to eq(false)
  end

  specify '#dig' do
    expect(config.dig('kek.pek.cheburek')).to eq('test')
    expect(config.dig('kek.pek')).to be_a(Qonfig::Settings)
    expect(config.dig('kek')).to be_a(Qonfig::Settings)

    expect { config.dig('kek.pek.ululek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.dig('kek.ululek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.dig('ululek') }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#subset' do
    expect(config.subset('kek', 'kek.frek')).to match(
      'kek' => {
        'frek' => { 'jek' => { 'bek' => 123456 } },
        'pek' => { 'cheburek'=>'test' }
      },
      'frek' => {
        'jek' => { 'bek' => 123_456 }
      }
    )

    expect do
      config.subset('kek', 'kek.frek', 'kek.lel')
    end.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#slice' do
    expect(config.slice('kek.pek')).to match('pek' => { 'cheburek' => 'test' })
    expect(config.slice('kek.frek')).to match('frek' => { 'jek' => { 'bek' => 123_456 } })

    expect { config.slice('lel') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice('kek.lek') }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#slice_value' do
    expect(config.slice_value('kek.pek.cheburek')).to eq('test')
    expect(config.slice_value('kek.pek')).to match('cheburek' => 'test')
    expect(config.slice_value('kek.frek')).to match('jek' => { 'bek' => 123_456 })

    expect { config.slice_value('kek.pek.lelek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value('kek.frek.bek') }.to raise_error(Qonfig::UnknownSettingError)
    expect { config.slice_value('lel') }.to raise_error(Qonfig::UnknownSettingError)
  end

  specify '#[]' do
    expect(config['kek.pek.cheburek']).to eq('test')
    expect(config['kek.pek']).to be_a(Qonfig::Settings)
    expect(config['kek.pek']['cheburek']).to eq('test')
    expect(config['kek']['frek.jek']['bek']).to eq(123_456)

    expect { config['kek.pek.lelek'] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config['kek.frek']['bek'] }.to raise_error(Qonfig::UnknownSettingError)
    expect { config['lel'] }.to raise_error(Qonfig::UnknownSettingError)
  end
end
