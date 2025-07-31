use poll::joined::poll_joined;
use utils::{bits::num_to_bits, keypair::PrivateKey};

mod poll;
mod utils;

fn main(
    private_key: Field,
    voice_credits_balance: Field,
    state_root: Field,
    actual_state_tree_depth: u32,
    index: Field,
    siblings: [Field; 10],
) {
    let secret = PrivateKey::new(private_key);

    poll_joined(
        secret,
        voice_credits_balance,
        state_root,
        actual_state_tree_depth,
        num_to_bits(index),
        siblings,
    );
}
