√

template compute_constraint_denom(N) {
    signal input x[4];

    signal t[N][4];
    t[0] <== x;

    component mul[N - 1];
    component dbl[N - 1];

    for(var i = 1; i < N; i++) {
        mul[i - 1] = qm31_mul();
        mul[i - 1].a <== t[i - 1];
        mul[i - 1].b <== t[i - 1];

        dbl[i - 1] = qm31_add();
        dbl[i - 1].a <== mul[i - 1].out;
        dbl[i - 1].b <== mul[i - 1].out;

        t[i][0] <== dbl[i - 1].out[0] - 1;
        t[i][1] <== dbl[i - 1].out[1];
        t[i][2] <== dbl[i - 1].out[2];
        t[i][3] <== dbl[i - 1].out[3];
    }

    component inv = qm31_inv();
    inv.a <== t[N - 1];

    signal output out[4];
    out <== inv.out;
}