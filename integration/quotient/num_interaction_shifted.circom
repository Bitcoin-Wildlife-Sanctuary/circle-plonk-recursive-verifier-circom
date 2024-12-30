pragma circom 2.0.0

include "apply_column_line_coeffs.circom";

template compute_num_interaction_shifted() {
    signal input shifted_y;

    signal input interaction_shifted_0_l;
    signal input interaction_shifted_0_r;

    signal input interaction_shifted_1_l;
    signal input interaction_shifted_1_r;

    signal input interaction_shifted_2_l;
    signal input interaction_shifted_2_r;

    signal input interaction_shifted_3_l;
    signal input interaction_shifted_3_r;

    signal input coeffs_interaction_shifted_0_a[2];
    signal input coeffs_interaction_shifted_0_b[2];

    signal input coeffs_interaction_shifted_1_a[2];
    signal input coeffs_interaction_shifted_1_b[2];

    signal input coeffs_interaction_shifted_2_a[2];
    signal input coeffs_interaction_shifted_2_b[2];

    signal input coeffs_interaction_shifted_3_a[2];
    signal input coeffs_interaction_shifted_3_b[2];

    signal input alpha[4];

    component num_interaction_shifted_0 = apply_column_line_coeffs();
    num_interaction_shifted_0.z_y <== shifted_y;
    num_interaction_shifted_0.queried_value_for_z <== interaction_shifted_0_l;
    num_interaction_shifted_0.queried_value_for_z <== interaction_shifted_0_r;
    num_interaction_shifted_0.a <== coeffs_interaction_shifted_0_a;
    num_interaction_shifted_0.b <== coeffs_interaction_shifted_0_b;

    component num_interaction_shifted_1 = apply_column_line_coeffs();
    num_interaction_shifted_1.z_y <== shifted_y;
    num_interaction_shifted_1.queried_value_for_z <== interaction_shifted_1_l;
    num_interaction_shifted_1.queried_value_for_z <== interaction_shifted_1_r;
    num_interaction_shifted_1.a <== coeffs_interaction_shifted_1_a;
    num_interaction_shifted_1.b <== coeffs_interaction_shifted_1_b;

    component num_interaction_shifted_2 = apply_column_line_coeffs();
    num_interaction_shifted_2.z_y <== shifted_y;
    num_interaction_shifted_2.queried_value_for_z <== interaction_shifted_2_l;
    num_interaction_shifted_2.queried_value_for_z <== interaction_shifted_2_r;
    num_interaction_shifted_2.a <== coeffs_interaction_shifted_2_a;
    num_interaction_shifted_2.b <== coeffs_interaction_shifted_2_b;

    component num_interaction_shifted_3 = apply_column_line_coeffs();
    num_interaction_shifted_3.z_y <== shifted_y;
    num_interaction_shifted_3.queried_value_for_z <== interaction_shifted_3_l;
    num_interaction_shifted_3.queried_value_for_z <== interaction_shifted_3_r;
    num_interaction_shifted_3.a <== coeffs_interaction_shifted_3_a;
    num_interaction_shifted_3.b <== coeffs_interaction_shifted_3_b;

    component alpha2 = qm31_mul();
    alpha2.a <== alpha;
    alpha2.b <== alpha;

    component alpha3 = qm31_mul();
    alpha3.a <== alpha2.out;
    alpha3.b <== alpha;

    component l_m1 = qm31_mul_cm31();
    l_m1.a <== alpha3.out;
    l_m1.b <== num_interaction_shifted_0.res_z;

    component l_m2 = qm31_mul_cm31();
    l_m2.a <== alpha2.out;
    l_m2.b <== num_interaction_shifted_1.res_z;

    component l_m3 = qm31_mul_cm31();
    l_m3.a <== alpha;
    l_m3.b <== num_interaction_shifted_2.res_z;

    component l_s1 = qm31_add();
    l_s1.a <== l_m1.out;
    l_s1.b <== l_m2.out;

    component l_s2 = qm31_add();
    l_s2.a <== l_s1.out;
    l_s2.b <== l_m3.out;

    component l_s3 = qm31_add_cm31();
    l_s3.a <== l_s2.out;
    l_s3.b <== num_interaction_shifted_3.res_z;

    component r_m1 = qm31_mul_cm31();
    r_m1.a <== alpha3.out;
    r_m1.b <== num_interaction_shifted_0.res_conjugated_z;

    component r_m2 = qm31_mul_cm31();
    r_m2.a <== alpha2.out;
    r_m2.b <== num_interaction_shifted_1.res_conjugated_z;

    component r_m3 = qm31_mul_cm31();
    r_m3.a <== alpha;
    r_m3.b <== num_interaction_shifted_2.res_conjugated_z;

    component r_s1 = qm31_add();
    r_s1.a <== r_m1.out;
    r_s1.b <== r_m2.out;

    component r_s2 = qm31_add();
    r_s2.a <== r_s1.out;
    r_s2.b <== r_m3.out;

    component r_s3 = qm31_add_cm31();
    r_s3.a <== r_s2.out;
    r_s3.b <== num_interaction_shifted_3.res_conjugated_z;

    signal output num_interaction_shifted_l[4];
    num_interaction_shifted_l <== l_s3.out;

    signal output num_interaction_shifted_r[4];
    num_interaction_shifted_r <== r_s3.out;
}