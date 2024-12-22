pragma circom 2.0.0;

include "channel.circom";

template test_channel() {
    signal input iv[8];

    component default_ch = poseidon31_channel_default();
    for(var i = 0; i < 8; i++) {
        iv[i] === default_ch.out[i + 8];
    }

    signal input root[8];
    signal input channel_mix_root[8];
    component mix_root = poseidon31_channel_mix_root();
    for(var i = 0; i < 8; i++) {
        mix_root.old_channel[i] <== 0;
        mix_root.old_channel[i + 8] <== iv[i];
    }
    for(var i = 0; i < 8; i++) {
        mix_root.root[i] <== root[i];
    }
    for(var i = 0; i < 8; i++) {
        channel_mix_root[i] === mix_root.new_channel[8 + i];
    }

    signal input channel_draw_felt1[4];
    signal input channel_draw_felt2_a[4];
    signal input channel_draw_felt2_b[4];
    signal input channel_draw_felt2_c[4];
    component draw_felt = poseidon31_channel_get_felts();
    for(var i = 0; i < 16; i++) {
        draw_felt.old_channel[i] <== mix_root.new_channel[i];
    }
    for(var i = 0; i < 4; i++) {
        draw_felt.a[i] === channel_draw_felt1[i];
        draw_felt.b[i] === channel_draw_felt2_a[i];
    }

    component squeeze_again = poseidon31_channel_squeeze_again();
    for(var i = 0; i < 16; i++) {
        squeeze_again.old_channel[i] <== mix_root.new_channel[i];
    }

    component draw_felt2 = poseidon31_channel_get_felts();
    for(var i = 0; i < 16; i++) {
        draw_felt2.old_channel[i] <== squeeze_again.new_channel[i];
    }
    for(var i = 0; i < 4; i++) {
        draw_felt2.a[i] === channel_draw_felt2_b[i];
        draw_felt2.b[i] === channel_draw_felt2_c[i];
    }

    signal input a[4];
    signal input b[4];
    signal input c[4];
    signal input channel_absorb_1[8];
    signal input channel_absorb_2[8];

    component absorb1 = poseidon31_channel_absorb_one_felt_and_permute();
    for(var i = 0; i < 16; i++) {
        absorb1.old_channel[i] <== squeeze_again.new_channel[i];
    }
    for(var i = 0; i < 4; i++) {
        absorb1.a[i] <== a[i];
    }
    for(var i = 0; i < 8; i++) {
        channel_absorb_1[i] === absorb1.new_channel[i + 8];
    }

    component absorb2 = poseidon31_channel_absorb_two_felts_and_permute();
    for(var i = 0; i < 16; i++) {
        absorb2.old_channel[i] <== absorb1.new_channel[i];
    }
    for(var i = 0; i < 4; i++) {
        absorb2.a[i] <== b[i];
        absorb2.b[i] <== c[i];
    }
    for(var i = 0; i < 8; i++) {
        channel_absorb_2[i] === absorb2.new_channel[i + 8];
    }
}

component main { public [
        iv, root, channel_mix_root, channel_draw_felt1, channel_draw_felt2_a, channel_draw_felt2_b,
        channel_draw_felt2_c, a, b, c, channel_absorb_1, channel_absorb_2
    ]
} = test_channel();