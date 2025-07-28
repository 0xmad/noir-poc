fn main(age: u8) {
    assert(age >= 18);
}

#[test]
fn test_main() {
    main(18);
}

#[test(should_fail)]
fn test_main_fail() {
    main(11);
}
