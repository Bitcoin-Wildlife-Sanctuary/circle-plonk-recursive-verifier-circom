pragma circom 2.0.0;

include "bits.circom";

template test_check_num_bits() {
    signal input a22;
    signal input a23;
    signal input a15;

    component a22_check = check_num_bits(22);
    a22_check.a <== a22;

    component a23_check = check_num_bits(23);
    a23_check.a <== a23;

    component a15_check = check_num_bits(15);
    a15_check.a <== a15;

    signal input in_a;
    signal input out_low;

    component low_check = get_lower_bits_checked(18);
    low_check.in <== in_a;
    low_check.out === out_low;
}

component main = test_check_num_bits();