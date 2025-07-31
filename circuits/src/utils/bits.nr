pub fn num_to_bits<let N: u32>(number: Field) -> [u1; N] {
    let mut sum: Field = 0;
    let mut power_of_two: Field = 1;
    let bits = number.to_le_bits::<N>();

    for index in 0..N {
        assert(bits[index] * (1 - bits[index]) == 0);

        sum += if bits[index] == 1 { power_of_two } else { 0 };
        power_of_two = power_of_two + power_of_two;
    }

    assert(sum == number);

    bits
}

pub fn bits_to_num<let N: u32>(bits: [u1; N]) -> Field {
    let mut number: Field = 0;
    let mut power_of_two: Field = 1;

    for index in 0..N {
        assert(bits[index] * (1 - bits[index]) == 0);

        number += if bits[index] == 1 { power_of_two } else { 0 };
        power_of_two = power_of_two + power_of_two;
    }

    number
}
