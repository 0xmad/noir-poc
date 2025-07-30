use poseidon::poseidon::bn254::hash_2 as poseidon2;

use crate::utils::{keypair::{PrivateKey, PublicKey}, state_leaf::StateLeaf};
use super::binary_merkle_root::binary_merkle_root;

pub fn poll_joined<let STATE_TREE_DEPTH: u32>(
    private_key: PrivateKey,
    voice_credits_balance: Field,
    state_root: Field,
    actual_state_tree_depth: u32,
    indices: [u1; STATE_TREE_DEPTH],
    path_elements: [Field; STATE_TREE_DEPTH],
) {
    assert(STATE_TREE_DEPTH >= actual_state_tree_depth);

    let public_key: PublicKey = private_key.into();

    let leaf = StateLeaf::new(public_key, voice_credits_balance);
    let root = binary_merkle_root(
        poseidon2,
        leaf.hash(),
        actual_state_tree_depth,
        indices,
        path_elements,
    );

    assert(state_root == root);
}
