pragma circom 2.0.0;

include "constraint_denom.circom";
include "constraint_num.circom";
include "pair_vanishing.circom";

template test_prepare() {
    signal input a_val[4];
    signal input b_val[4];
    signal input c_val[4];
    signal input op[4];
    signal input random_coeff[4];

    signal input a_wire[4];
    signal input b_wire[4];
    signal input alpha[4];
    signal input z[4];
    signal input a_b_logup_0[4];
    signal input a_b_logup_1[4];
    signal input a_b_logup_2[4];
    signal input a_b_logup_3[4];

    signal input c_wire[4];
    signal input c_logup_0[4];
    signal input c_logup_1[4];
    signal input c_logup_2[4];
    signal input c_logup_3[4];
    signal input c_logup_next_0[4];
    signal input c_logup_next_1[4];
    signal input c_logup_next_2[4];
    signal input c_logup_next_3[4];

    signal input claimed_sum[4];
    signal input mult[4];

    signal input constraint_num[4];

    component constraint_num_c = compute_constraint_num();
    constraint_num_c.a_val <== a_val;
    constraint_num_c.b_val <== b_val;
    constraint_num_c.c_val <== c_val;
    constraint_num_c.op <== op;
    constraint_num_c.random_coeff <== random_coeff;
    constraint_num_c.a_wire <== a_wire;
    constraint_num_c.b_wire <== b_wire;
    constraint_num_c.alpha <== alpha;
    constraint_num_c.z <== z;
    constraint_num_c.a_b_logup_0 <== a_b_logup_0;
    constraint_num_c.a_b_logup_1 <== a_b_logup_1;
    constraint_num_c.a_b_logup_2 <== a_b_logup_2;
    constraint_num_c.a_b_logup_3 <== a_b_logup_3;
    constraint_num_c.c_wire <== c_wire;
    constraint_num_c.c_logup_0 <== c_logup_0;
    constraint_num_c.c_logup_1 <== c_logup_1;
    constraint_num_c.c_logup_2 <== c_logup_2;
    constraint_num_c.c_logup_3 <== c_logup_3;
    constraint_num_c.c_logup_next_0 <== c_logup_next_0;
    constraint_num_c.c_logup_next_1 <== c_logup_next_1;
    constraint_num_c.c_logup_next_2 <== c_logup_next_2;
    constraint_num_c.c_logup_next_3 <== c_logup_next_3;
    constraint_num_c.claimed_sum <== claimed_sum;
    constraint_num_c.mult <== mult;

    constraint_num === constraint_num_c.out;

    signal input oods_point_x[4];
    signal input oods_point_y[4];
    signal input constraint_denom[4];

    component constraint_denom_c = compute_constraint_denom(13);
    constraint_denom_c.x <== oods_point_x;

    constraint_denom === constraint_denom_c.out;

    component pair_vanishing = prepare_pair_vanishing();
    pair_vanishing.oods_x <== oods_point_x;
    pair_vanishing.oods_y <== oods_point_y;

    signal input oods_a[2];
    signal input oods_b[2];
    signal input oods_shifted_a[2];
    signal input oods_shifted_b[2];

    oods_a === pair_vanishing.oods_pair_vanishing_a;
    oods_b === pair_vanishing.oods_pair_vanishing_b;
    oods_shifted_a === pair_vanishing.oods_shifted_pair_vanishing_a;
    oods_shifted_b === pair_vanishing.oods_shifted_pair_vanishing_b;
}

component main { public [
    a_val, b_val, c_val, op, random_coeff, a_wire, b_wire,
    alpha, z, a_b_logup_0, a_b_logup_1, a_b_logup_2, a_b_logup_3,
    c_wire, c_logup_0, c_logup_1, c_logup_2, c_logup_3, c_logup_next_0,
    c_logup_next_1, c_logup_next_2, c_logup_next_3, claimed_sum, mult,
    constraint_num, oods_point_x, oods_point_y, constraint_denom,
    oods_a, oods_b, oods_shifted_a, oods_shifted_b
] } = test_prepare();