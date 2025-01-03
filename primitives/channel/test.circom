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
    mix_root.root <== root;
    for(var i = 0; i < 8; i++) {
        channel_mix_root[i] === mix_root.new_channel[8 + i];
    }

    signal input channel_draw_felt1[4];
    signal input channel_draw_felt2_a[4];
    signal input channel_draw_felt2_b[4];
    signal input channel_draw_felt2_c[4];
    component draw_felt = poseidon31_channel_get_felts();
    draw_felt.old_channel <== mix_root.new_channel;
    draw_felt.a === channel_draw_felt1;
    draw_felt.b === channel_draw_felt2_a;

    component squeeze_again = poseidon31_channel_squeeze_again();
    squeeze_again.old_channel <== mix_root.new_channel;

    component draw_felt2 = poseidon31_channel_get_felts();
    draw_felt2.old_channel <== squeeze_again.new_channel;
    draw_felt2.a === channel_draw_felt2_b;
    draw_felt2.b === channel_draw_felt2_c;

    signal input a[4];
    signal input b[4];
    signal input c[4];
    signal input channel_absorb_1[8];
    signal input channel_absorb_2[8];

    component absorb1 = poseidon31_channel_absorb_one_felt_and_permute();
    absorb1.old_channel <== squeeze_again.new_channel;
    absorb1.a <== a;
    for(var i = 0; i < 8; i++) {
        channel_absorb_1[i] === absorb1.new_channel[i + 8];
    }

    component absorb2 = poseidon31_channel_absorb_two_felts_and_permute();
    absorb2.old_channel <== absorb1.new_channel;
    absorb2.a <== b;
    absorb2.b <== c;
    for(var i = 0; i < 8; i++) {
        channel_absorb_2[i] === absorb2.new_channel[i + 8];
    }
}

component main = test_channel();