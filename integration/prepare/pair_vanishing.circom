pragma circom 2.0.0;

include "../../primitives/circle/curve.circom";

template prepare_pair_vanishing_individual() {
    signal input x[4];
    signal input y[4];
    signal output a[2];
    signal output b[2];

    signal x_first[2];
    x_first[0] <== x[0];
    x_first[1] <== x[1];

    signal x_second[2];
    x_second[0] <== x[2];
    x_second[1] <== x[3];

    signal y_first[2];
    y_first[0] <== y[0];
    y_first[1] <== y[1];

    signal y_second[2];
    y_second[0] <== y[2];
    y_second[1] <== y[3];

    component y_second_inv = cm31_inv();
    y_second_inv.a <== y_second;

    component x_second_div_y_second = cm31_mul();
    x_second_div_y_second.a <== x_second;
    x_second_div_y_second.b <== y_second_inv.out;

    component cross_term_s1 = cm31_mul();
    cross_term_s1.a <== x_second_div_y_second.out;
    cross_term_s1.b <== y_first;

    component cross_term = cm31_sub();
    cross_term.a <== cross_term_s1.out;
    cross_term.b <== x_first;

    a <== x_second_div_y_second.out;
    b <== cross_term.out;
}

template prepare_pair_vanishing() {
    signal input oods_x[4];
    signal input oods_y[4];

    signal output oods_pair_vanishing_a[2];
    signal output oods_pair_vanishing_b[2];

    component prepare_pair_vanishing_oods = prepare_pair_vanishing_individual();
    prepare_pair_vanishing_oods.x <== oods_x;
    prepare_pair_vanishing_oods.y <== oods_y;
    oods_pair_vanishing_a <== prepare_pair_vanishing_oods.a;
    oods_pair_vanishing_b <== prepare_pair_vanishing_oods.b;

    component shift_minus_1 = circle_point_minus_1(13);
    component oods_shifted_c = circle_point_add_m31();
    oods_shifted_c.x1 <== oods_x;
    oods_shifted_c.y1 <== oods_y;
    oods_shifted_c.x2 <== shift_minus_1.x;
    oods_shifted_c.y2 <== shift_minus_1.y;

    signal output oods_shifted_pair_vanishing_a[2];
    signal output oods_shifted_pair_vanishing_b[2];

    component prepare_pair_vanishing_oods_shifted = prepare_pair_vanishing_individual();
    prepare_pair_vanishing_oods_shifted.x <== oods_shifted_c.out_x;
    prepare_pair_vanishing_oods_shifted.y <== oods_shifted_c.out_y;
    oods_shifted_pair_vanishing_a <== prepare_pair_vanishing_oods_shifted.a;
    oods_shifted_pair_vanishing_b <== prepare_pair_vanishing_oods_shifted.b;
}