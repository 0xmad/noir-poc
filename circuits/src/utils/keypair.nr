use ec::{consts::te::baby_jubjub, tecurve::affine::Point};

pub struct PrivateKey {
    pub value: Field,
}

pub struct PublicKey {
    x: Field,
    y: Field,
}

impl PrivateKey {
    pub fn new(value: Field) -> Self {
        Self { value }
    }
}

impl PublicKey {
    pub fn new(x: Field, y: Field) -> Self {
        Self { x, y }
    }

    pub fn x(self) -> Field {
        self.x
    }

    pub fn y(self) -> Field {
        self.y
    }
}

impl From<PrivateKey> for PublicKey {
    fn from(input: PrivateKey) -> Self {
        let bjj = baby_jubjub();

        assert(input.value.lt(bjj.suborder), "Private key must be less than the subgroup order");

        bjj.curve.mul(input.value, bjj.base8).into()
    }
}

impl From<Point> for PublicKey {
    fn from(input: Point) -> Self {
        Self { x: input.x, y: input.y }
    }
}

impl Eq for PrivateKey {
    fn eq(self, other: Self) -> bool {
        self.value == other.value
    }
}

impl Eq for PublicKey {
    fn eq(self, other: Self) -> bool {
        [self.x, self.y] == [other.x, other.y]
    }
}
