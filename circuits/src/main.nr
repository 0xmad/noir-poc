// use poll::binary_merkle_root::binary_merkle_root;
use binary_merkle_root::binary_merkle_root;
use poseidon::poseidon::bn254::{hash_2 as poseidon2, hash_3 as poseidon3};
use utils::keypair::{PrivateKey, PublicKey};

mod poll;
mod utils;

fn main(
    private_key: Field,
    voice_credits_balance: Field,
    state_root: Field,
    actual_state_tree_depth: u32,
    index: Field,
    path_elements: [Field; 10],
) -> pub PublicKey {
    let sk = PrivateKey::new(private_key);
    let pk: PublicKey = sk.into();
    let leaf = poseidon3([pk.x(), pk.y(), voice_credits_balance]);

    let root = binary_merkle_root(
        poseidon2,
        leaf,
        actual_state_tree_depth,
        index.to_le_bits(),
        path_elements,
    );

    assert(root == state_root);

    pk
}
