pragma circom 2.0.0

include "apply_column_line_coeffs.circom";

template compute_num_interaction() {
    signal input y;

    signal input interaction_ab_0_l;
    signal input interaction_ab_0_r;

    signal input interaction_ab_1_l;
    signal input interaction_ab_1_r;

    signal input interaction_ab_2_l;
    signal input interaction_ab_2_r;

    signal input interaction_ab_3_l;
    signal input interaction_ab_3_r;

    signal input interaction_sum_0_l;
    signal input interaction_sum_0_r;

    signal input interaction_sum_1_l;
    signal input interaction_sum_1_r;

    signal input interaction_sum_2_l;
    signal input interaction_sum_2_r;

    signal input interaction_sum_3_l;
    signal input interaction_sum_3_r;

    signal input coeffs_interaction_ab_0_a[2];
    signal input coeffs_interaction_ab_0_b[2];

    signal input coeffs_interaction_ab_1_a[2];
    signal input coeffs_interaction_ab_1_b[2];

    signal input coeffs_interaction_ab_2_a[2];
    signal input coeffs_interaction_ab_2_b[2];

    signal input coeffs_interaction_ab_3_a[2];
    signal input coeffs_interaction_ab_3_b[2];

    signal input coeffs_interaction_sum_0_a[2];
    signal input coeffs_interaction_sum_0_b[2];

    signal input coeffs_interaction_sum_1_a[2];
    signal input coeffs_interaction_sum_1_b[2];

    signal input coeffs_interaction_sum_2_a[2];
    signal input coeffs_interaction_sum_2_b[2];

    signal input coeffs_interaction_sum_3_a[2];
    signal input coeffs_interaction_sum_3_b[2];

    signal input alpha[4];

    component num_interaction_ab_0 = apply_column_line_coeffs();
    num_interaction_ab_0.z_y <== y;
    num_interaction_ab_0.queried_value_for_z <== interaction_ab_0_l;
    num_interaction_ab_0.queried_value_for_conjugated_z <== interaction_ab_0_r;
    num_interaction_ab_0.a <== coeffs_interaction_ab_0_a;
    num_interaction_ab_0.b <== coeffs_interaction_ab_0_b;

    component num_interaction_ab_1 = apply_column_line_coeffs();
    num_interaction_ab_1.z_y <== y;
    num_interaction_ab_1.queried_value_for_z <== interaction_ab_1_l;
    num_interaction_ab_1.queried_value_for_conjugated_z <== interaction_ab_1_r;
    num_interaction_ab_1.a <== coeffs_interaction_ab_1_a;
    num_interaction_ab_1.b <== coeffs_interaction_ab_1_b;

    component num_interaction_ab_2 = apply_column_line_coeffs();
    num_interaction_ab_2.z_y <== y;
    num_interaction_ab_2.queried_value_for_z <== interaction_ab_2_l;
    num_interaction_ab_2.queried_value_for_conjugated_z <== interaction_ab_2_r;
    num_interaction_ab_2.a <== coeffs_interaction_ab_2_a;
    num_interaction_ab_2.b <== coeffs_interaction_ab_2_b;

    component num_interaction_ab_3 = apply_column_line_coeffs();
    num_interaction_ab_3.z_y <== y;
    num_interaction_ab_3.queried_value_for_z <== interaction_ab_3_l;
    num_interaction_ab_3.queried_value_for_conjugated_z <== interaction_ab_3_r;
    num_interaction_ab_3.a <== coeffs_interaction_ab_3_a;
    num_interaction_ab_3.b <== coeffs_interaction_ab_3_b;

    component num_interaction_sum_0 = apply_column_line_coeffs();
    num_interaction_sum_0.z_y <== y;
    num_interaction_sum_0.queried_value_for_z <== interaction_sum_0_l;
    num_interaction_sum_0.queried_value_for_conjugated_z <== interaction_sum_0_r;
    num_interaction_sum_0.a <== coeffs_interaction_sum_0_a;
    num_interaction_sum_0.b <== coeffs_interaction_sum_0_b;

    component num_interaction_sum_1 = apply_column_line_coeffs();
    num_interaction_sum_1.z_y <== y;
    num_interaction_sum_1.queried_value_for_z <== interaction_sum_1_l;
    num_interaction_sum_1.queried_value_for_conjugated_z <== interaction_sum_1_r;
    num_interaction_sum_1.a <== coeffs_interaction_sum_1_a;
    num_interaction_sum_1.b <== coeffs_interaction_sum_1_b;

    component num_interaction_sum_2 = apply_column_line_coeffs();
    num_interaction_sum_2.z_y <== y;
    num_interaction_sum_2.queried_value_for_z <== interaction_sum_2_l;
    num_interaction_sum_2.queried_value_for_conjugated_z <== interaction_sum_2_r;
    num_interaction_sum_2.a <== coeffs_interaction_sum_2_a;
    num_interaction_sum_2.b <== coeffs_interaction_sum_2_b;

    component num_interaction_sum_3 = apply_column_line_coeffs();
    num_interaction_sum_3.z_y <== y;
    num_interaction_sum_3.queried_value_for_z <== interaction_sum_3_l;
    num_interaction_sum_3.queried_value_for_conjugated_z <== interaction_sum_3_r;
    num_interaction_sum_3.a <== coeffs_interaction_sum_3_a;
    num_interaction_sum_3.b <== coeffs_interaction_sum_3_b;

    component alpha2 = qm31_mul();
    alpha2.a <== alpha;
    alpha2.b <== alpha;

    component alpha3 = qm31_mul();
    alpha3.a <== alpha2.out;
    alpha3.b <== alpha;

    component alpha4 = qm31_mul();
    alpha4.a <== alpha2.out;
    alpha4.b <== alpha2.out;

    component alpha5 = qm31_mul();
    alpha5.a <== alpha3.out;
    alpha5.b <== alpha2.out;

    component alpha6 = qm31_mul();
    alpha6.a <== alpha3.out;
    alpha6.b <== alpha3.out;

    component alpha7 = qm31_mul();
    alpha7.a <== alpha4.out;
    alpha7.b <== alpha3.out;

    component alpha8 = qm31_mul();
    alpha8.a <== alpha4.out;
    alpha8.b <== alpha4.out;

    component l_m1 = qm31_mul_cm31();
    l_m1.a <== alpha7.out;
    l_m1.b <== num_interaction_ab_0.res_z;

    component l_m2 = qm31_mul_cm31();
    l_m2.a <== alpha6.out;
    l_m2.b <== num_interaction_ab_1.res_z;

    component l_m3 = qm31_mul_cm31();
    l_m3.a <== alpha5.out;
    l_m3.b <== num_interaction_ab_2.res_z;

    component l_m4 = qm31_mul_cm31();
    l_m4.a <== alpha4.out;
    l_m4.b <== num_interaction_ab_3.res_z;

    component l_m5 = qm31_mul_cm31();
    l_m5.a <== alpha3.out;
    l_m5.b <== num_interaction_sum_0.res_z;

    component l_m6 = qm31_mul_cm31();
    l_m6.a <== alpha2.out;
    l_m6.b <== num_interaction_sum_1.res_z;

    component l_m7 = qm31_mul_cm31();
    l_m7.a <== alpha;
    l_m7.b <== num_interaction_sum_2.res_z;

    component l_s1 = qm31_add();
    l_s1.a <== l_m1.out;
    l_s1.b <== l_m2.out;

    component l_s2 = qm31_add();
    l_s2.a <== l_s1.out;
    l_s2.b <== l_m3.out;

    component l_s3 = qm31_add();
    l_s3.a <== l_s2.out;
    l_s3.b <== l_m4.out;

    component l_s4 = qm31_add();
    l_s4.a <== l_s3.out;
    l_s4.b <== l_m5.out;

    component l_s5 = qm31_add();
    l_s5.a <== l_s4.out;
    l_s5.b <== l_m6.out;

    component l_s6 = qm31_add_cm31();
    l_s6.a <== l_s5.out;
    l_s6.b <== l_m7.out;

    component r_m1 = qm31_mul_cm31();
    r_m1.a <== alpha7.out;
    r_m1.b <== num_interaction_ab_0.res_conjugated_z;

    component r_m2 = qm31_mul_cm31();
    r_m2.a <== alpha6.out;
    r_m2.b <== num_interaction_ab_1.res_conjugated_z;

    component r_m3 = qm31_mul_cm31();
    r_m3.a <== alpha5.out;
    r_m3.b <== num_interaction_ab_2.res_conjugated_z;

    component r_m4 = qm31_mul_cm31();
    r_m4.a <== alpha4.out;
    r_m4.b <== num_interaction_ab_3.res_conjugated_z;

    component r_m5 = qm31_mul_cm31();
    r_m5.a <== alpha3.out;
    r_m5.b <== num_interaction_sum_0.res_conjugated_z;

    component r_m6 = qm31_mul_cm31();
    r_m6.a <== alpha2.out;
    r_m6.b <== num_interaction_sum_1.res_conjugated_z;

    component r_m7 = qm31_mul_cm31();
    r_m7.a <== alpha;
    r_m7.b <== num_interaction_sum_2.res_conjugated_z;

    component r_s1 = qm31_add();
    r_s1.a <== r_m1.out;
    r_s1.b <== r_m2.out;

    component r_s2 = qm31_add();
    r_s2.a <== r_s1.out;
    r_s2.b <== r_m3.out;

    component r_s3 = qm31_add();
    r_s3.a <== r_s2.out;
    r_s3.b <== r_m4.out;

    component r_s4 = qm31_add();
    r_s4.a <== r_s3.out;
    r_s4.b <== r_m5.out;

    component r_s5 = qm31_add();
    r_s5.a <== r_s4.out;
    r_s5.b <== r_m6.out;

    component r_s6 = qm31_add_cm31();
    r_s6.a <== r_s5.out;
    r_s6.b <== r_m7.out;

    component alpha12 = qm31_mul();
    alpha12.a <== alpha8.out;
    alpha12.b <== alpha4.out;

    component alpha13 = qm31_mul();
    alpha13.a <== alpha12.out;
    alpha13.b <== alpha;

    component alpha13_interaction_l = qm31_mul();
    alpha13_interaction_l.a <== alpha13.out;
    alpha13_interaction_l.b <== l_s6.out;

    component alpha13_interaction_r = qm31_mul();
    alpha13_interaction_r.a <== alpha13.out;
    alpha13_interaction_r.b <== r_s6.out;

    signal output num_interaction_l[4];
    num_interaction_l <== alpha13_interaction_l.out;

    signal output num_interaction_r[4];
    num_interaction_r <== alpha13_interaction_r.out;
}