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

  specify 'composed nested settings invalidate the host cache on mutation' do
    shared = Class.new(Qonfig::DataSet) do
      setting :s do
        setting :v, 1
      end
    end

    host = Qonfig::DataSet.build { compose shared }

    expect(host['s.v']).to eq(1) # warm up the cache through the host
    host['s.v'] = 88
    # the nested instance was merged in "by reference"; mutating it must still
    # cascade invalidation up to the host (otherwise the host serves a stale 1)
    expect(host['s.v']).to eq(88)
  end

  specify 're-defined nested settings invalidate the cache on mutation' do
    redefined_config = Class.new(Qonfig::DataSet) do
      setting :s do
        setting :v, 1
      end

      re_setting :s do
        setting :v, 10
      end
    end

    instance = redefined_config.new

    expect(instance['s.v']).to eq(10) # warm up the cache
    instance['s.v'] = 77
    expect(instance['s.v']).to eq(77)
  end

  specify 'cache invalidation always swaps in a fresh hash, even when already empty' do
    # Guards the lock-free invalidation contract: invalidation may propagate up
    # from a nested mutation without holding our access lock, so the swap must be
    # unconditional. A `unless empty?` guard would let a concurrent reader that has
    # resolved a stale value (but not yet written it) persist that value forever.
    settings = config.settings
    empty_cache = settings.instance_variable_get(:@__deep_access_cache__)
    expect(empty_cache).to be_empty

    settings.send(:__invalidate_deep_access_cache__)

    swapped_cache = settings.instance_variable_get(:@__deep_access_cache__)
    expect(swapped_cache).to be_empty
    expect(swapped_cache).not_to equal(empty_cache)
  end
end
