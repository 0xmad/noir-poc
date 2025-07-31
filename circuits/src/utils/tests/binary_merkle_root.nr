use poseidon::poseidon::bn254::hash_2 as poseidon2;

use crate::utils::{binary_merkle_root::BinaryMerkleRoot, keypair::PublicKey, state_leaf::StateLeaf};

global PUBLIC_KEY: PublicKey = PublicKey::new(
    0x106218f0c63d2e110f838b4ed6e49bdb871f55d46b9b0e5a34c2db1e4736cd10,
    0x0c850201bf0fbbf2db3922a7ecc7f1a2de96c0453802ca6e35217bd2c8a40db9,
);
global VOICE_CREDITS_BALANCE: Field = 100;
global ACTUAL_STATE_TREE_DEPTH: u32 = 6;
global EXPECTED_ROOT: Field = 0x25166ece8315f6a3b9a3be418bd225dee9c85cb35608dcee64583dcd2898267e;
global SIBLINGS: [Field; 10] = [
    0x19ce4238de2f70198652072a6fc1d13e88dbb8338091878c892cfffd95b3b870,
    0x19f9a4410e14a1b1a3a7e9b03a55c518c712fb78fd34feadebc55749d2351ac8,
    0x28f1a6f8e2afd3b4bdb2354b1878c03fbc0689f59f2506ec9c1a07f3ae43eb8e,
    0x1475250f14274b35bf6f3f21fb0b92c7429da64a16f9e14a76b42e13278671e3,
    0x16205c1b6fef76c5f3ebeeb65fb9d03870de9406b4553c230a0967e54c778236,
    0x21c60230ea583db469b0241e9b4b1fed912978ea94e8fd7943d70d66f054c850,
    0,
    0,
    0,
    0,
];

#[test]
fn test_binary_merkle_root() {
    let leaf = StateLeaf::new(PUBLIC_KEY, VOICE_CREDITS_BALANCE);
    let indices = 2.to_le_bits();
    let binary_merkle_root = BinaryMerkleRoot::new(poseidon2);

    let root = binary_merkle_root.root(leaf.hash(), ACTUAL_STATE_TREE_DEPTH, indices, SIBLINGS);

    assert(root == EXPECTED_ROOT)
}

#[test(should_fail)]
fn test_binary_merkle_root_with_invalid_indices() {
    let leaf = StateLeaf::new(PUBLIC_KEY, VOICE_CREDITS_BALANCE);
    let invalid_indices = 6.to_le_bits();
    let binary_merkle_root = BinaryMerkleRoot::new(poseidon2);

    let root =
        binary_merkle_root.root(leaf.hash(), ACTUAL_STATE_TREE_DEPTH, invalid_indices, SIBLINGS);

    assert(root == EXPECTED_ROOT)
}

#[test(should_fail)]
fn test_binary_merkle_root_with_invalid_hasher() {
    let leaf = StateLeaf::new(PUBLIC_KEY, VOICE_CREDITS_BALANCE);
    let indices = 2.to_le_bits();

    let invalid_hasher = |values: [Field; 2]| values[0] + values[1];
    let binary_merkle_root = BinaryMerkleRoot::new(invalid_hasher);

    let root = binary_merkle_root.root(leaf.hash(), ACTUAL_STATE_TREE_DEPTH, indices, SIBLINGS);

    assert(root == EXPECTED_ROOT)
}

#[test(should_fail)]
fn test_binary_merkle_root_with_invalid_state_tree_depth() {
    let leaf = StateLeaf::new(PUBLIC_KEY, VOICE_CREDITS_BALANCE);
    let invalid_depth = 20;
    let indices = 2.to_le_bits();
    let binary_merkle_root = BinaryMerkleRoot::new(poseidon2);

    let root = binary_merkle_root.root(leaf.hash(), invalid_depth, indices, SIBLINGS);

    assert(root == EXPECTED_ROOT)
}

#[test(should_fail)]
fn test_binary_merkle_root_with_invalid_leaf() {
    let indices = 2.to_le_bits();
    let binary_merkle_root = BinaryMerkleRoot::new(poseidon2);

    let root = binary_merkle_root.root(0, ACTUAL_STATE_TREE_DEPTH, indices, SIBLINGS);

    assert(root == EXPECTED_ROOT)
}

#[test(should_fail)]
fn test_binary_merkle_root_with_invalid_siblings() {
    let leaf = StateLeaf::new(PUBLIC_KEY, VOICE_CREDITS_BALANCE);
    let indices = 2.to_le_bits();
    let invalid_siblings = [
        0,
        0,
        0,
        0,
        0x1475250f14274b35bf6f3f21fb0b92c7429da64a16f9e14a76b42e13278671e3,
        0x16205c1b6fef76c5f3ebeeb65fb9d03870de9406b4553c230a0967e54c778236,
        0x19ce4238de2f70198652072a6fc1d13e88dbb8338091878c892cfffd95b3b870,
        0x19f9a4410e14a1b1a3a7e9b03a55c518c712fb78fd34feadebc55749d2351ac8,
        0x21c60230ea583db469b0241e9b4b1fed912978ea94e8fd7943d70d66f054c850,
        0x28f1a6f8e2afd3b4bdb2354b1878c03fbc0689f59f2506ec9c1a07f3ae43eb8e,
    ];
    let binary_merkle_root = BinaryMerkleRoot::new(poseidon2);

    let root =
        binary_merkle_root.root(leaf.hash(), ACTUAL_STATE_TREE_DEPTH, indices, invalid_siblings);

    assert(root == EXPECTED_ROOT)
}
