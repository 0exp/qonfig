# frozen_string_literal: true

describe 'Load from self (hash-like __END__ data representation)' do
  specify 'defines config object by self-contained __END__ yaml data' do
    class SelfDefinedConfig < Qonfig::DataSet
      load_from_self

      setting :with_nesting do
        load_from_self
      end
    end

    SelfDefinedConfig.new.settings.tap do |conf|
      expect(conf.secret_key).to eq('top-mega-secret')
      expect(conf.api_host).to eq('super.puper-google.com')
      expect(conf.connection_timeout.seconds).to eq(10)
      expect(conf.connection_timeout.enabled).to eq(false)

      expect(conf['secret_key']).to eq('top-mega-secret')
      expect(conf['api_host']).to eq('super.puper-google.com')
      expect(conf[:connection_timeout]['seconds']).to eq(10)
      expect(conf[:connection_timeout]['enabled']).to eq(false)

      expect(conf.with_nesting.secret_key).to eq('top-mega-secret')
      expect(conf.with_nesting.api_host).to eq('super.puper-google.com')
      expect(conf.with_nesting.connection_timeout.seconds).to eq(10)
      expect(conf.with_nesting.connection_timeout.enabled).to eq(false)

      expect(conf[:with_nesting]['secret_key']).to eq('top-mega-secret')
      expect(conf[:with_nesting]['api_host']).to eq('super.puper-google.com')
      expect(conf[:with_nesting][:connection_timeout]['seconds']).to eq(10)
      expect(conf[:with_nesting][:connection_timeout]['enabled']).to eq(false)
    end
  end
end

__END__

secret_key: top-mega-secret
api_host: super.puper-google.com
:connection_timeout:
   seconds: 10
   enabled: false
