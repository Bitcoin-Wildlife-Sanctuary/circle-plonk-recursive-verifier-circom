pragma circom 2.0.0;

include "merkle.circom";

template test_merkle() {
    signal input idx;
    signal input leaf_hash[8];

    signal input siblings[64];
    signal input root[8];

    component verify = verify_merkle_path(8);
    verify.idx <== idx;
    verify.leaf_hash <== leaf_hash;
    verify.siblings <== siblings;
    verify.root <== root;
}

component main { public [idx, leaf_hash, siblings, root] } = test_merkle();