# frozen_string_literal: true

describe 'Plugins' do
  specify 'plguin regsitration, load and resolving' do
    # plugins are not registered
    expect(Qonfig::Plugins.names).not_to include('internal_test_plugin', 'external_test_plugin')
    expect(Qonfig.plugins).not_to        include('internal_test_plugin', 'external_test_plugin')

    InternalTestPluginInterceptor = Class.new { def self.invoke; end }
    ExternalTestPluginInterceptor = Class.new { def self.call; end }

    module Qonfig::Plugins
      class InternalTestPlugin < Abstract
        def self.install!
          InternalTestPluginInterceptor.invoke
        end
      end

      class ExternalTestPlugin < Abstract
        def self.install!
          ExternalTestPluginInterceptor.call
        end
      end

      # register new plugins
      register_plugin(:internal_test_plugin, InternalTestPlugin)
      register_plugin(:external_test_plugin, ExternalTestPlugin)
    end

    # plugins are registered
    expect(Qonfig::Plugins.names).to include('internal_test_plugin', 'external_test_plugin')
    expect(Qonfig.plugins).to        include('internal_test_plugin', 'external_test_plugin')

    # new plugins is not included in #loaded_plugins list
    expect(Qonfig.loaded_plugins).not_to include('internal_test_plugin')
    expect(Qonfig.loaded_plugins).not_to include('external_test_plugin')
    expect(Qonfig.enabled_plugins).not_to include('internal_test_plugin')
    expect(Qonfig.enabled_plugins).not_to include('external_test_plugin')
    expect(Qonfig.loaded_plugins).to eq(Qonfig.enabled_plugins)

    # plugin can be loaded
    expect(InternalTestPluginInterceptor).to receive(:invoke).exactly(4).times
    Qonfig::Plugins.load(:internal_test_plugin)
    Qonfig::Plugins.load('internal_test_plugin')
    Qonfig.plugin(:internal_test_plugin)
    Qonfig.plugin('internal_test_plugin')
    expect(Qonfig.loaded_plugins).to include('internal_test_plugin')
    expect(Qonfig.loaded_plugins).not_to include('external_test_plugin')
    expect(Qonfig.enabled_plugins).to include('internal_test_plugin')
    expect(Qonfig.enabled_plugins).not_to include('external_test_plugin')
    expect(Qonfig.loaded_plugins).to eq(Qonfig.enabled_plugins)

    # plugin can be loaded
    expect(ExternalTestPluginInterceptor).to receive(:call).exactly(4).times
    Qonfig::Plugins.load(:external_test_plugin)
    Qonfig::Plugins.load('external_test_plugin')
    Qonfig.enable(:external_test_plugin)
    Qonfig.enable('external_test_plugin')
    expect(Qonfig.loaded_plugins).to include('external_test_plugin')
    expect(Qonfig.loaded_plugins).to include('internal_test_plugin')
    expect(Qonfig.enabled_plugins).to include('external_test_plugin')
    expect(Qonfig.enabled_plugins).to include('internal_test_plugin')
    expect(Qonfig.loaded_plugins).to eq(Qonfig.enabled_plugins)

    # fails when there is an attempt to register a plugin with already used name
    expect do
      module Qonfig::Plugins
        register_plugin(:internal_test_plugin, Object)
      end
    end.to raise_error(Qonfig::AlreadyRegisteredPluginError)

    # fails when there is an attempt to register a plugin with already used name
    expect do
      module Qonfig::Plugins
        register_plugin(:external_test_plugin, Object)
      end
    end.to raise_error(Qonfig::AlreadyRegisteredPluginError)

    # fails when there is an attempt to load an unregistered plugin
    expect do
      Qonfig::Plugins.load(:kek_test_plugin)
    end.to raise_error(Qonfig::UnregisteredPluginError)

    # fails when there is an attempt to load an unregistered plugin
    expect do
      Qonfig.plugin(:kek_test_plugin)
    end.to raise_error(Qonfig::UnregisteredPluginError)
  end
end
