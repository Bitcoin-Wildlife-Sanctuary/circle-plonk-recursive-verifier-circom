pragma circom 2.0.0;

include "../bits/bits.circom";
include "../circle/fields.circom";
include "../poseidon31/poseidon31_permute.circom";

template swap_hashes() {
    signal input a[8];
    signal input b[8];

    signal input bit;

    signal output l[8];
    signal output r[8];

    component swaps[8];
    for(var i = 0; i < 8; i++) {
        swaps[i] = m31_swap();
        swaps[i].x0 <== a[i];
        swaps[i].x1 <== b[i];
        swaps[i].bit <== bit;
        l[i] <== swaps[i].out0;
        r[i] <== swaps[i].out1;
    }
}

template verify_merkle_path(D) {
    signal input idx;
    signal input leaf_hash[8];

    signal input siblings[D * 8];
    signal input root[8];

    component bits = decompose_into_bits(D + 1);
    bits.a <== idx;

    component rest = verify_merkle_path_with_bits(D);
    for(var i = 0; i < D; i++) {
        rest.bits[i] <== bits.bits[i + 1];
    }
    rest.leaf_hash <== leaf_hash;
    rest.siblings <== siblings;
    rest.root <== root;
}

template verify_merkle_path_with_bits(D) {
    signal input bits[D];
    signal input leaf_hash[8];

    signal input siblings[D * 8];
    signal input root[8];

    signal prev_elem[D + 1][8];
    prev_elem[0] <== leaf_hash;

    component swaps[D];
    component permute[D];

    for(var i = 0; i < D; i++) {
        swaps[i] = swap_hashes();
        swaps[i].a <== prev_elem[i];
        for(var j = 0; j < 8; j++) {
            swaps[i].b[j] <== siblings[i * 8 + j];
        }
        swaps[i].bit <== bits[i];

        permute[i] = poseidon31_permute();
        for(var j = 0; j < 8; j++) {
            permute[i].in[j] <== swaps[i].l[j];
        }
        for(var j = 0; j < 8; j++) {
            permute[i].in[8 + j] <== swaps[i].r[j];
        }

        for(var j = 0; j < 8; j++) {
            prev_elem[i + 1][j] <== permute[i].out[j] + swaps[i].l[j];
        }
    }

    prev_elem[D] === root;
}