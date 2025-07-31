type Hasher = fn([Field; 2]) -> Field;

pub struct BinaryMerkleRoot {
    hasher: Hasher,
}

impl BinaryMerkleRoot {
    pub fn new(hasher: Hasher) -> Self {
        Self { hasher }
    }

    pub fn root<let MAX_DEPTH: u32>(
        self,
        leaf: Field,
        depth: u32,
        indices: [u1; MAX_DEPTH],
        siblings: [Field; MAX_DEPTH],
    ) -> Field {
        // Start from the leaf node
        let mut node = leaf;
        let mut root = 0;

        // Iterate through the Merkle proof up to MAX_DEPTH
        for i in 0..MAX_DEPTH {
            let sibling = siblings[i];
            let value = if depth == i { node } else { 0 };
            root += value;

            let (left, right) = if indices[i] == 0 {
                (node, sibling)
            } else {
                (sibling, node)
            };

            node = (self.hasher)([left, right]);
        }

        let value = if depth == MAX_DEPTH { node } else { 0 };

        root + value
    }
}
