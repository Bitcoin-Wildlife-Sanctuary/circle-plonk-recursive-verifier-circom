pragma circom 2.0.0;

include "../../primitives/bits/bits.circom";
include "../../primitives/circle/curve.circom";
include "../../primitives/circle/fields.circom";

template initial_fold() {
    signal input l[4];
    signal input r[4];
    signal input y;
    signal input fri_fold_random_coeff[4];

    component y_inverse = m31_inv();
    y_inverse.in <== y;

    component f0_px = qm31_add();
    f0_px.a <== l;
    f0_px.b <== r;

    component f1_px_p1 = qm31_sub();
    f1_px_p1.a <== l;
    f1_px_p1.b <== r;

    component f1_px = qm31_mul_m31();
    f1_px.a <== f1_px_p1.out;
    f1_px.b <== y_inverse.out;

    component alpha_times_f1_px = qm31_mul();
    alpha_times_f1_px.a <== fri_fold_random_coeff;
    alpha_times_f1_px.b <== f1_px.out;

    component f_prime = qm31_add();
    f_prime.a <== alpha_times_f1_px.out;
    f_prime.b <== f0_px.out;

    signal output res[4];
    res <== f_prime.out;
}

template fri_fold(N, L) {
    // N is the log of the number of rows
    // L is the negative log of the rate

    signal input query_parent;

    component bits = decompose_into_bits(N + L);
    bits.a <== query_parent;

    signal input siblings[N][4];
    signal input fri_alphas[N][4];

    signal input f_prime[4];
    signal input last_layer[4];

    signal prev_results[N + 1][4];
    prev_results[0] <== f_prime;

    component add[N];
    component sub[N];
    component cond_neg[N];
    component start[N];
    component step[N];
    component scalar_mul[N];
    component point_add[N];
    component inv[N];
    component f1[N];
    component f1_times_alpha[N];
    component calc_f_prime[N];
    for(var i = 0; i < N; i++) {
        add[i] = qm31_add();
        add[i].a <== prev_results[i];
        add[i].b <== siblings[i];

        sub[i] = qm31_sub();
        sub[i].a <== prev_results[i];
        sub[i].b <== siblings[i];

        cond_neg[i] = qm31_cond_neg();
        cond_neg[i].a <== sub[i].out;
        cond_neg[i].bit <== bits.bits[i];

        start[i] = m31_subgroup_generator(N + L + 2 - i);
        step[i] = m31_subgroup_generator(N + L - i);

        var ll = N + L - 1 - i;
        scalar_mul[i] = circle_point_m31_only_mul_by_bits(ll);
        scalar_mul[i].x <== step[i].x;
        scalar_mul[i].y <== step[i].y;
        for(var j = 0; j < ll; j++) {
            scalar_mul[i].bits_le[j] <== bits.bits[N + L - 1 - j];
        }

        point_add[i] = circle_point_m31_only_add_x_only();
        point_add[i].x1 <== start[i].x;
        point_add[i].y1 <== start[i].y;
        point_add[i].x2 <== scalar_mul[i].out_x;
        point_add[i].y2 <== scalar_mul[i].out_y;

        inv[i] = m31_inv();
        inv[i].in <== point_add[i].out_x;

        f1[i] = qm31_mul_m31();
        f1[i].a <== cond_neg[i].out;
        f1[i].b <== inv[i].out;

        f1_times_alpha[i] = qm31_mul();
        f1_times_alpha[i].a <== fri_alphas[i];
        f1_times_alpha[i].b <== f1[i].out;

        calc_f_prime[i] = qm31_add();
        calc_f_prime[i].a <== f1_times_alpha[i].out;
        calc_f_prime[i].b <== add[i].out;

        prev_results[i + 1] <== calc_f_prime[i].out;
    }

    last_layer === prev_results[N];
}

template test_fold(N, L) {
    signal input l[4];
    signal input r[4];
    signal input y;
    signal input fri_fold_random_coeff[4];
    signal input f_prime[4];

    component init = initial_fold();
    init.l <== l;
    init.r <== r;
    init.y <== y;
    init.fri_fold_random_coeff <== fri_fold_random_coeff;
    f_prime === init.res;

    signal input query_parent;
    signal input last_layer[4];
    signal input siblings[N * 4];
    signal input fri_alphas[N * 4];

    component fold = fri_fold(N, L);
    fold.f_prime <== init.res;
    fold.query_parent <== query_parent;
    fold.last_layer <== last_layer;
    for(var i = 0; i < N; i++) {
        fold.siblings[i][0] <== siblings[i * 4];
        fold.siblings[i][1] <== siblings[i * 4 + 1];
        fold.siblings[i][2] <== siblings[i * 4 + 2];
        fold.siblings[i][3] <== siblings[i * 4 + 3];
    }
    for(var i = 0; i < N; i++) {
        fold.fri_alphas[i][0] <== fri_alphas[i * 4];
        fold.fri_alphas[i][1] <== fri_alphas[i * 4 + 1];
        fold.fri_alphas[i][2] <== fri_alphas[i * 4 + 2];
        fold.fri_alphas[i][3] <== fri_alphas[i * 4 + 3];
    }
}

component main { public [
    query_parent,
    l, r, y, fri_fold_random_coeff,
    f_prime, last_layer, siblings, fri_alphas
] } = test_fold(13, 5);