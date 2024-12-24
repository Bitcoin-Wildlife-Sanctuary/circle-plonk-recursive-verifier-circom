pragma circom 2.0.0;

include "../../primitives/circle/curve.circom";
include "../../primitives/circle/fields.circom";
include "../../primitives/channel/channel.circom";

template fiat_shamir() {
    signal input trace_commitment[8];
    signal input alpha[4];
    signal input z[4];
    signal input interaction_commitment[8];
    signal input constant_commitment[8];
    signal input random_coeff[4];

    component channel_default = poseidon31_channel_default();

    component channel_mix_trace_commitment = poseidon31_channel_mix_root();
    channel_mix_trace_commitment.old_channel <== channel_default.out;
    channel_mix_trace_commitment.root <== trace_commitment;

    component channel_squeeze_alpha_and_z = poseidon31_channel_get_felts();
    channel_squeeze_alpha_and_z.old_channel <== channel_mix_trace_commitment.new_channel;
    z === channel_squeeze_alpha_and_z.a;
    alpha === channel_squeeze_alpha_and_z.b;

    component channel_mix_interaction_commitment = poseidon31_channel_mix_root();
    channel_mix_interaction_commitment.old_channel <== channel_mix_trace_commitment.new_channel;
    channel_mix_interaction_commitment.root <== interaction_commitment;

    component channel_mix_constant_commitment = poseidon31_channel_mix_root();
    channel_mix_constant_commitment.old_channel <== channel_mix_interaction_commitment.new_channel;
    channel_mix_constant_commitment.root <== constant_commitment;

    component channel_squeeze_random_coeff = poseidon31_channel_get_felts();
    channel_squeeze_random_coeff.old_channel <== channel_mix_constant_commitment.new_channel;
    random_coeff === channel_squeeze_random_coeff.a;

    signal input composition_commitment[8];

    component channel_mix_composition_commitment = poseidon31_channel_mix_root();
    channel_mix_composition_commitment.old_channel <== channel_mix_constant_commitment.new_channel;
    channel_mix_composition_commitment.root <== composition_commitment;

    component channel_squeeze_t = poseidon31_channel_get_felts();
    channel_squeeze_t.old_channel <== channel_mix_composition_commitment.new_channel;

    signal input oods_point_x[4];
    signal input oods_point_y[4];

    component channel_get_oods_point = circle_point_from_t();
    channel_get_oods_point.t <== channel_squeeze_t.a;
    oods_point_x === channel_get_oods_point.x;
    oods_point_y === channel_get_oods_point.y;

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

    component channel_absorb1 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb1.old_channel <== channel_mix_composition_commitment.new_channel;
    channel_absorb1.a <== sampled_value_trace_a_val;
    channel_absorb1.b <== sampled_value_trace_b_val;

    component channel_absorb2 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb2.old_channel <== channel_absorb1.new_channel;
    channel_absorb2.a <== sampled_value_trace_c_val;
    channel_absorb2.b <== sampled_value_interaction_ab_0;

    component channel_absorb3 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb3.old_channel <== channel_absorb2.new_channel;
    channel_absorb3.a <== sampled_value_interaction_ab_1;
    channel_absorb3.b <== sampled_value_interaction_ab_2;

    component channel_absorb4 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb4.old_channel <== channel_absorb3.new_channel;
    channel_absorb4.a <== sampled_value_interaction_ab_3;
    channel_absorb4.b <== sampled_value_interaction_sum_0;

    component channel_absorb5 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb5.old_channel <== channel_absorb4.new_channel;
    channel_absorb5.a <== sampled_value_interaction_shifted_sum_0;
    channel_absorb5.b <== sampled_value_interaction_sum_1;

    component channel_absorb6 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb6.old_channel <== channel_absorb5.new_channel;
    channel_absorb6.a <== sampled_value_interaction_shifted_sum_1;
    channel_absorb6.b <== sampled_value_interaction_sum_2;

    component channel_absorb7 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb7.old_channel <== channel_absorb6.new_channel;
    channel_absorb7.a <== sampled_value_interaction_shifted_sum_2;
    channel_absorb7.b <== sampled_value_interaction_sum_3;

    component channel_absorb8 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb8.old_channel <== channel_absorb7.new_channel;
    channel_absorb8.a <== sampled_value_interaction_shifted_sum_3;
    channel_absorb8.b <== sampled_value_constant_mult;

    component channel_absorb9 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb9.old_channel <== channel_absorb8.new_channel;
    channel_absorb9.a <== sampled_value_constant_a_wire;
    channel_absorb9.b <== sampled_value_constant_b_wire;

    component channel_absorb10 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb10.old_channel <== channel_absorb9.new_channel;
    channel_absorb10.a <== sampled_value_constant_c_wire;
    channel_absorb10.b <== sampled_value_constant_op;

    component channel_absorb11 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb11.old_channel <== channel_absorb10.new_channel;
    channel_absorb11.a <== sampled_value_composition_0;
    channel_absorb11.b <== sampled_value_composition_1;

    component channel_absorb12 = poseidon31_channel_absorb_two_felts_and_permute();
    channel_absorb12.old_channel <== channel_absorb11.new_channel;
    channel_absorb12.a <== sampled_value_composition_2;
    channel_absorb12.b <== sampled_value_composition_3;

    signal input line_batch_random_coeff[4];
    signal input fri_fold_random_coeff[4];

    component channel_squeeze_fri = poseidon31_channel_get_felts();
    channel_squeeze_fri.old_channel <== channel_absorb12.new_channel;
    line_batch_random_coeff === channel_squeeze_fri.a;
    fri_fold_random_coeff === channel_squeeze_fri.b;

    signal input fri_layer_commitment0[8];
    signal input fri_alpha0[4];

    component channel_fri_a0 = poseidon31_channel_mix_root();
    channel_fri_a0.old_channel <== channel_absorb12.new_channel;
    channel_fri_a0.root <== fri_layer_commitment0;

    component channel_fri_s0 = poseidon31_channel_get_felts();
    channel_fri_s0.old_channel <== channel_fri_a0.new_channel;
    fri_alpha0 === channel_fri_s0.a;

    signal input fri_layer_commitment1[8];
    signal input fri_alpha1[4];

    component channel_fri_a1 = poseidon31_channel_mix_root();
    channel_fri_a1.old_channel <== channel_fri_a0.new_channel;
    channel_fri_a1.root <== fri_layer_commitment1;

    component channel_fri_s1 = poseidon31_channel_get_felts();
    channel_fri_s1.old_channel <== channel_fri_a1.new_channel;
    fri_alpha1 === channel_fri_s1.a;

    signal input fri_layer_commitment2[8];
    signal input fri_alpha2[4];

    component channel_fri_a2 = poseidon31_channel_mix_root();
    channel_fri_a2.old_channel <== channel_fri_a1.new_channel;
    channel_fri_a2.root <== fri_layer_commitment2;

    component channel_fri_s2 = poseidon31_channel_get_felts();
    channel_fri_s2.old_channel <== channel_fri_a2.new_channel;
    fri_alpha2 === channel_fri_s2.a;

    signal input fri_layer_commitment3[8];
    signal input fri_alpha3[4];

    component channel_fri_a3 = poseidon31_channel_mix_root();
    channel_fri_a3.old_channel <== channel_fri_a2.new_channel;
    channel_fri_a3.root <== fri_layer_commitment3;

    component channel_fri_s3 = poseidon31_channel_get_felts();
    channel_fri_s3.old_channel <== channel_fri_a3.new_channel;
    fri_alpha3 === channel_fri_s3.a;

    signal input fri_layer_commitment4[8];
    signal input fri_alpha4[4];

    component channel_fri_a4 = poseidon31_channel_mix_root();
    channel_fri_a4.old_channel <== channel_fri_a3.new_channel;
    channel_fri_a4.root <== fri_layer_commitment4;

    component channel_fri_s4 = poseidon31_channel_get_felts();
    channel_fri_s4.old_channel <== channel_fri_a4.new_channel;
    fri_alpha4 === channel_fri_s4.a;

    signal input fri_layer_commitment5[8];
    signal input fri_alpha5[4];

    component channel_fri_a5 = poseidon31_channel_mix_root();
    channel_fri_a5.old_channel <== channel_fri_a4.new_channel;
    channel_fri_a5.root <== fri_layer_commitment5;

    component channel_fri_s5 = poseidon31_channel_get_felts();
    channel_fri_s5.old_channel <== channel_fri_a5.new_channel;
    fri_alpha5 === channel_fri_s5.a;

    signal input fri_layer_commitment6[8];
    signal input fri_alpha6[4];

    component channel_fri_a6 = poseidon31_channel_mix_root();
    channel_fri_a6.old_channel <== channel_fri_a5.new_channel;
    channel_fri_a6.root <== fri_layer_commitment6;

    component channel_fri_s6 = poseidon31_channel_get_felts();
    channel_fri_s6.old_channel <== channel_fri_a6.new_channel;
    fri_alpha6 === channel_fri_s6.a;

    signal input fri_layer_commitment7[8];
    signal input fri_alpha7[4];

    component channel_fri_a7 = poseidon31_channel_mix_root();
    channel_fri_a7.old_channel <== channel_fri_a6.new_channel;
    channel_fri_a7.root <== fri_layer_commitment7;

    component channel_fri_s7 = poseidon31_channel_get_felts();
    channel_fri_s7.old_channel <== channel_fri_a7.new_channel;
    fri_alpha7 === channel_fri_s7.a;

    signal input fri_layer_commitment8[8];
    signal input fri_alpha8[4];

    component channel_fri_a8 = poseidon31_channel_mix_root();
    channel_fri_a8.old_channel <== channel_fri_a7.new_channel;
    channel_fri_a8.root <== fri_layer_commitment8;

    component channel_fri_s8 = poseidon31_channel_get_felts();
    channel_fri_s8.old_channel <== channel_fri_a8.new_channel;
    fri_alpha8 === channel_fri_s8.a;

    signal input fri_layer_commitment9[8];
    signal input fri_alpha9[4];

    component channel_fri_a9 = poseidon31_channel_mix_root();
    channel_fri_a9.old_channel <== channel_fri_a8.new_channel;
    channel_fri_a9.root <== fri_layer_commitment9;

    component channel_fri_s9 = poseidon31_channel_get_felts();
    channel_fri_s9.old_channel <== channel_fri_a9.new_channel;
    fri_alpha9 === channel_fri_s9.a;

    signal input fri_layer_commitment10[8];
    signal input fri_alpha10[4];

    component channel_fri_a10 = poseidon31_channel_mix_root();
    channel_fri_a10.old_channel <== channel_fri_a9.new_channel;
    channel_fri_a10.root <== fri_layer_commitment10;

    component channel_fri_s10 = poseidon31_channel_get_felts();
    channel_fri_s10.old_channel <== channel_fri_a10.new_channel;
    fri_alpha10 === channel_fri_s10.a;

    signal input fri_layer_commitment11[8];
    signal input fri_alpha11[4];

    component channel_fri_a11 = poseidon31_channel_mix_root();
    channel_fri_a11.old_channel <== channel_fri_a10.new_channel;
    channel_fri_a11.root <== fri_layer_commitment11;

    component channel_fri_s11 = poseidon31_channel_get_felts();
    channel_fri_s11.old_channel <== channel_fri_a11.new_channel;
    fri_alpha11 === channel_fri_s11.a;

    signal input fri_layer_commitment12[8];
    signal input fri_alpha12[4];

    component channel_fri_a12 = poseidon31_channel_mix_root();
    channel_fri_a12.old_channel <== channel_fri_a11.new_channel;
    channel_fri_a12.root <== fri_layer_commitment12;

    component channel_fri_s12 = poseidon31_channel_get_felts();
    channel_fri_s12.old_channel <== channel_fri_a12.new_channel;
    fri_alpha12 === channel_fri_s12.a;

    signal input last_layer[4];
    signal input channel_after_pow[16];

    signal input nonce[3];
    component channel_last_layer = poseidon31_channel_absorb_two_felts_and_permute();
    channel_last_layer.old_channel <== channel_fri_a12.new_channel;
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

    channel_after_pow === channel_last_layer.new_channel;

    signal pow_check;
    pow_check <== channel_last_layer.new_channel[8] / 1024;

    component check_pow = check_num_bits(21);
    check_pow.a <== pow_check;
}

