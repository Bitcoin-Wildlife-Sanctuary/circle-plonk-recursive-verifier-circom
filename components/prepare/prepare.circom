pragma circom 2.0.0;

include "constraint_denom.circom";
include "constraint_num.circom";
include "pair_vanishing.circom";
include "column_line_coeffs.circom";

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

    component column_c = compute_column_line_coeffs();
    column_c.oods_y <== oods_point_y;
    column_c.oods_shifted_y <== pair_vanishing.oods_shifted_y;

    signal input sampled_value_trace_a_val[4];
    signal input sampled_value_trace_b_val[4];
    signal input sampled_value_trace_c_val[4];
    signal input sampled_value_interaction_ab_0[4];
    signal input sampled_value_interaction_ab_1[4];
    signal input sampled_value_interaction_ab_2[4];
    signal input sampled_value_interaction_ab_3[4];
    signal input sampled_value_interaction_sum_0[4];
    signal input sampled_value_interaction_sum_1[4];
    signal input sampled_value_interaction_sum_2[4];
    signal input sampled_value_interaction_sum_3[4];
    signal input sampled_value_interaction_shifted_sum_0[4];
    signal input sampled_value_interaction_shifted_sum_1[4];
    signal input sampled_value_interaction_shifted_sum_2[4];
    signal input sampled_value_interaction_shifted_sum_3[4];
    signal input sampled_value_constant_mult[4];
    signal input sampled_value_constant_a_wire[4];
    signal input sampled_value_constant_b_wire[4];
    signal input sampled_value_constant_c_wire[4];
    signal input sampled_value_constant_op[4];
    signal input sampled_value_composition_0[4];
    signal input sampled_value_composition_1[4];
    signal input sampled_value_composition_2[4];
    signal input sampled_value_composition_3[4];

    column_c.trace_a_val <== sampled_value_trace_a_val;
    column_c.trace_b_val <== sampled_value_trace_b_val;
    column_c.trace_c_val <== sampled_value_trace_c_val;
    column_c.interaction_ab_0 <== sampled_value_interaction_ab_0;
    column_c.interaction_ab_1 <== sampled_value_interaction_ab_1;
    column_c.interaction_ab_2 <== sampled_value_interaction_ab_2;
    column_c.interaction_ab_3 <== sampled_value_interaction_ab_3;
    column_c.interaction_sum_0 <== sampled_value_interaction_sum_0;
    column_c.interaction_sum_1 <== sampled_value_interaction_sum_1;
    column_c.interaction_sum_2 <== sampled_value_interaction_sum_2;
    column_c.interaction_sum_3 <== sampled_value_interaction_sum_3;
    column_c.interaction_shifted_sum_0 <== sampled_value_interaction_shifted_sum_0;
    column_c.interaction_shifted_sum_1 <== sampled_value_interaction_shifted_sum_1;
    column_c.interaction_shifted_sum_2 <== sampled_value_interaction_shifted_sum_2;
    column_c.interaction_shifted_sum_3 <== sampled_value_interaction_shifted_sum_3;
    column_c.constant_mult <== sampled_value_constant_mult;
    column_c.constant_a_wire <== sampled_value_constant_a_wire;
    column_c.constant_b_wire <== sampled_value_constant_b_wire;
    column_c.constant_c_wire <== sampled_value_constant_c_wire;
    column_c.constant_op <== sampled_value_constant_op;
    column_c.composition_0 <== sampled_value_composition_0;
    column_c.composition_1 <== sampled_value_composition_1;
    column_c.composition_2 <== sampled_value_composition_2;
    column_c.composition_3 <== sampled_value_composition_3;

    signal input trace_column_line_coeffs_a[6];
    signal input trace_column_line_coeffs_b[6];
    for(var i = 0; i < 3; i++) {
        column_c.trace_column_line_coeffs_a[i][0] === trace_column_line_coeffs_a[i * 2];
        column_c.trace_column_line_coeffs_a[i][1] === trace_column_line_coeffs_a[i * 2 + 1];
        column_c.trace_column_line_coeffs_b[i][0] === trace_column_line_coeffs_b[i * 2];
        column_c.trace_column_line_coeffs_b[i][1] === trace_column_line_coeffs_b[i * 2 + 1];
    }

    signal input interaction_column_line_coeffs_a[16];
    signal input interaction_column_line_coeffs_b[16];
    for(var i = 0; i < 8; i++) {
        column_c.interaction_column_line_coeffs_a[i][0] === interaction_column_line_coeffs_a[i * 2];
        column_c.interaction_column_line_coeffs_a[i][1] === interaction_column_line_coeffs_a[i * 2 + 1];
        column_c.interaction_column_line_coeffs_b[i][0] === interaction_column_line_coeffs_b[i * 2];
        column_c.interaction_column_line_coeffs_b[i][1] === interaction_column_line_coeffs_b[i * 2 + 1];
    }

    signal input interaction_shifted_column_line_coeffs_a[8];
    signal input interaction_shifted_column_line_coeffs_b[8];
    for(var i = 0; i < 4; i++) {
        column_c.interaction_shifted_column_line_coeffs_a[i][0] === interaction_shifted_column_line_coeffs_a[i * 2];
        column_c.interaction_shifted_column_line_coeffs_a[i][1] === interaction_shifted_column_line_coeffs_a[i * 2 + 1];
        column_c.interaction_shifted_column_line_coeffs_b[i][0] === interaction_shifted_column_line_coeffs_b[i * 2];
        column_c.interaction_shifted_column_line_coeffs_b[i][1] === interaction_shifted_column_line_coeffs_b[i * 2 + 1];
    }

    signal input constant_column_line_coeffs_a[10];
    signal input constant_column_line_coeffs_b[10];
    for(var i = 0; i < 5; i++) {
        column_c.constant_column_line_coeffs_a[i][0] === constant_column_line_coeffs_a[i * 2];
        column_c.constant_column_line_coeffs_a[i][1] === constant_column_line_coeffs_a[i * 2 + 1];
        column_c.constant_column_line_coeffs_b[i][0] === constant_column_line_coeffs_b[i * 2];
        column_c.constant_column_line_coeffs_b[i][1] === constant_column_line_coeffs_b[i * 2 + 1];
    }

    signal input composition_column_line_coeffs_a[8];
    signal input composition_column_line_coeffs_b[8];
    for(var i = 0; i < 4; i++) {
        column_c.composition_column_line_coeffs_a[i][0] === composition_column_line_coeffs_a[i * 2];
        column_c.composition_column_line_coeffs_a[i][1] === composition_column_line_coeffs_a[i * 2 + 1];
        column_c.composition_column_line_coeffs_b[i][0] === composition_column_line_coeffs_b[i * 2];
        column_c.composition_column_line_coeffs_b[i][1] === composition_column_line_coeffs_b[i * 2 + 1];
    }
}

component main = test_prepare();