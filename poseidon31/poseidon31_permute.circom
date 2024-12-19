pragma circom 2.0.0;

include "params.circom";

template poseidon31_pow5() {
    signal input in;
    signal output out;

    signal pow2;
    pow2 <== in * in;

    signal pow4;
    pow4 <== pow2 * pow2;

    out <== pow4 * in;
}

template poseidon31_apply_4x4_mds_matrix() {
    signal input in[4];
    signal output out[4];

    signal t0;
    t0 <== in[0] + in[1];

    signal t1;
    t1 <== in[2] + in[3];

    signal t2;
    t2 <== 2 * in[1] + t1;

    signal t3;
    t3 <== 2 * in[3] + t0;

    signal t4;
    t4 <== 4 * t1 + t3;

    signal t5;
    t5 <== 4 * t0 + t2;

    out[0] <== t3 + t5;
    out[1] <== t5;
    out[2] <== t2 + t4;
    out[3] <== t4;
}

template poseidon31_apply_16x16_mds_matrix() {
    signal input in[16];
    signal output out[16];

    component s1 = poseidon31_apply_4x4_mds_matrix();
    component s2 = poseidon31_apply_4x4_mds_matrix();
    component s3 = poseidon31_apply_4x4_mds_matrix();
    component s4 = poseidon31_apply_4x4_mds_matrix();

    for(var i = 0; i < 4; i++) {
        s1.in[i] <== in[i];
    }

    for(var i = 0; i < 4; i++) {
        s2.in[i] <== in[i + 4];
    }

    for(var i = 0; i < 4; i++) {
        s3.in[i] <== in[i + 8];
    }

    for(var i = 0; i < 4; i++) {
        s4.in[i] <== in[i + 12];
    }

    signal t[4];
    for(var i = 0; i < 4; i++) {
        t[i] <== s1.out[i] + s2.out[i] + s3.out[i] + s4.out[i];
    }

    for(var i = 0; i < 4; i++) {
        out[i] <== s1.out[i] + t[i];
        out[i + 4] <== s2.out[i] + t[i];
        out[i + 8] <== s3.out[i] + t[i];
        out[i + 12] <== s4.out[i] + t[i];
    }
}

template poseidon31_full_round(r) {
    signal input in[16];
    signal output out[16];

    signal before_mds[16];

    component round_constants = poseidon31_full_round_rc(r);
    component pow5[16];
    for(var i = 0; i < 16; i++) {
        pow5[i] = poseidon31_pow5();
        pow5[i].in <== in[i] + round_constants.out[i];
        before_mds[i] <== pow5[i].out;
    }

    component mds = poseidon31_apply_16x16_mds_matrix();
    for(var i = 0; i < 16; i++) {
        mds.in[i] <== before_mds[i];
    }
    for(var i = 0; i < 16; i++) {
        out[i] <== mds.out[i];
    }
}

template poseidon31_partial_round(r) {
    signal input in[16];
    signal output out[16];

    var diag[16] = [
        0x07b80ac4, 0x6bd9cb33, 0x48ee3f9f, 0x4f63dd19, 0x18c546b3, 0x5af89e8b, 0x4ff23de8, 0x4f78aaf6,
        0x53bdc6d4, 0x5c59823e, 0x2a471c72, 0x4c975e79, 0x58dc64d4, 0x06e9315d, 0x2cf32286, 0x2fb6755d
    ];

    var partial_rc[14] = [
        0x7f7ec4bf, 0x0421926f, 0x5198e669, 0x34db3148, 0x4368bafd, 0x66685c7f, 0x78d3249a, 0x60187881,
        0x76dad67a, 0x0690b437, 0x1ea95311, 0x40e5369a, 0x38f103fc, 0x1d226a21
    ];

    component pow5 = poseidon31_pow5();
    pow5.in <== partial_rc[r] + in[0];

    signal sum;
    sum <== pow5.out + in[1] + in[2] + in[3] + in[4] + in[5] + in[6] + in[7] + in[8] + in[9]
        + in[10] + in[11] + in[12] + in[13] + in[14] + in[15];

    out[0] <== sum + diag[0] * pow5.out;

    for(var i = 1; i < 16; i++) {
        out[i] <== sum + diag[i] * in[i];
    }
}

template poseidon31_permute() {
    signal input in[16];
    signal output out[16];

    signal before_rounds[22][16];

    component preprocessing = poseidon31_apply_16x16_mds_matrix();

    for(var i = 0; i < 16; i++) {
        preprocessing.in[i] <== in[i];
    }
    for(var i = 0; i < 16; i++) {
        before_rounds[0][i] <== preprocessing.out[i];
    }

    component full_round[8];
    for(var r = 0; r < 4; r++) {
        full_round[r] = poseidon31_full_round(r);

        for(var i = 0; i < 16; i++) {
            full_round[r].in[i] <== before_rounds[r][i];
        }
        for(var i = 0; i < 16; i++) {
            before_rounds[r + 1][i] <== full_round[r].out[i];
        }
    }

    component partial_round[14];
    for(var r = 0; r < 14; r++) {
        partial_round[r] = poseidon31_partial_round(r);

        for(var i = 0; i < 16; i++) {
            partial_round[r].in[i] <== before_rounds[4 + r][i];
        }
        for(var i = 0; i < 16; i++) {
            before_rounds[4 + r + 1][i] <== partial_round[r].out[i];
        }
    }

    for(var r = 0; r < 3; r++) {
        full_round[4 + r] = poseidon31_full_round(4 + r);

        for(var i = 0; i < 16; i++) {
            full_round[4 + r].in[i] <== before_rounds[18 + r][i];
        }
        for(var i = 0; i < 16; i++) {
            before_rounds[18 + r + 1][i] <== full_round[4 + r].out[i];
        }
    }

    full_round[7] = poseidon31_full_round(7);
    for(var i = 0; i < 16; i++) {
        full_round[7].in[i] <== before_rounds[21][i];
    }
    for(var i = 0; i < 16; i++) {
        out[i] <== full_round[7].out[i];
    }
}