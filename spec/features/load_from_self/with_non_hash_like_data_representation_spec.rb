# frozen_string_literal: true

describe 'Load from self (non-hash-like __END__ data representation)' do
  specify 'fails when yaml data is not represented as a hash' do
    class IncompatibleSelfDataConfig < Qonfig::DataSet
      load_from_self
    end

    expect { IncompatibleSelfDataConfig.new }.to raise_error(Qonfig::IncompatibleYAMLStructureError)
  end
end

__END__

- user
- password
- 123
