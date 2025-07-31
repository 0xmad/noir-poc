use crate::utils::bits::{bits_to_num, num_to_bits};

#[fuzz]
fn fuzz_bits(number: Field) {
    let bits: [u1; 254] = num_to_bits(number);
    let result = bits_to_num(bits);

    assert(number == result);
}

#[test]
fn test_bits() {
    let number = 9000;
    let bits: [u1; 254] = num_to_bits(number);
    let result = bits_to_num(bits);

    assert(result == number);
}
