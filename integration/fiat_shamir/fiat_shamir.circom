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
        fri_fold_random_coeff
    ]
} = fiat_shamir();