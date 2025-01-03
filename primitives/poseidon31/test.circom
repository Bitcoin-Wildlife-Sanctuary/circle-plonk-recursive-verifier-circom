pragma circom 2.0.0;
include "poseidon31_permute.circom";

template test_poseidon31_permute() {
    signal input in[16];
    signal input out[16];

    signal tmp[16];

    component s1 = poseidon31_permute();
    s1.in <== in;

    component s2 = poseidon31_permute();
    s2.in <== s1.out;
    s2.out === out;
}

component main = test_poseidon31_permute();