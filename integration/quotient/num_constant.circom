pragma circom 2.0.0

include "apply_column_line_coeffs.circom";

template compute_num_constant() {
    signal input y;

    signal input mult_l;
    signal input mult_r;

    signal input a_wire_l;
    signal input a_wire_r;

    signal input b_wire_l;
    signal input b_wire_r;

    signal input c_wire_l;
    signal input c_wire_r;

    signal input op_l;
    signal input op_r;

    signal input coeffs_constant_mult_a[2];
    signal input coeffs_constant_mult_b[2];

    signal input coeffs_constant_a_wire_a[2];
    signal input coeffs_constant_a_wire_b[2];

    signal input coeffs_constant_b_wire_a[2];
    signal input coeffs_constant_b_wire_b[2];

    signal input coeffs_constant_c_wire_a[2];
    signal input coeffs_constant_c_wire_b[2];

    signal input coeffs_constant_op_a[2];
    signal input coeffs_constant_op_b[2];

    signal input alpha[4];

    component num_constant_mult = apply_column_line_coeffs();
    num_constant_mult.z_y <== y;
    num_constant_mult.queried_value_for_z <== mult_l;
    num_constant_mult.queried_value_for_conjugated_z <== mult_r;
    num_constant_mult.a <== coeffs_constant_mult_a;
    num_constant_mult.b <== coeffs_constant_mult_b;

    component num_constant_a_wire = apply_column_line_coeffs();
    num_constant_a_wire.z_y <== y;
    num_constant_a_wire.queried_value_for_z <== a_wire_l;
    num_constant_a_wire.queried_value_for_conjugated_z <== a_wire_r;
    num_constant_a_wire.a <== coeffs_constant_a_wire_a;
    num_constant_a_wire.b <== coeffs_constant_a_wire_b;

    component num_constant_b_wire = apply_column_line_coeffs();
    num_constant_b_wire.z_y <== y;
    num_constant_b_wire.queried_value_for_z <== b_wire_l;
    num_constant_b_wire.queried_value_for_conjugated_z <== b_wire_r;
    num_constant_b_wire.a <== coeffs_constant_b_wire_a;
    num_constant_b_wire.b <== coeffs_constant_b_wire_b;

    component num_constant_c_wire = apply_column_line_coeffs();
    num_constant_c_wire.z_y <== y;
    num_constant_c_wire.queried_value_for_z <== c_wire_l;
    num_constant_c_wire.queried_value_for_conjugated_z <== c_wire_r;
    num_constant_c_wire.a <== coeffs_constant_c_wire_a;
    num_constant_c_wire.b <== coeffs_constant_c_wire_b;

    component num_constant_op = apply_column_line_coeffs();
    num_constant_op.z_y <== y;
    num_constant_op.queried_value_for_z <== op_l;
    num_constant_op.queried_value_for_conjugated_z <== op_r;
    num_constant_op.a <== coeffs_constant_op_a;
    num_constant_op.b <== coeffs_constant_op_b;

    component alpha2 = qm31_mul();
    alpha2.a <== alpha;
    alpha2.b <== alpha;

    component alpha3 = qm31_mul();
    alpha3.a <== alpha2.out;
    alpha3.b <== alpha;

    component alpha4 = qm31_mul();
    alpha4.a <== alpha2.out;
    alpha4.b <== alpha2.out;

    component alpha8 = qm31_mul();
    alpha8.a <== alpha4.out;
    alpha8.b <== alpha4.out;

    component l_m1 = qm31_mul_cm31();
    l_m1.a <== alpha4.out;
    l_m1.b <== num_constant_mult.res_z;

    component l_m2 = qm31_mul_cm31();
    l_m2.a <== alpha3.out;
    l_m2.b <== num_constant_a_wire.res_z;

    component l_m3 = qm31_mul_cm31();
    l_m3.a <== alpha2.out;
    l_m3.b <== num_constant_b_wire.res_z;

    component l_m4 = qm31_mul_cm31();
    l_m4.a <== alpha;
    l_m4.b <== num_constant_c_wire.res_z;

    component l_s1 = qm31_add();
    l_s1.a <== l_m1.out;
    l_s1.b <== l_m2.out;

    component l_s2 = qm31_add();
    l_s2.a <== l_s1.out;
    l_s2.b <== l_m3.out;

    component l_s3 = qm31_add();
    l_s3.a <== l_s2.out;
    l_s3.b <== l_m4.out;

    component l_s4 = qm31_add_cm31();
    l_s4.a <== l_s3.out;
    l_s4.b <== num_constant_op.res_z;

    component r_m1 = qm31_mul_cm31();
    r_m1.a <== alpha4.out;
    r_m1.b <== num_constant_mult.res_conjugated_z;

    component r_m2 = qm31_mul_cm31();
    r_m2.a <== alpha3.out;
    r_m2.b <== num_constant_a_wire.res_conjugated_z;

    component r_m3 = qm31_mul_cm31();
    r_m3.a <== alpha2.out;
    r_m3.b <== num_constant_b_wire.res_conjugated_z;

    component r_m4 = qm31_mul_cm31();
    r_m4.a <== alpha;
    r_m4.b <== num_constant_c_wire.res_conjugated_z;

    component r_s1 = qm31_add();
    r_s1.a <== r_m1.out;
    r_s1.b <== r_m2.out;

    component r_s2 = qm31_add();
    r_s2.a <== r_s1.out;
    r_s2.b <== r_m3.out;

    component r_s3 = qm31_add();
    r_s3.a <== r_s2.out;
    r_s3.b <== r_m4.out;

    component r_s4 = qm31_add_cm31();
    r_s4.a <== r_s3.out;
    r_s4.b <== num_constant_op.res_conjugated_z;

    component alpha8_constant_l = qm31_mul();
    alpha8_constant_l.a <== alpha8.out;
    alpha8_constant_l.b <== l_s4.out;

    component alpha8_constant_r = qm31_mul();
    alpha8_constant_r.a <== alpha8.out;
    alpha8_constant_r.b <== r_s4.out;

    signal output num_constant_l[4];
    num_constant_l <== alpha8_constant_l.out;

    signal output num_constant_r[4];
    num_constant_r <== alpha8_constant_r.out;
}