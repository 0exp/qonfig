# frozen_string_literal: true

describe 'Plugins(:pretty_print): Pretty print :)', plugin: :pretty_print do
  before do
    stub_const('PrettyPrintableConfig', Class.new(Qonfig::DataSet) do
      setting :api do
        setting :domain, 'google'
        setting :creds do
          setting :token, 'a0sdj10k@'
          setting :login, 'D2'
        end
      end

      setting :database do
        setting :adapter, 'pg'
        setting 'logging.queries', nil
      end

      setting :logging, false
      setting :author, nil
    end)
  end

  shared_examples 'pretty printing :)' do
    subject(:print_to_console!) { PP.pp(config, pretty_printer_output) }

    let(:pretty_printer_output) { StringIO.new }

    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.7.0')
      specify 'shows config settings in beatufied format' do
        print_to_console!

        expect(pretty_printer_output.string).to include(
          "#<#{expected_config_klass_name}:0x"
        )

        expect(pretty_printer_output.string).to include(
          " api.domain: \"google\",\n " \
          "api.creds.token: \"a0sdj10k@\",\n " \
          "api.creds.login: \"D2\",\n " \
          "database.adapter: \"pg\",\n " \
          "database.logging.queries: nil,\n " \
          "logging: false,\n " \
          "author: nil>\n"
        )
      end
    else
      specify 'shows config settings in beatufied format' do
        print_to_console!
        value_space = SpecSupport.from_object_id_space_to_value_space(config)

        expect(pretty_printer_output.string).to eq(
          "#<#{expected_config_klass_name}:0x#{value_space}\n " \
          "api.domain: \"google\",\n " \
          "api.creds.token: \"a0sdj10k@\",\n " \
          "api.creds.login: \"D2\",\n " \
          "database.adapter: \"pg\",\n " \
          "database.logging.queries: nil,\n " \
          "logging: false,\n " \
          "author: nil>\n"
        )
      end
    end
  end

  context 'pretty-printed Qonfig::DataSet' do
    include_examples 'pretty printing :)' do
      let(:config) { PrettyPrintableConfig.new }
      let(:expected_config_klass_name) { 'PrettyPrintableConfig' }
    end
  end

  context 'pretty-printed Qonfig::Settings' do
    include_examples 'pretty printing :)' do
      let(:config) { PrettyPrintableConfig.new.settings }
      let(:expected_config_klass_name) { 'Qonfig::Settings' }
    end
  end

  context 'pretty-printed Qonfig::Compacted' do
    include_examples 'pretty printing :)' do
      let(:config) { PrettyPrintableConfig.new.compacted }
      let(:expected_config_klass_name) { 'Qonfig::Compacted' }
    end
  end
end
