# frozen_string_literal: true

shared_context "vault context" do
  before { allow(Vault).to receive(:logical).and_return(logical_double) }

  before { allow(Vault).to receive(:kv).and_return(kv_double) }

  let(:logical_double) { instance_double(Vault::Logical) }
  let(:kv_double) { instance_double(Vault::KV) }
end
