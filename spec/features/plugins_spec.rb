# frozen_string_literal: true

describe 'Plugins' do
  specify 'currently registered plugins' do
    expect(Qonfig.plugins).to contain_exactly('rails')
  end
end
