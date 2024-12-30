pragma circom 2.0.0

include "apply_column_line_coeffs.circom";

template compute_num_composition() {
    signal input y;

    signal input composition_0_l;
    signal input composition_0_r;

    signal input composition_1_l;
    signal input composition_1_r;

    signal input composition_2_l;
    signal input composition_2_r;

    signal input composition_3_l;
    signal input composition_3_r;

    signal input coeffs_composition_0_a[2];
    signal input coeffs_composition_0_b[2];

    signal input coeffs_composition_1_a[2];
    signal input coeffs_composition_1_b[2];

    signal input coeffs_composition_2_a[2];
    signal input coeffs_composition_2_b[2];

    signal input coeffs_composition_3_a[2];
    signal input coeffs_composition_3_b[2];

    signal input alpha[4];

    component num_composition_0 = apply_column_line_coeffs();
    num_composition_0.z_y <== y;
    num_composition_0.queried_value_for_z <== composition_0_l;
    num_composition_0.queried_value_for_z <== composition_0_r;
    num_composition_0.a <== coeffs_composition_0_a;
    num_composition_0.b <== coeffs_composition_0_b;

    component num_composition_1 = apply_column_line_coeffs();
    num_composition_1.z_y <== y;
    num_composition_1.queried_value_for_z <== composition_1_l;
    num_composition_1.queried_value_for_conjugated_z <== composition_1_r;
    num_composition_1.a <== coeffs_composition_1_a;
    num_composition_1.b <== coeffs_composition_1_b;

    component num_composition_2 = apply_column_line_coeffs();
    num_composition_2.z_y <== y;
    num_composition_2.queried_value_for_z <== composition_2_l;
    num_composition_2.queried_value_for_conjugated_z <== composition_2_r;
    num_composition_2.a <== coeffs_composition_2_a;
    num_composition_2.b <== coeffs_composition_2_b;

    component num_composition_3 = apply_column_line_coeffs();
    num_composition_3.z_y <== y;
    num_composition_3.queried_value_for_z <== composition_3_l;
    num_composition_3.queried_value_for_conjugated_z <== composition_3_r;
    num_composition_3.a <== coeffs_composition_3_a;
    num_composition_3.b <== coeffs_composition_3_b;

    component alpha2 = qm31_mul();
    alpha2.a <== alpha;
    alpha2.b <== alpha;

    component alpha3 = qm31_mul();
    alpha3.a <== alpha2.out;
    alpha3.b <== alpha;

    component alpha4 = qm31_mul();
    alpha4.a <== alpha2.out;
    alpha4.b <== alpha2.out;

    component l_m1 = qm31_mul_cm31();
    l_m1.a <== alpha3;
    l_m1.b <== num_composition_0.res_z;

    component l_m2 = qm31_mul_cm31();
    l_m2.a <== alpha2;
    l_m2.b <== num_composition_1.res_z;

    component l_m3 = qm31_mul_cm31();
    l_m3.a <== alpha;
    l_m3.b <== num_composition_2.res_z;

    component l_s1 = qm31_add();
    l_s1.a <== l_m1.out;
    l_s1.b <== l_m2.out;

    component l_s2 = qm31_add();
    l_s2.a <== l_s1.out;
    l_s2.b <== l_m3.out;

    component l_s3 = qm31_add_cm31();
    l_s3.a <== l_s2.out;
    l_s3.b <== num_composition_3.res_z;

    component r_m1 = qm31_mul_cm31();
    r_m1.a <== alpha3;
    r_m1.b <== num_composition_0.res_conjugated_z;

    component r_m2 = qm31_mul_cm31();
    r_m2.a <== alpha2;
    r_m2.b <== num_composition_1.res_conjugated_z;

    component r_m3 = qm31_mul_cm31();
    r_m3.a <== alpha;
    r_m3.b <== num_composition_2.res_conjugated_z;

    component r_s1 = qm31_add();
    r_s1.a <== r_m1.out;
    r_s1.b <== r_m2.out;

    component r_s2 = qm31_add();
    r_s2.a <== r_s1.out;
    r_s2.b <== r_m3.out;

    component r_s3 = qm31_add_cm31();
    r_s3.a <== r_s2.out;
    r_s3.b <== num_composition_3.res_conjugated_z;

    component alpha4_composition_l = qm31_mul();
    alpha4_composition_l.a <== alpha4.out;
    alpha4_composition_l.b <== l_s3.out;

    component alpha4_composition_r = qm31_mul();
    alpha4_composition_r.a <== alpha4.out;
    alpha4_composition_r.b <== r_s3.out;

    signal output num_composition_l[4];
    num_composition_l <== alpha4_composition_l.out;

    signal output num_composition_r[4];
    num_composition_r <== alpha4_composition_r.out;
}