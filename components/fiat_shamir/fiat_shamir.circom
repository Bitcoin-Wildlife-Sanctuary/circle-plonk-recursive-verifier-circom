pragma circom 2.0.0;

include "../../primitives/bits/bits.circom";
include "../../primitives/circle/curve.circom";
include "../../primitives/circle/fields.circom";
include "../../primitives/channel/channel.circom";

template fiat_shamir(N) {
    signal input trace_commitment[8];
    signal output alpha[4];
    signal output z[4];
    signal input interaction_commitment[8];
    signal input constant_commitment[8];
    signal output random_coeff[4];

    component channel_default = poseidon31_channel_default();

    component channel_mix_trace_commitment = poseidon31_channel_mix_root();
    channel_mix_trace_commitment.old_channel <== channel_default.out;
    channel_mix_trace_commitment.root <== trace_commitment;

    component channel_squeeze_alpha_and_z = poseidon31_channel_get_felts();
    channel_squeeze_alpha_and_z.old_channel <== channel_mix_trace_commitment.new_channel;
    z <== channel_squeeze_alpha_and_z.a;
    alpha <== channel_squeeze_alpha_and_z.b;

    component channel_mix_interaction_commitment = poseidon31_channel_mix_root();
    channel_mix_interaction_commitment.old_channel <== channel_mix_trace_commitment.new_channel;
    channel_mix_interaction_commitment.root <== interaction_commitment;

    component channel_mix_constant_commitment = poseidon31_channel_mix_root();
    channel_mix_constant_commitment.old_channel <== channel_mix_interaction_commitment.new_channel;
    channel_mix_constant_commitment.root <== constant_commitment;

    component channel_squeeze_random_coeff = poseidon31_channel_get_felts();
    channel_squeeze_random_coeff.old_channel <== channel_mix_constant_commitment.new_channel;
    random_coeff <== channel_squeeze_random_coeff.a;

    signal input composition_commitment[8];

    component channel_mix_composition_commitment = poseidon31_channel_mix_root();
    channel_mix_composition_commitment.old_channel <== channel_mix_constant_commitment.new_channel;
    channel_mix_composition_commitment.root <== composition_commitment;

    component channel_squeeze_t = poseidon31_channel_get_felts();
    channel_squeeze_t.old_channel <== channel_mix_composition_commitment.new_channel;

    signal output oods_point_x[4];
    signal output oods_point_y[4];

    component channel_get_oods_point = circle_point_from_t();
    channel_get_oods_point.t <== channel_squeeze_t.a;
    oods_point_x <== channel_get_oods_point.x;
    oods_point_y <== channel_get_oods_point.y;

    signal input sampled_value_trace[12];
    signal input sampled_value_interaction[32];
    signal input sampled_value_interaction_shifted[16];
    signal input sampled_value_constant[20];
    signal input sampled_value_composition[16];

    component channel_absorb1 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb1.old_channel <== channel_mix_composition_commitment.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb1.a[i] <== sampled_value_trace[i];
        channel_absorb1.b[i] <== sampled_value_trace[i + 4];
    }

    component channel_absorb2 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb2.old_channel <== channel_absorb1.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb2.a[i] <== sampled_value_trace[i + 8];
        channel_absorb2.b[i] <== sampled_value_interaction[i];
    }

    component channel_absorb3 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb3.old_channel <== channel_absorb2.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb3.a[i] <== sampled_value_interaction[i + 4];
        channel_absorb3.b[i] <== sampled_value_interaction[i + 8];
    }

    component channel_absorb4 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb4.old_channel <== channel_absorb3.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb4.a[i] <== sampled_value_interaction[i + 12];
        channel_absorb4.b[i] <== sampled_value_interaction[i + 16];
    }

    component channel_absorb5 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb5.old_channel <== channel_absorb4.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb5.a[i] <== sampled_value_interaction_shifted[i];
        channel_absorb5.b[i] <== sampled_value_interaction[i + 20];
    }

    component channel_absorb6 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb6.old_channel <== channel_absorb5.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb6.a[i] <== sampled_value_interaction_shifted[i + 4];
        channel_absorb6.b[i] <== sampled_value_interaction[i + 24];
    }

    component channel_absorb7 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb7.old_channel <== channel_absorb6.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb7.a[i] <== sampled_value_interaction_shifted[i + 8];
        channel_absorb7.b[i] <== sampled_value_interaction[i + 28];
    }

    component channel_absorb8 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb8.old_channel <== channel_absorb7.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb8.a[i] <== sampled_value_interaction_shifted[i + 12];
        channel_absorb8.b[i] <== sampled_value_constant[i];
    }

    component channel_absorb9 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb9.old_channel <== channel_absorb8.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb9.a[i] <== sampled_value_constant[i + 4];
        channel_absorb9.b[i] <== sampled_value_constant[i + 8];
    }

    component channel_absorb10 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb10.old_channel <== channel_absorb9.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb10.a[i] <== sampled_value_constant[i + 12];
        channel_absorb10.b[i] <== sampled_value_constant[i + 16];
    }

    component channel_absorb11 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb11.old_channel <== channel_absorb10.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb11.a[i] <== sampled_value_composition[i];
        channel_absorb11.b[i] <== sampled_value_composition[i + 4];
    }

    component channel_absorb12 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb12.old_channel <== channel_absorb11.new_channel;
    for(var i = 0; i < 4; i++) {
        channel_absorb12.a[i] <== sampled_value_composition[i + 8];
        channel_absorb12.b[i] <== sampled_value_composition[i + 12];
    }

    signal output line_batch_random_coeff[4];
    signal output fri_fold_random_coeff[4];

    component channel_squeeze_fri = poseidon31_channel_get_felts();
    channel_squeeze_fri.old_channel <== channel_absorb12.new_channel;
    line_batch_random_coeff <== channel_squeeze_fri.a;
    fri_fold_random_coeff <== channel_squeeze_fri.b;

    signal input fri_layer_commitments[8 * N];
    signal output fri_alphas[4 * N];

    signal old_channels[N + 1][16];
    old_channels[0] <== channel_absorb12.new_channel;

    component mix_roots[N];
    component extracts[N];
    for(var i = 0; i < N; i++) {
        mix_roots[i] = poseidon31_channel_mix_root();
        mix_roots[i].old_channel <== old_channels[i];
        for(var j = 0; j < 8; j++) {
            mix_roots[i].root[j] <== fri_layer_commitments[i * 8 + j];
        }

        extracts[i] = poseidon31_channel_get_felts();
        extracts[i].old_channel <== mix_roots[i].new_channel;
        for(var j = 0; j < 4; j++) {
            fri_alphas[i * 4 + j] <== extracts[i].a[j];
        }
        old_channels[i + 1] <== mix_roots[i].new_channel;
    }

    signal input last_layer[4];
    signal input nonce[3];

    component channel_last_layer = poseidon31_channel_absorb_two_felts_and_permute();
    channel_last_layer.old_channel <== old_channels[N];
    channel_last_layer.a <== last_layer;
    channel_last_layer.b[0] <== nonce[0];
    channel_last_layer.b[1] <== nonce[1];
    channel_last_layer.b[2] <== nonce[2];
    channel_last_layer.b[3] <== 0;

    component check_nonce1 = check_num_bits(22);
    check_nonce1.a <== nonce[0];

    component check_nonce2 = check_num_bits(21);
    check_nonce2.a <== nonce[1];

    component check_nonce3 = check_num_bits(21);
    check_nonce3.a <== nonce[2];

    signal pow_check;
    pow_check <-- channel_last_layer.new_channel[8] >> 20;
    pow_check * 1048576 === channel_last_layer.new_channel[8];
    component check_pow = check_num_bits(11);
    check_pow.a <== pow_check;

    signal output queries[16];

    signal raw_queries[16];
    component channel_get_raw_queries_1 = poseidon31_channel_get_felts();
    channel_get_raw_queries_1.old_channel <== channel_last_layer.new_channel;
    for(var i = 0; i < 4; i++) {
        raw_queries[i] <== channel_get_raw_queries_1.a[i];
        raw_queries[i + 4] <== channel_get_raw_queries_1.b[i];
    }

    component channel_squeeze_again_for_queries = poseidon31_channel_squeeze_again();
    channel_squeeze_again_for_queries.old_channel <== channel_last_layer.new_channel;

    component channel_get_raw_queries_2 = poseidon31_channel_get_felts();
    channel_get_raw_queries_2.old_channel <== channel_squeeze_again_for_queries.new_channel;
    for(var i = 0; i < 4; i++) {
        raw_queries[i + 8] <== channel_get_raw_queries_2.a[i];
        raw_queries[i + 12] <== channel_get_raw_queries_2.b[i];
    }

    component get_lower_bits[16];
    for(var i = 0; i < 16; i++) {
        get_lower_bits[i] = get_lower_bits_checked(19);
        get_lower_bits[i].in <== raw_queries[i];
        queries[i] <== get_lower_bits[i].out;
    }
}