pragma circom 2.0.0;

template circle_point_from_t() {
    signal input t[4];
    signal output x[4];
    signal output y[4];

    component t_doubled = qm31_add();
    t_doubled.a <== t;
    t_doubled.b <== t;

    component t_squared = qm31_mul();
    t_squared.a <== t;
    t_squared.b <== t;

    signal t_squared_plus_1[4];
    t_squared_plus_1[0] <== t_squared.out[0] + 1;
    t_squared_plus_1[1] <== t_squared.out[1];
    t_squared_plus_1[2] <== t_squared.out[2];
    t_squared_plus_1[3] <== t_squared.out[3];

    component t_squared_plus_1_inverse = qm31_inv();
    t_squared_plus_1_inverse.a <== t_squared_plus_1;

    signal one_minus_t_squared_minus[4];
    one_minus_t_squared_minus[0] <== 1 - t_squared.out[0];
    one_minus_t_squared_minus[1] <== -t_squared.out[1];
    one_minus_t_squared_minus[2] <== -t_squared.out[2];
    one_minus_t_squared_minus[3] <== -t_squared.out[3];

    component compute_x = qm31_mul();
    compute_x.a <== one_minus_t_squared_minus;
    compute_x.b <== t_squared_plus_1_inverse.out;
    x <== compute_x.out;

    component compute_y = qm31_mul();
    compute_y.a <== t_doubled.out;
    compute_y.b <== t_squared_plus_1_inverse.out;
    y <== compute_y.out;
}

template circle_point_minus_1(N) {
    var shift_minus_1[31][2] = [
        [0, 0], // 0, undefined
        [2147483646, 0],
        [0, 1],
        [32768, 32768],
        [590768354, 1168891274],
        [1179735656, 906276279],
        [579625837, 456695729],
        [838195206, 373229752],
        [785043271, 886732674],
        [13610297, 1082787046],
        [1434706457, 311689836],
        [996212859, 1006487271],
        [2015554631, 1059389700],
        [1420207432, 124245130],
        [1330239767, 701114069],
        [1543902459, 515154224],
        [1389168750, 1308592621],
        [438833264, 820464519],
        [1799120754, 1803884779],
        [595037635, 35941196],
        [1633461177, 1573187080],
        [1022251061, 1359389136],
        [6346213, 1241959954],
        [421007138, 1891305787],
        [212706801, 923663760],
        [2042371533, 785218351],
        [334835419, 702516331],
        [708158977, 1464297727],
        [18817, 427150433],
        [97, 2005781910],
        [7, 1370403649]
    ];

    signal output x;
    signal output y;

    x <== shift_minus_1[N][0];
    y <== shift_minus_1[N][1];
}

template circle_point_add_m31() {
    signal input x1[4];
    signal input y1[4];

    signal input x2;
    signal input y2;

    signal output out_x[4];
    signal output out_y[4];

    component x1x2 = qm31_mul_m31();
    x1x2.a <== x1;
    x1x2.b <== x2;

    component y1y2 = qm31_mul_m31();
    y1y2.a <== y1;
    y1y2.b <== y2;

    component x1y2 = qm31_mul_m31();
    x1y2.a <== x1;
    x1y2.b <== y2;

    component y1x2 = qm31_mul_m31();
    y1x2.a <== y1;
    y1x2.b <== x2;

    component out_x_c = qm31_sub();
    out_x_c.a <== x1x2.out;
    out_x_c.b <== y1y2.out;
    out_x <== out_x_c.out;

    component out_y_c = qm31_add();
    out_y_c.a <== x1y2.out;
    out_y_c.b <== y1x2.out;
    out_y <== out_y_c.out;
}