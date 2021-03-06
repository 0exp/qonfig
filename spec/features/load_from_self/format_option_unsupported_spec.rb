# frozen_string_literal: true

describe '#load_from_self => format: <unsupported>' do
  specify 'fails on unsupported formats' do
    expect do
      Class.new(Qonfig::DataSet) do
        load_from_self format: :atata
      end
    end.to raise_error(Qonfig::UnsupportedLoaderFormatError)
  end

  specify 'fails on empty format parameter' do
    expect do
      Class.new(Qonfig::DataSet) do
        load_from_self format: ''
      end
    end.to raise_error(Qonfig::UnsupportedLoaderFormatError)
  end

  specify 'fails on incorrect format parameter' do
    expect do
      Class.new(Qonfig::DataSet) do
        load_from_self format: Object.new
      end
    end.to raise_error(Qonfig::ArgumentError)
  end
end
