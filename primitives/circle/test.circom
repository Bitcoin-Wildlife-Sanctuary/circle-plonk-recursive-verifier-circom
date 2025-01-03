pragma circom 2.0.0;

include "curve.circom";
include "fields.circom";

template test_fields() {
    signal input a[4];
    signal input b[4];
    signal input a_plus_b[4];
    signal input a_minus_b[4];
    signal input a_times_b[4];
    signal input a_inv[4];
    signal input a_square[4];

    component s1 = qm31_add();
    s1.a <== a;
    s1.b <== b;
    s1.out === a_plus_b;

    component s2 = qm31_sub();
    s2.a <== a;
    s2.b <== b;
    s2.out === a_minus_b;

    component s3 = qm31_mul();
    s3.a <== a;
    s3.b <== b;
    s3.out === a_times_b;

    component s4 = qm31_inv();
    s4.a <== a;
    s4.out === a_inv;

    component s5 = qm31_mul();
    s5.a <== a;
    s5.b <== a;
    s5.out === a_square;

    signal input t[4];
    signal input x[4];
    signal input y[4];

    component compute_t = circle_point_from_t();
    compute_t.t <== t;
    compute_t.x === x;
    compute_t.y === y;

    component shift_1 = m31_subgroup_generator(15);

    component shifted_point_c = circle_point_sub_m31();
    shifted_point_c.x1 <== x;
    shifted_point_c.y1 <== y;
    shifted_point_c.x2 <== shift_1.x;
    shifted_point_c.y2 <== shift_1.y;

    signal input shifted_x[4];
    signal input shifted_y[4];

    shifted_x === shifted_point_c.out_x;
    shifted_y === shifted_point_c.out_y;

    component generator = m31_generator();

    signal input bits[128];

    component mul_by_bits = circle_point_m31_only_mul_by_bits(128);
    mul_by_bits.x <== generator.x;
    mul_by_bits.y <== generator.y;
    mul_by_bits.bits_le <== bits;

    signal input random_point_x;
    signal input random_point_y;

    random_point_x === mul_by_bits.out_x;
    random_point_y === mul_by_bits.out_y;
}

component main = test_fields();