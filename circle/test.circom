pragma circom 2.0.0;
include "fields.circom";

template test_fields() {
    signal input a[4];
    signal input b[4];
    signal input a_plus_b[4];
    signal input a_minus_b[4];
    signal input a_times_b[4];
    signal input a_inv[4];
    signal input a_square[4];

    component s1 = qm31_add();
    for(var i = 0; i < 4; i++) {
        s1.a[i] <== a[i];
        s1.b[i] <== b[i];
    }
    for(var i = 0; i < 4; i++) {
        s1.out[i] === a_plus_b[i];
    }

    component s2 = qm31_sub();
    for(var i = 0; i < 4; i++) {
        s2.a[i] <== a[i];
        s2.b[i] <== b[i];
    }
    for(var i = 0; i < 4; i++) {
        s2.out[i] === a_minus_b[i];
    }

    component s3 = qm31_mul();
    for(var i = 0; i < 4; i++) {
        s3.a[i] <== a[i];
        s3.b[i] <== b[i];
    }
    for(var i = 0; i < 4; i++) {
        s3.out[i] === a_times_b[i];
    }

    component s4 = qm31_inv();
    for(var i = 0; i < 4; i++) {
        s4.a[i] <== a[i];
    }
    for(var i = 0; i < 4; i++) {
        s4.out[i] === a_inv[i];
    }

    component s5 = qm31_mul();
    for(var i = 0; i < 4; i++) {
        s5.a[i] <== a[i];
        s5.b[i] <== a[i];
    }
    for(var i = 0; i < 4; i++) {
        s5.out[i] === a_square[i];
    }
}

component main { public [a, b, a_plus_b, a_minus_b, a_times_b, a_inv, a_square] } = test_fields();