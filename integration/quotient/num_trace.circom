pragma circom 2.0.0;

include "apply_column_line_coeffs.circom";
include "../../primitives/circle/fields.circom";

template compute_num_trace() {
    signal input y;

    signal input a_val_l;
    signal input a_val_r;

    signal input b_val_l;
    signal input b_val_r;

    signal input c_val_l;
    signal input c_val_r;

    signal input coeffs_trace_a_val_a[2];
    signal input coeffs_trace_a_val_b[2];

    signal input coeffs_trace_b_val_a[2];
    signal input coeffs_trace_b_val_b[2];

    signal input coeffs_trace_c_val_a[2];
    signal input coeffs_trace_c_val_b[2];

    signal input alpha[4];

    component num_trace_a_val = apply_column_line_coeffs();
    num_trace_a_val.z_y <== y;
    num_trace_a_val.queried_value_for_z <== a_val_l;
    num_trace_a_val.queried_value_for_conjugated_z <== a_val_r;
    num_trace_a_val.a <== coeffs_trace_a_val_a;
    num_trace_a_val.b <== coeffs_trace_a_val_b;

    component num_trace_b_val = apply_column_line_coeffs();
    num_trace_b_val.z_y <== y;
    num_trace_b_val.queried_value_for_z <== b_val_l;
    num_trace_b_val.queried_value_for_conjugated_z <== b_val_r;
    num_trace_b_val.a <== coeffs_trace_b_val_a;
    num_trace_b_val.b <== coeffs_trace_b_val_b;

    component num_trace_c_val = apply_column_line_coeffs();
    num_trace_c_val.z_y <== y;
    num_trace_c_val.queried_value_for_z <== c_val_l;
    num_trace_c_val.queried_value_for_conjugated_z <== c_val_r;
    num_trace_c_val.a <== coeffs_trace_c_val_a;
    num_trace_c_val.b <== coeffs_trace_c_val_b;

    component alpha2 = qm31_mul();
    alpha2.a <== alpha;
    alpha2.b <== alpha;

    component alpha4 = qm31_mul();
    alpha4.a <== alpha2.out;
    alpha4.b <== alpha2.out;

    component alpha8 = qm31_mul();
    alpha8.a <== alpha4.out;
    alpha8.b <== alpha4.out;

    component alpha16 = qm31_mul();
    alpha16.a <== alpha8.out;
    alpha16.b <== alpha8.out;

    component alpha20 = qm31_mul();
    alpha20.a <== alpha16.out;
    alpha20.b <== alpha4.out;

    component alpha21 = qm31_mul();
    alpha21.a <== alpha20.out;
    alpha21.b <== alpha;

    component l_m1 = qm31_mul_cm31();
    l_m1.a <== alpha2.out;
    l_m1.b <== num_trace_a_val.res_z;

    component l_m2 = qm31_mul_cm31();
    l_m2.a <== alpha;
    l_m2.b <== num_trace_b_val.res_z;

    component l_s1 = qm31_add();
    l_s1.a <== l_m1.out;
    l_s1.b <== l_m2.out;

    component l_s2 = qm31_add_cm31();
    l_s2.a <== l_s1.out;
    l_s2.b <== num_trace_c_val.res_z;

    component r_m1 = qm31_mul_cm31();
    r_m1.a <== alpha2.out;
    r_m1.b <== num_trace_a_val.res_conjugated_z;

    component r_m2 = qm31_mul_cm31();
    r_m2.a <== alpha;
    r_m2.b <== num_trace_b_val.res_conjugated_z;

    component r_s1 = qm31_add();
    r_s1.a <== r_m1.out;
    r_s1.b <== r_m2.out;

    component r_s2 = qm31_add_cm31();
    r_s2.a <== r_s1.out;
    r_s2.b <== num_trace_c_val.res_conjugated_z;

    component alpha21_trace_l = qm31_mul();
    alpha21_trace_l.a <== alpha21.out;
    alpha21_trace_l.b <== l_s2.out;

    component alpha21_trace_r = qm31_mul();
    alpha21_trace_r.a <== alpha21.out;
    alpha21_trace_r.b <== r_s2.out;

    signal output num_trace_l[4];
    num_trace_l <== alpha21_trace_l.out;

    signal output num_trace_r[4];
    num_trace_r <== alpha21_trace_r.out;
}