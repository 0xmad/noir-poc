use super::keypair::PublicKey;
use std::hash::pedersen_hash;

pub struct StateLeaf {
    public_key: PublicKey,
    voice_credits_balance: Field,
}

impl StateLeaf {
    pub fn new(public_key: PublicKey, voice_credits_balance: Field) -> Self {
        Self { public_key, voice_credits_balance }
    }

    pub fn hash(self) -> Field {
        pedersen_hash(
            [self.public_key.x(), self.public_key.y(), self.voice_credits_balance],
        )
    }
}
