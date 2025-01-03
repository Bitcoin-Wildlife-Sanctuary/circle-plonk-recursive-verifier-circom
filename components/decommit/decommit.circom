pragma circom 2.0.0;

include "../../primitives/merkle/merkle.circom";

template merkle_decommit(D) {
    signal input query;
    signal input parent_hash[8];
    signal input siblings[D * 8];
    signal input root[8];

    component merkle = verify_merkle_path(D);
    merkle.idx <== query;
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

template decommit(N, L) {
    signal input query;
    signal input trace_siblings[(N + L) * 8];
    signal input trace_root[8];

    signal input trace_l[3];
    signal input trace_r[3];

    component trace_hash = compute_parent_hash_no_more_than_8(3);
    trace_hash.left <== trace_l;
    trace_hash.right <== trace_r;

    signal input interaction_l[8];
    signal input interaction_r[8];

    component interaction_hash = compute_parent_hash_no_more_than_8(8);
    interaction_hash.left <== interaction_l;
    interaction_hash.right <== interaction_r;

    signal input constant_l[5];
    signal input constant_r[5];

    component constant_hash = compute_parent_hash_no_more_than_8(5);
    constant_hash.left <== constant_l;
    constant_hash.right <== constant_r;

    signal input composition_l[4];
    signal input composition_r[4];

    component composition_hash = compute_parent_hash_no_more_than_8(4);
    composition_hash.left <== composition_l;
    composition_hash.right <== composition_r;

    component trace = merkle_decommit(N + L);
    trace.query <== query;
    trace.parent_hash <== trace_hash.parent_hash;
    trace.siblings <== trace_siblings;
    trace.root <== trace_root;

    signal input interaction_siblings[(N + L) * 8];
    signal input interaction_root[8];

    component interaction = merkle_decommit(N + L);
    interaction.query <== query;
    interaction.parent_hash <== interaction_hash.parent_hash;
    interaction.siblings <== interaction_siblings;
    interaction.root <== interaction_root;

    signal input constant_siblings[(N + L) * 8];
    signal input constant_root[8];

    component constant = merkle_decommit(N + L);
    constant.query <== query;
    constant.parent_hash <== constant_hash.parent_hash;
    constant.siblings <== constant_siblings;
    constant.root <== constant_root;

    signal input composition_siblings[(N + L) * 8];
    signal input composition_root[8];

    component composition = merkle_decommit(N + L);
    composition.query <== query;
    composition.parent_hash <== composition_hash.parent_hash;
    composition.siblings <== composition_siblings;
    composition.root <== composition_root;
}
