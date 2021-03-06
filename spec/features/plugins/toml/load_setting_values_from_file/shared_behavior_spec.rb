# frozen_string_literal: true

describe 'Plugin(:toml) .values_file / #load_from_file (shared behavior)', plugin: :toml do
  describe 'unsupported format failures' do
    describe 'DSL macros' do
      specify 'fails on unsupported format' do
        expect do
          Qonfig::DataSet.build do
            values_file :self
          end
        end.to raise_error(Qonfig::DynamicLoaderParseError)
      end
    end

    describe 'Instance method' do
      specify 'fails on unsupported format' do
        expect do
          Qonfig::DataSet.build.load_from_self
        end.to raise_error(Qonfig::DynamicLoaderParseError)
      end
    end
  end
end

__END__

user: 0exp
ASDF|"asSDF"
[test]
<xml>
  <data>
    <key>123</key>
  </data>
</xml>
