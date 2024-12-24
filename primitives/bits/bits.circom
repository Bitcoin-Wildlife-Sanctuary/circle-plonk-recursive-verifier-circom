pragma circom 2.0.0;

template check_num_bits(N) {
    signal input a;

    signal bits[N];
    for(var i = 0; i < N; i++) {
        bits[i] <-- (a >> i) & 1;
    }

    signal bits_neg[N];
    for(var i = 0; i < N; i++) {
        bits_neg[i] <== 1 - bits[i];
    }

    for(var i = 0; i < N; i++) {
        bits[i] * bits_neg[i] === 0;
    }

    signal sum[N];
    sum[0] <== bits[0];
    for(var i = 1; i < N; i++) {
        sum[i] <== sum[i-1] + bits[i] * (1 << i);
    }

    sum[N - 1] === a;
}
