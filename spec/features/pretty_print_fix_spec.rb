# frozen_string_literal: true

RSpec.describe 'fix' do
  specify do
    Qonfig.enable(:pretty_print)

    class MaConfig < Qonfig::DataSet
      setting :nested do
        setting 'foo.bar'
      end
    end

    config = MaConfig.new
    pp config
  end
end
