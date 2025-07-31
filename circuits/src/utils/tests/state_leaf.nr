use crate::utils::{keypair::PublicKey, state_leaf::StateLeaf};

#[test]
fn test_state_leaf() {
    let public_key = PublicKey::new(0, 1);
    let state_leaf = StateLeaf::new(public_key, 100);

    let hash = state_leaf.hash();

    assert(hash == 0x0b823d5d51dadba00f873df82a384c7bbfd6ef3dc9894ec6efc30860c89a3fdd);
}

#[fuzz]
fn fuzz_state_leaf(public_key: PublicKey, voice_credits_balance: Field) {
    let state_leaf = StateLeaf::new(public_key, voice_credits_balance + 1);
    let new_state_leaf = StateLeaf::new(public_key, voice_credits_balance);

    let hash = state_leaf.hash();
    let new_hash = new_state_leaf.hash();

    assert(hash != new_hash);
}
