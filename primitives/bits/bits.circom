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

template get_lower_bits_checked(N) {
    signal input in;
    signal output out;

    signal high_bits;
    high_bits <-- in >> N;

    component check_high_bits = check_num_bits(31 - N);
    check_high_bits.a <== high_bits;

    signal high_bits_shifted;
    high_bits_shifted <== high_bits * (1 << N);

    out <== in - high_bits_shifted;

    component check_low_bits = check_num_bits(N);
    check_low_bits.a <== out;

    signal high_bits_minus_all_1;
    high_bits_minus_all_1 <== high_bits - ((1 << (31 - N)) - 1);

    component is_high_bits_all_1 = is_zero();
    is_high_bits_all_1.in <== high_bits_minus_all_1;

    signal low_bits_minus_all_1;
    low_bits_minus_all_1 <== out - ((1 << N) - 1);

    component is_low_bits_all_1 = is_zero();
    is_low_bits_all_1.in <== low_bits_minus_all_1;

    is_high_bits_all_1.out * is_low_bits_all_1.out === 0;
}

// from https://docs.circom.io/circom-language/basic-operators/#examples-using-operators-from-the-circom-library
template is_zero() {
    signal input in;
    signal output out;
    signal inv;

    inv <-- in!=0 ? 1/in : 0;
    out <== -in*inv +1;
    in*out === 0;
}

template decompose_into_bits(N) {
    signal input a;
    signal output bits[N];

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