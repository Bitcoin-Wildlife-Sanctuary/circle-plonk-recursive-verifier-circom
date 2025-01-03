pragma circom 2.0.0;

include "constraint_denom.circom";
include "constraint_num.circom";
include "pair_vanishing.circom";
include "column_line_coeffs.circom";

template prepare(N) {
    signal input sampled_value_trace[12];
    signal input sampled_value_interaction[32];
    signal input sampled_value_interaction_shifted[16];
    signal input sampled_value_constant[20];
    signal input sampled_value_composition[16];

    signal input alpha[4];
    signal input z[4];
    signal input random_coeff[4];

    signal input claimed_sum[4];
    signal output constraint_num[4];

    component constraint_num_c = compute_constraint_num();
    constraint_num_c.alpha <== alpha;
    constraint_num_c.z <== z;
    constraint_num_c.random_coeff <== random_coeff;
    for(var i = 0; i < 4; i++) {
        constraint_num_c.a_val[i] <== sampled_value_trace[i];
        constraint_num_c.b_val[i] <== sampled_value_trace[i + 4];
        constraint_num_c.c_val[i] <== sampled_value_trace[i + 8];
        constraint_num_c.mult[i] <== sampled_value_constant[i];
        constraint_num_c.a_wire[i] <== sampled_value_constant[i + 4];
        constraint_num_c.b_wire[i] <== sampled_value_constant[i + 8];
        constraint_num_c.c_wire[i] <== sampled_value_constant[i + 12];
        constraint_num_c.op[i] <== sampled_value_constant[i + 16];
        constraint_num_c.a_b_logup_0[i] <== sampled_value_interaction[i];
        constraint_num_c.a_b_logup_1[i] <== sampled_value_interaction[i + 4];
        constraint_num_c.a_b_logup_2[i] <== sampled_value_interaction[i + 8];
        constraint_num_c.a_b_logup_3[i] <== sampled_value_interaction[i + 12];
        constraint_num_c.c_logup_0[i] <== sampled_value_interaction[i + 16];
        constraint_num_c.c_logup_1[i] <== sampled_value_interaction[i + 20];
        constraint_num_c.c_logup_2[i] <== sampled_value_interaction[i + 24];
        constraint_num_c.c_logup_3[i] <== sampled_value_interaction[i + 28];
        constraint_num_c.c_logup_next_0[i] <== sampled_value_interaction_shifted[i];
        constraint_num_c.c_logup_next_1[i] <== sampled_value_interaction_shifted[i + 4];
        constraint_num_c.c_logup_next_2[i] <== sampled_value_interaction_shifted[i + 8];
        constraint_num_c.c_logup_next_3[i] <== sampled_value_interaction_shifted[i + 12];
    }
    constraint_num_c.claimed_sum <== claimed_sum;

    constraint_num <== constraint_num_c.out;

    signal input oods_point_x[4];
    signal input oods_point_y[4];
    signal output constraint_denom[4];

    component constraint_denom_c = compute_constraint_denom(N);
    constraint_denom_c.x <== oods_point_x;

    constraint_denom <== constraint_denom_c.out;

    component pair_vanishing = prepare_pair_vanishing();
    pair_vanishing.oods_x <== oods_point_x;
    pair_vanishing.oods_y <== oods_point_y;

    signal output oods_a[2];
    signal output oods_b[2];
    signal output oods_shifted_a[2];
    signal output oods_shifted_b[2];

    oods_a <== pair_vanishing.oods_pair_vanishing_a;
    oods_b <== pair_vanishing.oods_pair_vanishing_b;
    oods_shifted_a <== pair_vanishing.oods_shifted_pair_vanishing_a;
    oods_shifted_b <== pair_vanishing.oods_shifted_pair_vanishing_b;

    component column_c = compute_column_line_coeffs();
    column_c.oods_y <== oods_point_y;
    column_c.oods_shifted_y <== pair_vanishing.oods_shifted_y;

    for(var i = 0; i < 4; i++) {
        column_c.trace_a_val[i] <== sampled_value_trace[i];
        column_c.trace_b_val[i] <== sampled_value_trace[i + 4];
        column_c.trace_c_val[i] <== sampled_value_trace[i + 8];
        column_c.interaction_ab_0[i] <== sampled_value_interaction[i];
        column_c.interaction_ab_1[i] <== sampled_value_interaction[i + 4];
        column_c.interaction_ab_2[i] <== sampled_value_interaction[i + 8];
        column_c.interaction_ab_3[i] <== sampled_value_interaction[i + 12];
        column_c.interaction_sum_0[i] <== sampled_value_interaction[i + 16];
        column_c.interaction_sum_1[i] <== sampled_value_interaction[i + 20];
        column_c.interaction_sum_2[i] <== sampled_value_interaction[i + 24];
        column_c.interaction_sum_3[i] <== sampled_value_interaction[i + 28];
        column_c.interaction_shifted_sum_0[i] <== sampled_value_interaction_shifted[i];
        column_c.interaction_shifted_sum_1[i] <== sampled_value_interaction_shifted[i + 4];
        column_c.interaction_shifted_sum_2[i] <== sampled_value_interaction_shifted[i + 8];
        column_c.interaction_shifted_sum_3[i] <== sampled_value_interaction_shifted[i + 12];
        column_c.constant_mult[i] <== sampled_value_constant[i];
        column_c.constant_a_wire[i] <== sampled_value_constant[i + 4];
        column_c.constant_b_wire[i] <== sampled_value_constant[i + 8];
        column_c.constant_c_wire[i] <== sampled_value_constant[i + 12];
        column_c.constant_op[i] <== sampled_value_constant[i + 16];
        column_c.composition_0[i] <== sampled_value_composition[i];
        column_c.composition_1[i] <== sampled_value_composition[i + 4];
        column_c.composition_2[i] <== sampled_value_composition[i + 8];
        column_c.composition_3[i] <== sampled_value_composition[i + 12];
    }

    signal output coeffs_trace_a[6];
    signal output coeffs_trace_b[6];
    for(var i = 0; i < 3; i++) {
        coeffs_trace_a[i * 2] <== column_c.trace_column_line_coeffs_a[i][0];
        coeffs_trace_a[i * 2 + 1] <== column_c.trace_column_line_coeffs_a[i][1];
        coeffs_trace_b[i * 2] <== column_c.trace_column_line_coeffs_b[i][0];
        coeffs_trace_b[i * 2 + 1] <== column_c.trace_column_line_coeffs_b[i][1];
    }

    signal output coeffs_interaction_a[16];
    signal output coeffs_interaction_b[16];
    for(var i = 0; i < 8; i++) {
        coeffs_interaction_a[i * 2] <== column_c.interaction_column_line_coeffs_a[i][0];
        coeffs_interaction_a[i * 2 + 1] <== column_c.interaction_column_line_coeffs_a[i][1];
        coeffs_interaction_b[i * 2] <== column_c.interaction_column_line_coeffs_b[i][0];
        coeffs_interaction_b[i * 2 + 1] <== column_c.interaction_column_line_coeffs_b[i][1];
    }

    signal output coeffs_interaction_shifted_a[8];
    signal output coeffs_interaction_shifted_b[8];
    for(var i = 0; i < 4; i++) {
        coeffs_interaction_shifted_a[i * 2] <== column_c.interaction_shifted_column_line_coeffs_a[i][0];
        coeffs_interaction_shifted_a[i * 2 + 1] <== column_c.interaction_shifted_column_line_coeffs_a[i][1];
        coeffs_interaction_shifted_b[i * 2] <== column_c.interaction_shifted_column_line_coeffs_b[i][0];
        coeffs_interaction_shifted_b[i * 2 + 1] <== column_c.interaction_shifted_column_line_coeffs_b[i][1];
    }

    signal output coeffs_constant_a[10];
    signal output coeffs_constant_b[10];
    for(var i = 0; i < 5; i++) {
        coeffs_constant_a[i * 2] <== column_c.constant_column_line_coeffs_a[i][0];
        coeffs_constant_a[i * 2 + 1] <== column_c.constant_column_line_coeffs_a[i][1];
        coeffs_constant_b[i * 2] <== column_c.constant_column_line_coeffs_b[i][0];
        coeffs_constant_b[i * 2 + 1] <== column_c.constant_column_line_coeffs_b[i][1];
    }

    signal output coeffs_composition_a[8];
    signal output coeffs_composition_b[8];
    for(var i = 0; i < 4; i++) {
        coeffs_composition_a[i * 2] <== column_c.composition_column_line_coeffs_a[i][0];
        coeffs_composition_a[i * 2 + 1] <== column_c.composition_column_line_coeffs_a[i][1];
        coeffs_composition_b[i * 2] <== column_c.composition_column_line_coeffs_b[i][0];
        coeffs_composition_b[i * 2 + 1] <== column_c.composition_column_line_coeffs_b[i][1];
    }
}