pragma circom 2.0.0;

include "folding.circom";

template test_fold(N, L) {
    signal input l[4];
    signal input r[4];
    signal input y;
    signal input fri_fold_random_coeff[4];
    signal input f_prime[4];

    signal input query;
    signal input last_layer[4];
    signal input siblings[N * 4];
    signal input fri_alphas[N * 4];

    signal input fri_hashes[N * 8];
    signal input fri_siblings[(L + L + N - 1) * N * 4];

    component fold = full_fold(N, L);
    fold.l <== l;
    fold.r <== r;
    fold.y <== y;
    fold.fri_fold_random_coeff <== fri_fold_random_coeff;
    fold.query <== query;
    fold.last_layer <== last_layer;
    fold.siblings <== siblings;
    fold.fri_alphas <== fri_alphas;

    fold.fri_hashes <== fri_hashes;
    fold.fri_siblings <== fri_siblings;

    f_prime === fold.f_prime;
}

component main = test_fold(13, 5);