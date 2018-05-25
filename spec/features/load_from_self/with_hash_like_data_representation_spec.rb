# frozen_string_literal: true

describe 'Load from self (hash-like __END__ data representation)' do
  specify 'defines config object by self-contained __END__ yaml data' do
    class SelfDefinedConfig < Qonfig::DataSet
      load_from_self
    end

    SelfDefinedConfig.new.settings.tap do |conf|
      expect(conf.database.user).to     eq('admin')
      expect(conf.database.password).to eq('admin')
      expect(conf.database.host).to     eq('1.2.3.4')
      expect(conf.database.port).to     eq(666)
      expect(conf.enable_api).to        eq(true)

      expect(conf['database']['user']).to     eq('admin')
      expect(conf['database']['password']).to eq('admin')
      expect(conf['database']['host']).to     eq('1.2.3.4')
      expect(conf['database']['port']).to     eq(666)
      expect(conf[:enable_api]).to            eq(true)
    end
  end
end

__END__

database:
  user: admin
  password: admin
  host: 1.2.3.4
  port: 666
:enable_api: true
