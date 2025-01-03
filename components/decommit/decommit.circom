pragma circom 2.0.0;

include "../../primitives/merkle/merkle.circom";

template decommit(D) {
    signal input queries_parent;
    signal input parent_hash[8];
    signal input siblings[D * 8];
    signal input root[8];

    component merkle = verify_merkle_path(D);
    merkle.idx <== queries_parent;
    merkle.leaf_hash <== parent_hash;
    merkle.siblings <== siblings;
    merkle.root <== root;
}

template compute_parent_hash_no_more_than_8(N) {
    signal input left[N];
    signal input right[N];

    signal output parent_hash[8];

    component permute = poseidon31_permute();
    for(var i = 0; i < N; i++) {
        permute.in[i] <== left[i];
        permute.in[i + 8] <== right[i];
    }
    for(var i = 0; i < 8 - N; i++) {
        permute.in[i + N] <== 0;
        permute.in[i + 8 + N] <== 0;
    }

    for(var i = 0; i < N; i++) {
        parent_hash[i] <== permute.out[i] + left[i];
    }
    for(var i = 0; i < 8 - N; i++) {
        parent_hash[i + N] <== permute.out[i + N];
    }
}

template test_decommit() {
    signal input queries_parent;
    signal input trace_siblings[18 * 8];
    signal input trace_root[8];

    signal input trace_left[3];
    signal input trace_right[3];

    component trace_hash = compute_parent_hash_no_more_than_8(3);
    trace_hash.left <== trace_left;
    trace_hash.right <== trace_right;

    signal input interaction_left[8];
    signal input interaction_right[8];

    component interaction_hash = compute_parent_hash_no_more_than_8(8);
    interaction_hash.left <== interaction_left;
    interaction_hash.right <== interaction_right;

    signal input constant_left[5];
    signal input constant_right[5];

    component constant_hash = compute_parent_hash_no_more_than_8(5);
    constant_hash.left <== constant_left;
    constant_hash.right <== constant_right;

    signal input composition_left[4];
    signal input composition_right[4];

    component composition_hash = compute_parent_hash_no_more_than_8(4);
    composition_hash.left <== composition_left;
    composition_hash.right <== composition_right;

    component trace = decommit(18);
    trace.queries_parent <== queries_parent;
    trace.parent_hash <== trace_hash.parent_hash;
    trace.siblings <== trace_siblings;
    trace.root <== trace_root;

    signal input interaction_siblings[18 * 8];
    signal input interaction_root[8];

    component interaction = decommit(18);
    interaction.queries_parent <== queries_parent;
    interaction.parent_hash <== interaction_hash.parent_hash;
    interaction.siblings <== interaction_siblings;
    interaction.root <== interaction_root;

    signal input constant_siblings[18 * 8];
    signal input constant_root[8];

    component constant = decommit(18);
    constant.queries_parent <== queries_parent;
    constant.parent_hash <== constant_hash.parent_hash;
    constant.siblings <== constant_siblings;
    constant.root <== constant_root;

    signal input composition_siblings[18 * 8];
    signal input composition_root[8];

    component composition = decommit(18);
    composition.queries_parent <== queries_parent;
    composition.parent_hash <== composition_hash.parent_hash;
    composition.siblings <== composition_siblings;
    composition.root <== composition_root;
}

component main = test_decommit();