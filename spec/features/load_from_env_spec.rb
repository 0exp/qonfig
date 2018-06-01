# frozen_string_literal: true

describe 'Load from ENV' do
  specify 'defines config object by ENV data' do
    ENV['QONFIG_SPEC_LOAD_ENTRIES'] = 'true'
    ENV['QONFIG_SPEC_RUN_CI_HOOKS'] = '1'

    class EnvConfig < Qonfig::DataSet
      setting :env do
        load_from_env
      end

      setting :converted do
        load_from_env convert_values: true
      end
    end

    config = EnvConfig.new

    # non-converted values
    expect(config['env']['QONFIG_SPEC_LOAD_ENTRIES']).to eq('true')
    expect(config['env']['QONFIG_SPEC_RUN_CI_HOOKS']).to eq('1')

    # converted values
    expect(config['converted']['QONFIG_SPEC_LOAD_ENTRIES']).to eq(true)
    expect(config['converted']['QONFIG_SPEC_RUN_CI_HOOKS']).to eq(1)
  end
end
