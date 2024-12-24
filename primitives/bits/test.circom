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
}

component main { public [a22, a23, a15] } = test_check_num_bits();