pragma circom 2.0.0;

include "../poseidon31/poseidon31_permute.circom";

template poseidon31_channel_default() {
    signal output out[16];

    for(var i = 0; i < 8; i++) {
        out[i] <== 0;
    }

    out[8] <== 653561903;
    out[9] <== 1570384735;
    out[10] <== 1642608663;
    out[11] <== 717067276;
    out[12] <== 1210045490;
    out[13] <== 80872923;
    out[14] <== 982214479;
    out[15] <== 945961255;
}

template poseidon31_channel_mix_root() {
    signal input old_channel[16];
    signal input root[8];
    signal output new_channel[16];

    component c1 = poseidon31_permute();
    for(var i = 0; i < 8; i++) {
        c1.in[i] <== root[i];
        c1.in[i + 8] <== old_channel[i + 8];
    }

    for(var i = 0; i < 16; i++) {
        new_channel[i] <== c1.out[i];
    }
}

template poseidon31_channel_get_felts() {
    signal input old_channel[16];
    signal output a[4];
    signal output b[4];

    for(var i = 0; i < 4; i++) {
        a[i] <== old_channel[i];
        b[i] <== old_channel[i + 4];
    }
}

template poseidon31_channel_squeeze_again()  {
    signal input old_channel[16];
    signal output new_channel[16];

    component c1 = poseidon31_permute();
    for(var i = 0; i < 8; i++) {
        c1.in[i] <== 0;
        c1.in[i + 8] <== old_channel[i + 8];
    }
    for(var i = 0; i < 16; i++) {
        new_channel[i] <== c1.out[i];
    }
}

template poseidon31_channel_absorb_one_felt_and_permute() {
    signal input old_channel[16];
    signal output new_channel[16];
    signal input a[4];

    component c1 = poseidon31_permute();
    for(var i = 0; i < 4; i++) {
        c1.in[i] <== a[i];
        c1.in[i + 4] <== 0;
    }
    for(var i = 0; i < 8; i++) {
        c1.in[i + 8] <== old_channel[i + 8];
    }
    for(var i = 0; i < 16; i++) {
        new_channel[i] <== c1.out[i];
    }
}

template poseidon31_channel_absorb_two_felts_and_permute() {
    signal input old_channel[16];
    signal output new_channel[16];
    signal input a[4];
    signal input b[4];

    component c1 = poseidon31_permute();
    for(var i = 0; i < 4; i++) {
        c1.in[i] <== a[i];
        c1.in[i + 4] <== b[i];
    }
    for(var i = 0; i < 8; i++) {
        c1.in[i + 8] <== old_channel[i + 8];
    }
    for(var i = 0; i < 16; i++) {
        new_channel[i] <== c1.out[i];
    }
}