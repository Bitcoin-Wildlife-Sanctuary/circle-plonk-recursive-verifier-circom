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

template circle_point_sub_m31() {
    signal input x1[4];
    signal input y1[4];

    signal input x2;
    signal input y2;

    signal output out_x[4];
    signal output out_y[4];

    component cur = circle_point_add_m31();
    cur.x1 <== x1;
    cur.y1 <== y1;
    cur.x2 <== x2;
    cur.y2 <== -y2;

    out_x <== cur.out_x;
    out_y <== cur.out_y;
}

template circle_point_m31_only_add() {
    signal input x1;
    signal input y1;

    signal input x2;
    signal input y2;

    signal x1x2 <== x1 * x2;
    signal y1y2 <== y1 * y2;
    signal x1y2 <== x1 * y2;
    signal y1x2 <== x2 * y1;

    signal output out_x;
    signal output out_y;

    out_x <== x1x2 - y1y2;
    out_y <== x1y2 + y1x2;
}

template circle_point_m31_only_add_x_only() {
    signal input x1;
    signal input y1;

    signal input x2;
    signal input y2;

    signal x1x2 <== x1 * x2;
    signal y1y2 <== y1 * y2;

    signal output out_x;
    out_x <== x1x2 - y1y2;
}

template circle_point_m31_only_double() {
    signal input x;
    signal input y;

    signal output out_x;
    signal output out_y;

    signal x_squared <== 2 * x * x;
    out_x <== x_squared - 1;
    out_y <== 2 * x * y;
}

template circle_point_m31_only_select() {
    signal input x0;
    signal input y0;

    signal input x1;
    signal input y1;

    signal input bit;

    signal output out_x;
    signal output out_y;

    signal t1 <== bit * (x1 - x0);
    out_x <== t1 + x0;

    signal t2 <== bit * (y1 - y0);
    out_y <== t2 + y0;
}

template circle_point_m31_only_mul_by_bits(N) {
    signal input x;
    signal input y;

    signal input bits_le[N];

    signal powers_x[N];
    signal powers_y[N];

    powers_x[0] <== x;
    powers_y[0] <== y;

    component doubling[N - 1];
    for(var i = 1; i < N; i++) {
        doubling[i - 1] = circle_point_m31_only_double();
        doubling[i - 1].x <== powers_x[i - 1];
        doubling[i - 1].y <== powers_y[i - 1];
        powers_x[i] <== doubling[i - 1].out_x;
        powers_y[i] <== doubling[i - 1].out_y;
    }

    component select[N];

    select[0] = circle_point_m31_only_select();
    select[0].x0 <== 1;
    select[0].y0 <== 0;
    select[0].x1 <== powers_x[0];
    select[0].y1 <== powers_y[0];
    select[0].bit <== bits_le[0];

    component adding[N - 1];
    for(var i = 1; i < N; i++) {
        adding[i - 1] = circle_point_m31_only_add();
        adding[i - 1].x1 <== select[i - 1].out_x;
        adding[i - 1].y1 <== select[i - 1].out_y;
        adding[i - 1].x2 <== powers_x[i];
        adding[i - 1].y2 <== powers_y[i];

        select[i] = circle_point_m31_only_select();
        select[i].x0 <== select[i - 1].out_x;
        select[i].y0 <== select[i - 1].out_y;
        select[i].x1 <== adding[i - 1].out_x;
        select[i].y1 <== adding[i - 1].out_y;
        select[i].bit <== bits_le[i];
    }

    signal output out_x;
    signal output out_y;

    out_x <== select[N - 1].out_x;
    out_y <== select[N - 1].out_y;
}

template m31_generator() {
    component cur = m31_subgroup_generator(31);

    signal output x <== cur.x;
    signal output y <== cur.y;
}

template m31_subgroup_generator(N) {
    var subgroup[32][2] = [
        [1, 0],
        [2147483646, 0],
        [0, 2147483646],
        [32768, 2147450879],
        [590768354, 978592373],
        [1179735656, 1241207368],
        [579625837, 1690787918],
        [838195206, 1774253895],
        [785043271, 1260750973],
        [13610297, 1064696601],
        [1434706457, 1835793811],
        [996212859, 1140996376],
        [2015554631, 1088093947],
        [1420207432, 2023238517],
        [1330239767, 1446369578],
        [1543902459, 1632329423],
        [1389168750, 838891026],
        [438833264, 1327019128],
        [1799120754, 343598868],
        [595037635, 2111542451],
        [1633461177, 574296567],
        [1022251061, 788094511],
        [6346213, 905523693],
        [421007138, 256177860],
        [212706801, 1223819887],
        [2042371533, 1362265296],
        [334835419, 1444967316],
        [708158977, 683185920],
        [18817, 1720333214],
        [97, 141701737],
        [7, 777079998],
        [2, 1268011823]
    ];

    signal output x;
    signal output y;

    x <== subgroup[N][0];
    y <== subgroup[N][1];
}