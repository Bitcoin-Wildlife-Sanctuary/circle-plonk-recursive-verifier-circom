pragma circom 2.0.0;

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
}

component main { public [
        trace_commitment, alpha, z, interaction_commitment, constant_commitment,
        random_coeff
    ]
} = fiat_shamir();