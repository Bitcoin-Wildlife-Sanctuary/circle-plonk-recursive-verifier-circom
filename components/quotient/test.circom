pragma circom 2.0.0;

include "quotient.circom";

template test_quotient(N, L) {
    signal input query;

    signal input trace_l[3];
    signal input trace_r[3];

    signal input interaction_l[8];
    signal input interaction_r[8];

    signal input constant_l[5];
    signal input constant_r[5];

    signal input composition_l[4];
    signal input composition_r[4];

    signal input coeffs_trace_a[6];
    signal input coeffs_trace_b[6];

    signal input coeffs_interaction_a[16];
    signal input coeffs_interaction_b[16];

    signal input coeffs_constant_a[10];
    signal input coeffs_constant_b[10];

    signal input coeffs_composition_a[8];
    signal input coeffs_composition_b[8];

    signal input coeffs_interaction_shifted_a[8];
    signal input coeffs_interaction_shifted_b[8];

    signal input alpha[4];

    component query_s = compute_quotient_for_individual_query(N, L);
    query_s.query <== query;
    query_s.alpha <== alpha;

    query_s.trace_l <== trace_l;
    query_s.trace_r <== trace_r;
    query_s.coeffs_trace_a <== coeffs_trace_a;
    query_s.coeffs_trace_b <== coeffs_trace_b;

    query_s.interaction_l <== interaction_l;
    query_s.interaction_r <== interaction_r;
    query_s.coeffs_interaction_a <== coeffs_interaction_a;
    query_s.coeffs_interaction_b <== coeffs_interaction_b;

    query_s.constant_l <== constant_l;
    query_s.constant_r <== constant_r;
    query_s.coeffs_constant_a <== coeffs_constant_a;
    query_s.coeffs_constant_b <== coeffs_constant_b;

    query_s.composition_l <== composition_l;
    query_s.composition_r <== composition_r;
    query_s.coeffs_composition_a <== coeffs_composition_a;
    query_s.coeffs_composition_b <== coeffs_composition_b;

    query_s.coeffs_interaction_shifted_a <== coeffs_interaction_shifted_a;
    query_s.coeffs_interaction_shifted_b <== coeffs_interaction_shifted_b;

    signal input oods_a[2];
    signal input oods_b[2];
    signal input oods_shifted_a[2];
    signal input oods_shifted_b[2];

    query_s.oods_a <== oods_a;
    query_s.oods_b <== oods_b;
    query_s.oods_shifted_a <== oods_shifted_a;
    query_s.oods_shifted_b <== oods_shifted_b;

    signal input sum_l[4];
    signal input sum_r[4];
    sum_l === query_s.sum_l;
    sum_r === query_s.sum_r;
}

component main = test_quotient(13, 5);