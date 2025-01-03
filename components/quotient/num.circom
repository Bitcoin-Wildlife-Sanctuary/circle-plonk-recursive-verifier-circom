pragma circom 2.0.0;

include "apply_column_line_coeffs.circom";
include "../../primitives/circle/fields.circom";

template compute_num(N) {
    signal input y;

    signal input l[N];
    signal input r[N];

    signal input coeffs_a[2 * N];
    signal input coeffs_b[2 * N];

    signal input alpha[4];

    component line_coeffs[N];
    for(var i = 0; i < N; i++) {
        line_coeffs[i] = apply_column_line_coeffs();
        line_coeffs[i].z_y <== y;
        line_coeffs[i].queried_value_for_z <== l[i];
        line_coeffs[i].queried_value_for_conjugated_z <== r[i];
        line_coeffs[i].a[0] <== coeffs_a[2 * i];
        line_coeffs[i].a[1] <== coeffs_a[2 * i + 1];
        line_coeffs[i].b[0] <== coeffs_b[2 * i];
        line_coeffs[i].b[1] <== coeffs_b[2 * i + 1];
    }

    signal alpha_powers[N][4];
    alpha_powers[0] <== [1, 0, 0, 0];
    alpha_powers[1] <== alpha;

    component alpha_compute[N - 2];
    for(var i = 0; i < N - 2; i++) {
        alpha_compute[i] = qm31_mul();
        alpha_compute[i].a <== alpha_powers[i + 1];
        alpha_compute[i].b <== alpha;
        alpha_powers[i + 2] <== alpha_compute[i].out;
    }

    component alpha_times_res_l[N - 1];
    for(var i = 0; i < N - 1; i++) {
        alpha_times_res_l[i] = qm31_mul_cm31();
        alpha_times_res_l[i].a <== alpha_powers[N - 1 - i];
        alpha_times_res_l[i].b <== line_coeffs[i].res_z;
    }

    component sum_l[N - 2];
    sum_l[0] = qm31_add();
    sum_l[0].a <== alpha_times_res_l[0].out;
    sum_l[0].b <== alpha_times_res_l[1].out;

    for(var i = 1; i < N - 2; i++) {
        sum_l[i] = qm31_add();
        sum_l[i].a <== sum_l[i - 1].out;
        sum_l[i].b <== alpha_times_res_l[i + 1].out;
    }

    component final_l = qm31_add_cm31();
    final_l.a <== sum_l[N - 3].out;
    final_l.b <== line_coeffs[N - 1].res_z;

    component alpha_times_res_r[N - 1];
    for(var i = 0; i < N - 1; i++) {
        alpha_times_res_r[i] = qm31_mul_cm31();
        alpha_times_res_r[i].a <== alpha_powers[N - 1 - i];
        alpha_times_res_r[i].b <== line_coeffs[i].res_conjugated_z;
    }

    component sum_r[N - 2];
    sum_r[0] = qm31_add();
    sum_r[0].a <== alpha_times_res_r[0].out;
    sum_r[0].b <== alpha_times_res_r[1].out;

    for(var i = 1; i < N - 2; i++) {
        sum_r[i] = qm31_add();
        sum_r[i].a <== sum_r[i - 1].out;
        sum_r[i].b <== alpha_times_res_r[i + 1].out;
    }

    component final_r = qm31_add_cm31();
    final_r.a <== sum_r[N - 3].out;
    final_r.b <== line_coeffs[N - 1].res_conjugated_z;

    signal output num_l[4];
    num_l <== final_l.out;

    signal output num_r[4];
    num_r <== final_r.out;
}