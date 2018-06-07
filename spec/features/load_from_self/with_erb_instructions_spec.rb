# frozen_string_literal: true

describe 'Load from self (hash-like __END__ data representation with ERB inserts)' do
  specify 'defines config object by self-contained __END__ yaml data with ERB inserts' do
    class SelfDefinedWithErbConfig < Qonfig::DataSet
      load_from_self
    end

    SelfDefinedWithErbConfig.new.settings.tap do |conf|
      expect(conf.defaults.host).to eq('localhost')
      expect(conf.defaults.user).to eq('0exp')
      expect(conf.defaults.password).to eq('password4')

      expect(conf.staging.host).to eq('yandex.ru')
      expect(conf.staging.user).to eq('0exp')
      expect(conf.staging.password).to eq('password4')
    end
  end
end

__END__

defaults: &defaults
  host: localhost
  user: <%= '0exp' %>
  password: <%= "password#{(2 * 2)}" %>

staging:
  <<: *defaults
  host: yandex.ru
