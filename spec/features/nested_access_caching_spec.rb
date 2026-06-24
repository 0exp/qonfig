# frozen_string_literal: true

describe 'Nested access caching (with matryoshka cache invalidation)' do
  let(:config) do
    Qonfig::DataSet.build do
      setting :a do
        setting :b do
          setting :c do
            setting :d, 1
          end
        end
      end

      setting :flat, 'value'
    end
  end

  specify 'repeated dot-notated / nested reads return the same (memoized) result' do
    expect(config['a.b.c.d']).to eq(1)
    expect(config['a.b.c.d']).to eq(1)

    nested = config['a.b.c']
    expect(nested).to be_a(Qonfig::Settings)
    # the very same nested settings instance is returned from the cache
    expect(config['a.b.c']).to equal(nested)
    expect(config.dig(:a, :b, :c)).to equal(nested)
  end

  specify 'symbol and string key variants share the cache (indifferent access)' do
    expect(config[:a][:b][:c][:d]).to eq(1)
    expect(config['a.b.c.d']).to eq(1)
    expect(config.dig('a', :b, 'c', :d)).to eq(1)
  end

  specify 'assigning a value invalidates the cache' do
    expect(config['a.b.c.d']).to eq(1)

    config['a.b.c.d'] = 2
    expect(config['a.b.c.d']).to eq(2)
  end

  specify 'mutating a nested config instance invalidates every parent cache (matryoshka)' do
    # warm up caches on every level
    expect(config['a.b.c.d']).to eq(1)
    expect(config['a.b.c']['d']).to eq(1)

    # mutate through a directly-grabbed nested instance
    nested = config['a.b.c']
    nested['d'] = 99

    # the mutation must be visible from the root through the (now stale) cache
    expect(config['a.b.c.d']).to eq(99)
    expect(config['a.b']['c.d']).to eq(99)
    expect(nested['d']).to eq(99)
  end

  specify 'a flat value mutation invalidates the cache' do
    expect(config['flat']).to eq('value')
    config['flat'] = 'changed'
    expect(config['flat']).to eq('changed')
  end

  specify '#clear! invalidates the cache' do
    expect(config['a.b.c.d']).to eq(1)
    config.clear!
    expect(config['a.b.c.d']).to be_nil
  end

  specify 'full data-set validators observe fresh values after mutation (no stale cache)' do
    validated_config = Class.new(Qonfig::DataSet) do
      setting :nested do
        setting :flag, :yes
      end

      validate { settings.nested.flag.is_a?(Symbol) }
    end

    instance = validated_config.new
    # warm the cache through the validator-read path
    expect(instance.settings.nested.flag).to eq(:yes)

    expect { instance.settings.nested.flag = 123 }.to raise_error(Qonfig::ValidationError)
  end
end
