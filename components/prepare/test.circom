pragma circom 2.0.0;

include "prepare.circom";

template test_prepare(N) {
    signal input sampled_value_trace[12];
    signal input sampled_value_interaction[32];
    signal input sampled_value_interaction_shifted[16];
    signal input sampled_value_constant[20];
    signal input sampled_value_composition[16];

    signal input alpha[4];
    signal input z[4];
    signal input random_coeff[4];

    signal input claimed_sum[4];

    signal input oods_point_x[4];
    signal input oods_point_y[4];

    component prepare = prepare(N);
    prepare.sampled_value_trace <== sampled_value_trace;
    prepare.sampled_value_interaction <== sampled_value_interaction;
    prepare.sampled_value_interaction_shifted <== sampled_value_interaction_shifted;
    prepare.sampled_value_constant <== sampled_value_constant;
    prepare.sampled_value_composition <== sampled_value_composition;

    prepare.alpha <== alpha;
    prepare.z <== z;
    prepare.random_coeff <== random_coeff;

    prepare.claimed_sum <== claimed_sum;
    prepare.oods_point_x <== oods_point_x;
    prepare.oods_point_y <== oods_point_y;

    signal input constraint_num[4];
    signal input constraint_denom[4];

    signal input coeffs_trace_a[6];
    signal input coeffs_trace_b[6];

    signal input coeffs_interaction_a[16];
    signal input coeffs_interaction_b[16];

    signal input coeffs_interaction_shifted_a[8];
    signal input coeffs_interaction_shifted_b[8];

    signal input coeffs_constant_a[10];
    signal input coeffs_constant_b[10];

    signal input coeffs_composition_a[8];
    signal input coeffs_composition_b[8];

    signal input oods_a[2];
    signal input oods_b[2];
    signal input oods_shifted_a[2];
    signal input oods_shifted_b[2];

    constraint_num === prepare.constraint_num;
    constraint_denom === prepare.constraint_denom;
    coeffs_trace_a === prepare.coeffs_trace_a;
    coeffs_trace_b === prepare.coeffs_trace_b;
    coeffs_interaction_a === prepare.coeffs_interaction_a;
    coeffs_interaction_b === prepare.coeffs_interaction_b;
    coeffs_interaction_shifted_a === prepare.coeffs_interaction_shifted_a;
    coeffs_interaction_shifted_b === prepare.coeffs_interaction_shifted_b;
    coeffs_constant_a === prepare.coeffs_constant_a;
    coeffs_constant_b === prepare.coeffs_constant_b;
    coeffs_composition_a === prepare.coeffs_composition_a;
    coeffs_composition_b === prepare.coeffs_composition_b;

    oods_a === prepare.oods_a;
    oods_b === prepare.oods_b;
    oods_shifted_a === prepare.oods_shifted_a;
    oods_shifted_b === prepare.oods_shifted_b;
}

component main = test_prepare(13);