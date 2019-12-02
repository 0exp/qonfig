# frozen_string_literal: true

describe 'Compact config' do
  specify do
    Qonfig.plugin(:pretty_print)

    class CompactCheckConfig < Qonfig::DataSet
      setting :db do
        setting :creds do
          setting :user, 'D@iVeR'
          setting :password, 'test123'
          setting :data, test: false
        end
      end
    end

    compact_config = CompactCheckConfig.new.compacted

    binding.pry
  end
end
