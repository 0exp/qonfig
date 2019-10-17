# frozen_string_literal: true

describe 'Has a key? (option? / setting?)' do
  specify 'setting key existence checker' do
    config = Qonfig::DataSet.build do
      setting :credentials do
        setting :user, 'D@iVeR'
        setting :password, 'test123'
      end
    end

    # root key
    expect(config.key?('credentials')).to eq(true)
    expect(config.key?(:credentials)).to eq(true)

    expect(config.option?('credentials')).to eq(true)
    expect(config.option?(:credentials)).to eq(true)

    expect(config.setting?('credentials')).to eq(true)
    expect(config.setting?(:credentials)).to eq(true)

    # deeply nested key (with mixed types of params)
    expect(config.key?('credentials', :user)).to eq(true)
    expect(config.key?(:credentials, 'user')).to eq(true)
    expect(config.key?(:credentials, :user)).to eq(true)

    expect(config.option?('credentials', :user)).to eq(true)
    expect(config.option?(:credentials, 'user')).to eq(true)
    expect(config.option?(:credentials, :user)).to eq(true)

    expect(config.setting?('credentials', :user)).to eq(true)
    expect(config.setting?(:credentials, 'user')).to eq(true)
    expect(config.setting?(:credentials, :user)).to eq(true)

    # nonexited key
    expect(config.key?(:user, :password)).to eq(false)
    expect(config.key?('options')).to eq(false)

    expect(config.option?(:user, :password)).to eq(false)
    expect(config.option?('options')).to eq(false)

    expect(config.setting?(:user, :password)).to eq(false)
    expect(config.setting?('options')).to eq(false)

    # incorrect key type
    expect { config.setting?(Object.new) }.to raise_error(Qonfig::ArgumentError)
  end
end
