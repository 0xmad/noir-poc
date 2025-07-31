use poseidon::poseidon::bn254::hash_2 as poseidon2;

use crate::utils::{
    binary_merkle_root::BinaryMerkleRoot,
    keypair::{PrivateKey, PublicKey},
    state_leaf::StateLeaf,
};

pub fn poll_joined<let STATE_TREE_DEPTH: u32>(
    private_key: PrivateKey,
    voice_credits_balance: Field,
    state_root: Field,
    actual_state_tree_depth: u32,
    indices: [u1; STATE_TREE_DEPTH],
    siblings: [Field; STATE_TREE_DEPTH],
) {
    assert(STATE_TREE_DEPTH >= actual_state_tree_depth);

    let public_key: PublicKey = private_key.into();

    let leaf = StateLeaf::new(public_key, voice_credits_balance);
    let binary_merkle_root = BinaryMerkleRoot::new(poseidon2);

    let root = binary_merkle_root.root(leaf.hash(), actual_state_tree_depth, indices, siblings);

    assert(state_root == root);
}
