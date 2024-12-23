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