component main { public [
        trace_commitment, alpha, z, interaction_commitment, constant_commitment,
        random_coeff, composition_commitment, oods_point_x, oods_point_y,
        sampled_value_trace_a_val, sampled_value_trace_b_val, sampled_value_trace_c_val,
        sampled_value_interaction_ab_0, sampled_value_interaction_ab_1,
        sampled_value_interaction_ab_2, sampled_value_interaction_ab_3,
        sampled_value_interaction_sum_0, sampled_value_interaction_sum_1,
        sampled_value_interaction_sum_2, sampled_value_interaction_sum_3,
        sampled_value_interaction_shifted_sum_0, sampled_value_interaction_shifted_sum_1,
        sampled_value_interaction_shifted_sum_2, sampled_value_interaction_shifted_sum_3,
        sampled_value_constant_mult, sampled_value_constant_a_wire,
        sampled_value_constant_b_wire, sampled_value_constant_c_wire,
        sampled_value_constant_op, sampled_value_composition_0, sampled_value_composition_1,
        sampled_value_composition_2, sampled_value_composition_3, line_batch_random_coeff,
        fri_fold_random_coeff, fri_layer_commitment0, fri_layer_commitment1,
        fri_layer_commitment2, fri_layer_commitment3, fri_layer_commitment4,
        fri_layer_commitment5, fri_layer_commitment6, fri_layer_commitment7,
        fri_layer_commitment8, fri_layer_commitment9, fri_layer_commitment10,
        fri_layer_commitment11, fri_layer_commitment12, fri_alpha0, fri_alpha1, fri_alpha2,
        fri_alpha3, fri_alpha4, fri_alpha5, fri_alpha6, fri_alpha7, fri_alpha8, fri_alpha9,
        fri_alpha10, fri_alpha11, fri_alpha12, last_layer, channel_after_pow,
        nonce
    ]
} = fiat_shamir();