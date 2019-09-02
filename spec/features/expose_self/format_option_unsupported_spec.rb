# frozen_string_literal: true

describe '#expose_self => format: <unsupported>' do
  specify 'fails on unsupported formats' do
    expect do
      Class.new(Qonfig::DataSet) do
        expose_self env: :production, format: :atata
      end
    end.to raise_error(Qonfig::UnsupportedLoaderFormatError)
  end

  specify 'fails on empty format parameter' do
    expect do
      Class.new(Qonfig::DataSet) do
        expose_self env: :production, format: ''
      end
    end.to raise_error(Qonfig::UnsupportedLoaderFormatError)
  end

  specify 'fails on incorrect format parameter' do
    expect do
      Class.new(Qonfig::DataSet) do
        expose_self env: :production, format: Object.new
      end
    end.to raise_error(Qonfig::ArgumentError)
  end
end
