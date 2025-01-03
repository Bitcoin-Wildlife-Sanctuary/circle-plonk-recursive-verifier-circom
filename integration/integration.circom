pragma circom 2.0.0;

include "../components/fiat_shamir/fiat_shamir.circom";
include "../components/prepare/prepare.circom";
include "../components/quotient/quotient.circom";
include "../components/folding/folding.circom";
include "../components/decommit/decommit.circom";

template integration(N, L) {
    signal input trace_commitment[8];
    signal input interaction_commitment[8];
    signal input constant_commitment[8];
    signal input composition_commitment[8];
    signal input sampled_value_trace[12];
    signal input sampled_value_interaction[32];
    signal input sampled_value_interaction_shifted[16];
    signal input sampled_value_constant[20];
    signal input sampled_value_composition[16];
    signal input fri_layer_commitments[8 * N];
    signal input last_layer[4];
    signal input nonce[3];

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

    signal input claimed_sum[4];

    component prepare = prepare(N);
    prepare.sampled_value_trace <== sampled_value_trace;
    prepare.sampled_value_interaction <== sampled_value_interaction;
    prepare.sampled_value_interaction_shifted <== sampled_value_interaction_shifted;
    prepare.sampled_value_constant <== sampled_value_constant;
    prepare.sampled_value_composition <== sampled_value_composition;

    prepare.alpha <== fiat_shamir.alpha;
    prepare.z <== fiat_shamir.z;
    prepare.random_coeff <== fiat_shamir.random_coeff;

    prepare.claimed_sum <== claimed_sum;
    prepare.oods_point_x <== fiat_shamir.oods_point_x;
    prepare.oods_point_y <== fiat_shamir.oods_point_y;

    signal input all_trace_l[3 * 16];
    signal input all_trace_r[3 * 16];

    signal input all_interaction_l[8 * 16];
    signal input all_interaction_r[8 * 16];

    signal input all_constant_l[5 * 16];
    signal input all_constant_r[5 * 16];

    signal input all_composition_l[4 * 16];
    signal input all_composition_r[4 * 16];

    component quotients[16];

    for(var query_idx = 0; query_idx < 16; query_idx++) {
        quotients[query_idx] = compute_quotient_for_individual_query(N, L);

        quotients[query_idx].coeffs_trace_a <== prepare.coeffs_trace_a;
        quotients[query_idx].coeffs_trace_b <== prepare.coeffs_trace_b;
        quotients[query_idx].coeffs_interaction_a <== prepare.coeffs_interaction_a;
        quotients[query_idx].coeffs_interaction_b <== prepare.coeffs_interaction_b;
        quotients[query_idx].coeffs_constant_a <== prepare.coeffs_constant_a;
        quotients[query_idx].coeffs_constant_b <== prepare.coeffs_constant_b;
        quotients[query_idx].alpha <== fiat_shamir.line_batch_random_coeff;
        quotients[query_idx].coeffs_composition_a <== prepare.coeffs_composition_a;
        quotients[query_idx].coeffs_composition_b <== prepare.coeffs_composition_b;
        quotients[query_idx].coeffs_interaction_shifted_a <== prepare.coeffs_interaction_shifted_a;
        quotients[query_idx].coeffs_interaction_shifted_b <== prepare.coeffs_interaction_shifted_b;
        quotients[query_idx].oods_a <== prepare.oods_a;
        quotients[query_idx].oods_b <== prepare.oods_b;
        quotients[query_idx].oods_shifted_a <== prepare.oods_shifted_a;
        quotients[query_idx].oods_shifted_b <== prepare.oods_shifted_b;

        quotients[query_idx].query <== fiat_shamir.queries[query_idx];

        for(var j = 0; j < 3; j++) {
            quotients[query_idx].trace_l[j] <== all_trace_l[3 * query_idx + j];
            quotients[query_idx].trace_r[j] <== all_trace_r[3 * query_idx + j];
        }
        for(var j = 0; j < 8; j++) {
            quotients[query_idx].interaction_l[j] <== all_interaction_l[8 * query_idx + j];
            quotients[query_idx].interaction_r[j] <== all_interaction_r[8 * query_idx + j];
        }
        for(var j = 0; j < 5; j++) {
            quotients[query_idx].constant_l[j] <== all_constant_l[5 * query_idx + j];
            quotients[query_idx].constant_r[j] <== all_constant_r[5 * query_idx + j];
        }
        for(var j = 0; j < 4; j++) {
            quotients[query_idx].composition_l[j] <== all_composition_l[4 * query_idx + j];
            quotients[query_idx].composition_r[j] <== all_composition_r[4 * query_idx + j];
        }
    }

    signal input all_siblings[N * 4 * 16];
    signal input all_fri_siblings[(L + L + N - 1) * N * 4 * 16];

    component folds[16];
    for(var query_idx = 0; query_idx < 16; query_idx ++) {
        folds[query_idx] = full_fold(N, L);
        folds[query_idx].l <== quotients[query_idx].sum_l;
        folds[query_idx].r <== quotients[query_idx].sum_r;
        folds[query_idx].y <== quotients[query_idx].z_y;
        folds[query_idx].fri_fold_random_coeff <== fiat_shamir.fri_fold_random_coeff;
        folds[query_idx].query <== fiat_shamir.queries[query_idx];
        folds[query_idx].last_layer <== last_layer;

        for(var j = 0; j < N * 4; j++) {
            folds[query_idx].siblings[j] <== all_siblings[N * 4 * query_idx + j];
        }
        folds[query_idx].fri_alphas <== fiat_shamir.fri_alphas;

        folds[query_idx].fri_hashes <== fri_layer_commitments;
        for(var j = 0; j < (L + L + N - 1) * N * 4; j++) {
            folds[query_idx].fri_siblings[j] <== all_fri_siblings[(L + L + N - 1) * N * 4 * query_idx + j];
        }
    }

    signal input all_trace_siblings[(N + L) * 8 * 16];
    signal input all_interaction_siblings[(N + L) * 8 * 16];
    signal input all_constant_siblings[(N + L) * 8 * 16];
    signal input all_composition_siblings[(N + L) * 8 * 16];

    component decommits[16];

    for(var query_idx = 0; query_idx < 16; query_idx ++) {
        decommits[query_idx] = decommit(N, L);
        decommits[query_idx].query <== fiat_shamir.queries[query_idx];
        for(var j = 0; j < (N + L) * 8; j++) {
            decommits[query_idx].trace_siblings[j] <== all_trace_siblings[(N + L) * 8 * query_idx + j];
            decommits[query_idx].interaction_siblings[j] <== all_interaction_siblings[(N + L) * 8 * query_idx + j];
            decommits[query_idx].constant_siblings[j] <== all_constant_siblings[(N + L) * 8 * query_idx + j];
            decommits[query_idx].composition_siblings[j] <== all_composition_siblings[(N + L) * 8 * query_idx + j];
        }
        decommits[query_idx].trace_root <== trace_commitment;
        decommits[query_idx].trace_l <== quotients[query_idx].trace_l;
        decommits[query_idx].trace_r <== quotients[query_idx].trace_r;
        decommits[query_idx].interaction_l <== quotients[query_idx].interaction_l;
        decommits[query_idx].interaction_r <== quotients[query_idx].interaction_r;
        decommits[query_idx].interaction_root <== interaction_commitment;
        decommits[query_idx].constant_l <== quotients[query_idx].constant_l;
        decommits[query_idx].constant_r <== quotients[query_idx].constant_r;
        decommits[query_idx].constant_root <== constant_commitment;
        decommits[query_idx].composition_l <== quotients[query_idx].composition_l;
        decommits[query_idx].composition_r <== quotients[query_idx].composition_r;
        decommits[query_idx].composition_root <== composition_commitment;
    }
}

component main = integration(13, 5);