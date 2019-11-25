# frozen_string_literal: true

describe 'Plugins(:pretty_print): Pretty print :)', :plugin do
  before { Qonfig.plugin(:pretty_print) }

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
      end

      setting :logging, false
      setting :author, nil
    end)
  end

  let(:pretty_printer_output) { StringIO.new }

  specify 'shows config settings in beatufied format' do
    config = PrettyPrintableConfig.new
    value_space = SpecSupport.from_object_id_space_to_value_space(config)
    PP.pp(config, pretty_printer_output)

    expect(pretty_printer_output.string).to eq(
      "#<PrettyPrintableConfig:0x#{value_space}\n" \
      " api.domain: \"google\",\n" \
      " api.creds.token: \"a0sdj10k@\",\n" \
      " api.creds.login: \"D2\",\n" \
      " database.adapter: \"pg\",\n" \
      " logging: false,\n" \
      " author: nil>\n"
    )
  end
end
