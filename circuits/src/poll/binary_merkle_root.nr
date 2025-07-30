pub fn binary_merkle_root<let MAX_DEPTH: u32>(
    hasher: fn([Field; 2]) -> Field,
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
        let selector = Field::from(depth == i);
        root += selector * node;
        let sibling = siblings[i];

        let (left, right) = if indices[i] == 0 {
            (node, sibling)
        } else {
            (sibling, node)
        };

        node = hasher([left, right]);
    }

    let selector = Field::from(depth == MAX_DEPTH);
    root + selector * node
}
