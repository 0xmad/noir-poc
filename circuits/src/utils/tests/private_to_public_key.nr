use crate::utils::keypair::{PrivateKey, PublicKey};
use ec::consts::te::baby_jubjub;

#[fuzz]
fn convert_private_key_to_public(value: Field) {
    let bjj = baby_jubjub();

    if !value.lt(bjj.suborder) {
        assert(true);
    } else {
        let private_key = PrivateKey::new(value);
        let public_key: PublicKey = private_key.into();
        let point = bjj.curve.mul(value, bjj.base8);

        assert(public_key == point.into());
    }
}

#[fuzz(should_fail_with = "Private key must be less than the subgroup order")]
fn convert_suborder_private_key_to_public(value: Field) {
    let bjj = baby_jubjub();

    if !value.lt(bjj.suborder) {
        let private_key = PrivateKey::new(value);
        let public_key: PublicKey = private_key.into();
        let point = bjj.curve.mul(value, bjj.base8);

        assert(public_key == point.into());
    } else {
        assert(false, "Private key must be less than the subgroup order");
    }
}

#[test]
fn convert_zero_private_key_to_public() {
    let private_key = PrivateKey::new(0);
    let public_key = private_key.into();
    let expected_public_key = PublicKey::new(0, 1);

    assert(public_key == expected_public_key)
}

#[test(should_fail_with = "Private key must be less than the subgroup order")]
fn covert_suborder_private_key_to_public() {
    let private_key = PrivateKey::new(
        0x061440c488e21a7f4daefea521872cbeab89f8efd244c8a00fa902a8b98d44ad,
    );

    let _: PublicKey = private_key.into();
}
