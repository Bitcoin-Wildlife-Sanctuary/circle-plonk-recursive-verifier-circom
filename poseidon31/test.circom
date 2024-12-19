pragma circom 2.0.0;
include "poseidon31_permute.circom";

template test_poseidon31_permute() {
    signal input in[16];
    signal input out[16];

    signal tmp[16];

    component s1 = poseidon31_permute();

    for(var i = 0; i < 16; i++) {
        s1.in[i] <== in[i];
    }

    component s2 = poseidon31_permute();
    for(var i = 0; i < 16; i++) {
        s2.in[i] <== s1.out[i];
    }

    for(var i = 0; i < 16; i++) {
        s2.out[i] === out[i];
    }
}

component main { public [in, out] } = test_poseidon31_permute();