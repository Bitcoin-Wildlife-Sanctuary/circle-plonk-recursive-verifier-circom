pragma circom 2.0.0;

include "fiat_shamir.circom";

template test_fiat_shamir(N) {
    signal input trace_commitment[8];
    signal input alpha[4];
    signal input z[4];
    signal input interaction_commitment[8];
    signal input constant_commitment[8];
    signal input random_coeff[4];
    signal input composition_commitment[8];

    signal input oods_point_x[4];
    signal input oods_point_y[4];

    signal input sampled_value_trace[12];
    signal input sampled_value_interaction[32];
    signal input sampled_value_interaction_shifted[16];
    signal input sampled_value_constant[20];
    signal input sampled_value_composition[16];

    signal input line_batch_random_coeff[4];
    signal input fri_fold_random_coeff[4];

    signal input fri_layer_commitments[8 * N];
    signal input fri_alphas[4 * N];

    signal input last_layer[4];
    signal input nonce[3];

    signal input queries[16];

    component fiat_shamir = fiat_shamir(N);
    fiat_shamir.trace_commitment <== trace_commitment;
    fiat_shamir.interaction_commitment <== interaction_commitment;
    fiat_shamir.constant_commitment <== constant_commitment;
    fiat_shamir.composition_commitment <== composition_commitment;
    fiat_shamir.sampled_value_trace <== sampled_value_trace;
    fiat_shamir.sampled_value_interaction <== sampled_value_interaction;
    fiat_shamir.sampled_value_interaction_shifted <== sampled_value_interaction_shifted;
    fiat_shamir.sampled_value_constant <== sampled_value_constant;
    fiat_shamir.sampled_value_composition <== sampled_value_composition;
    fiat_shamir.fri_layer_commitments <== fri_layer_commitments;
    fiat_shamir.last_layer <== last_layer;
    fiat_shamir.nonce <== nonce;

    alpha === fiat_shamir.alpha;
    z === fiat_shamir.z;
    random_coeff === fiat_shamir.random_coeff;
    oods_point_x === fiat_shamir.oods_point_x;
    oods_point_y === fiat_shamir.oods_point_y;
    line_batch_random_coeff === fiat_shamir.line_batch_random_coeff;
    fri_fold_random_coeff === fiat_shamir.fri_fold_random_coeff;
    fri_alphas === fiat_shamir.fri_alphas;
    queries === fiat_shamir.queries;
}

component main = test_fiat_shamir(13);