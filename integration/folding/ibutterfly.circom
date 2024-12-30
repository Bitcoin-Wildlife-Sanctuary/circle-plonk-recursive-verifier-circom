pragma circom 2.0.0;

include "../../primitives/circle/fields.circom";

template ibutterfly() {
    signal input v0[4];
    signal input v1[4];
    signal input itwid;

    component new_v0_c = qm31_add();
    new_v0_c.a <== v0;
    new_v0_c.b <== v1;

    component diff = qm31_sub();
    diff.a <== v0;
    diff.b <== v1;

    component new_v1_c = qm31_mul_m31();
    new_v1_c.a <== diff.out;
    new_v1_c.b <== itwid;

    signal output new_v0[4];
    signal output new_v1[4];

    new_v0 <== new_v0_c.out;
    new_v1 <== new_v1_c.out;
}