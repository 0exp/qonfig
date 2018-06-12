# frozen_string_literal: true

describe 'Mixin (Qonfig::Configurable)' do
  ENV['QONFIG_MIXIN_GENERIC_VARIABLE'] = 'true'

  class AnyApplication
    include Qonfig::Configurable

    configuration do
      setting :env do
        load_from_env convert_values: true, prefix: 'QONFIG_MIXIN_', trim_prefix: true
      end

      setting :data do
        load_from_self
      end
    end
  end

  class InheritedApplication < AnyApplication
    configuration do
      setting :database do
        setting :adapter, 'postgresql'
      end
    end
  end

  specify 'configurable class+instance level behaviour with working inheritance' do
    any_app = AnyApplication.new

    # class has it's own config object
    expect(AnyApplication.config[:env][:GENERIC_VARIABLE]).to eq(true)
    expect(AnyApplication.config[:data][:version]).to eq(RUBY_VERSION)
    expect(AnyApplication.config[:data][:language]).to eq('ruby')

    # instance has it's own config object
    expect(any_app.config[:env][:GENERIC_VARIABLE]).to eq(true)
    expect(any_app.config[:data][:version]).to eq(RUBY_VERSION)
    expect(any_app.config[:data][:language]).to eq('ruby')

    # configure class-level config object
    AnyApplication.configure do |conf|
      conf.data.version  = '9.2.0.0'
      conf.data.language = 'jruby'
      conf[:env][:GENERIC_VARIABLE] = false
    end

    # class config - affected
    expect(AnyApplication.config[:env][:GENERIC_VARIABLE]).to eq(false)
    expect(AnyApplication.config[:data][:version]).to eq('9.2.0.0')
    expect(AnyApplication.config[:data][:language]).to eq('jruby')

    # instance config - not affected
    expect(any_app.config[:env][:GENERIC_VARIABLE]).to eq(true)
    expect(any_app.config[:data][:version]).to eq(RUBY_VERSION)
    expect(any_app.config[:data][:language]).to eq('ruby')

    # configure instance-level config object
    any_app.configure do |conf|
      conf.data.version = '2.4.1'
      conf.data.language = 'mruby'
      conf[:env][:GENERIC_VARIABLE] = nil
    end

    # class config - not affected
    expect(AnyApplication.config[:env][:GENERIC_VARIABLE]).to eq(false)
    expect(AnyApplication.config[:data][:version]).to eq('9.2.0.0')
    expect(AnyApplication.config[:data][:language]).to eq('jruby')

    # instance config - affected
    expect(any_app.config[:env][:GENERIC_VARIABLE]).to eq(nil)
    expect(any_app.config[:data][:version]).to eq('2.4.1')
    expect(any_app.config[:data][:language]).to eq('mruby')

    # --- same with inhertiance ---

    # inherited instance
    inh_app = InheritedApplication.new

    # class has it's own config object
    expect(InheritedApplication.config[:env][:GENERIC_VARIABLE]).to eq(true)
    expect(InheritedApplication.config[:data][:version]).to eq(RUBY_VERSION)
    expect(InheritedApplication.config[:data][:language]).to eq('ruby')
    expect(InheritedApplication.config[:database][:adapter]).to eq('postgresql')

    # instance has it's own config object
    expect(inh_app.config[:env][:GENERIC_VARIABLE]).to eq(true)
    expect(inh_app.config[:data][:version]).to eq(RUBY_VERSION)
    expect(inh_app.config[:data][:language]).to eq('ruby')
    expect(inh_app.config[:database][:adapter]).to eq('postgresql')

    # configure class-level config object
    InheritedApplication.configure do |conf|
      conf[:env][:GENERIC_VARIABLE] = '123'
      conf[:data][:version] = '2.2.10'
      conf[:data][:language] = 'super_ruby'
      conf[:database][:adapter] = 'oracle'
    end

    # class config - affected
    expect(InheritedApplication.config[:env][:GENERIC_VARIABLE]).to eq('123')
    expect(InheritedApplication.config[:data][:version]).to eq('2.2.10')
    expect(InheritedApplication.config[:data][:language]).to eq('super_ruby')
    expect(InheritedApplication.config[:database][:adapter]).to eq('oracle')

    # instance config - not affected
    expect(inh_app.config[:env][:GENERIC_VARIABLE]).to eq(true)
    expect(inh_app.config[:data][:version]).to eq(RUBY_VERSION)
    expect(inh_app.config[:data][:language]).to eq('ruby')
    expect(inh_app.config[:database][:adapter]).to eq('postgresql')

    # configure instance-level config object
    inh_app.configure do |conf|
      conf[:env][:GENERIC_VARIABLE] = 'mega-blast'
      conf[:data][:version] = '3x3'
      conf[:data][:language] = 'ultimate_ruby'
      conf[:database][:adapter] = 'mongodb'
    end

    # class config - not affected
    expect(InheritedApplication.config[:env][:GENERIC_VARIABLE]).to eq('123')
    expect(InheritedApplication.config[:data][:version]).to eq('2.2.10')
    expect(InheritedApplication.config[:data][:language]).to eq('super_ruby')
    expect(InheritedApplication.config[:database][:adapter]).to eq('oracle')

    # instance config - affected
    expect(inh_app.config[:env][:GENERIC_VARIABLE]).to eq('mega-blast')
    expect(inh_app.config[:data][:version]).to eq('3x3')
    expect(inh_app.config[:data][:language]).to eq('ultimate_ruby')
    expect(inh_app.config[:database][:adapter]).to eq('mongodb')

    # -- there are no intersections between original and inherited entities --
    expect(any_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => nil },
      'data' => { 'version' => '2.4.1', 'language' => 'mruby' }
    )

    expect(AnyApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => false },
      'data' => { 'version' => '9.2.0.0', 'language' => 'jruby' }
    )

    expect(inh_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => 'mega-blast' },
      'data' => { 'version' => '3x3', 'language' => 'ultimate_ruby' },
      'database' => { 'adapter' => 'mongodb' }
    )

    expect(InheritedApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => '123' },
      'data' => { 'version' => '2.2.10', 'language' => 'super_ruby' },
      'database' => { 'adapter' => 'oracle' }
    )

    # --- configuration with hash / hash + proc
    AnyApplication.configure(env: { GENERIC_VARIABLE: false }) do |conf|
      conf.data.version = '2.2.11'
      conf.data.language = 'mega_ruby'
    end
    expect(AnyApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => false },
      'data' => { 'version' => '2.2.11', 'language' => 'mega_ruby' },
    )

    any_app.configure(data: { version: '3x3' }) do |conf|
      conf.data.language = 'ultra_ruby'
      conf.env[:GENERIC_VARIABLE] = nil
    end
    expect(any_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => nil },
      'data' => { 'version' => '3x3', 'language' => 'ultra_ruby' },
    )

    [AnyApplication, any_app].each do |configurable|
      expect do
        configurable.configure(env: { nonexistent_key: 100 })
      end.to raise_error(Qonfig::UnknownSettingError)
      expect do
        configurable.configure(nonexistent_key: false)
      end.to raise_error(Qonfig::UnknownSettingError)
      expect do
        configurable.configure(env: nil)
      end.to raise_error(Qonfig::AmbiguousSettingValueError)
    end

    # --- config definitions extend working correctly ---
    AnyApplication.configuration do
      setting :any_additional, 'any'
    end

    InheritedApplication.configuration do
      setting :inh_additional, 'inh'
    end

    AnyApplication.config.reload!
    any_app.config.reload!

    InheritedApplication.config.reload!
    inh_app.config.reload!

    expect(any_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => true },
      'data' => { 'version' => RUBY_VERSION, 'language' => 'ruby' },
      'any_additional' => 'any'
    )

    expect(AnyApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => true },
      'data' => { 'version' => RUBY_VERSION, 'language' => 'ruby' },
      'any_additional' => 'any'
    )

    expect(inh_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => true },
      'data' => { 'version' => RUBY_VERSION, 'language' => 'ruby' },
      'database' => { 'adapter' => 'postgresql' },
      'inh_additional' => 'inh'
    )

    expect(InheritedApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => true },
      'data' => { 'version' => RUBY_VERSION, 'language' => 'ruby' },
      'database' => { 'adapter' => 'postgresql' },
      'inh_additional' => 'inh'
    )

    # --- #clear! works correctly ---
    AnyApplication.config.clear!
    any_app.config.clear!

    InheritedApplication.config.clear!
    inh_app.config.clear!

    expect(any_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => nil },
      'data' => { 'version' => nil, 'language' => nil },
      'any_additional' => nil
    )

    expect(AnyApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => nil },
      'data' => { 'version' => nil, 'language' => nil },
      'any_additional' => nil
    )

    expect(inh_app.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => nil },
      'data' => { 'version' => nil, 'language' => nil },
      'database' => { 'adapter' => nil },
      'inh_additional' => nil
    )

    expect(InheritedApplication.config.to_h).to match(
      'env' => { 'GENERIC_VARIABLE' => nil },
      'data' => { 'version' => nil, 'language' => nil },
      'database' => { 'adapter' => nil },
      'inh_additional' => nil
    )

    # --- #freeze! does not intersects between class-level and instance-level configs ---
    # --- #freeze! does not intersects between original and inherited entities ---

    AnyApplication.config.freeze!

    expect do
      AnyApplication.configure { |conf| conf.any_additional = true }
    end.to raise_error(Qonfig::FrozenSettingsError)

    expect do
      AnyApplication.configure { |conf| conf.any_additional = true }
    end.to raise_error(Qonfig::FrozenSettingsError)

    expect do
      any_app.configure { |conf| conf.any_additional = true }
    end.not_to raise_error

    expect do
      InheritedApplication.configure { |conf| conf.inh_additional = true }
    end.not_to raise_error

    expect do
      inh_app.configure { |conf| conf.inh_additional = true }
    end.not_to raise_error

    any_app.config.freeze!

    expect do
      any_app.configure { |conf| conf.any_additional = true }
    end.to raise_error(Qonfig::FrozenSettingsError)

    expect do
      InheritedApplication.configure { |conf| conf.inh_additional = true }
    end.not_to raise_error

    expect do
      inh_app.configure { |conf| conf.inh_additional = true }
    end.not_to raise_error

    InheritedApplication.config.freeze!

    expect do
      InheritedApplication.configure { |conf| conf.inh_additional = true }
    end.to raise_error(Qonfig::FrozenSettingsError)

    expect do
      inh_app.configure { |conf| conf.inh_additional = true }
    end.not_to raise_error

    inh_app.config.freeze!

    expect do
      inh_app.configure { |conf| conf.inh_additional = true }
    end.to raise_error(Qonfig::FrozenSettingsError)
  end
end

__END__

version: <%= RUBY_VERSION %>
language: ruby
