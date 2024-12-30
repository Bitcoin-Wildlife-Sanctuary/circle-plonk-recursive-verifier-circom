pragma circom 2.0.0;

include "../../primitives/circle/fields.circom";

template apply_column_line_coeffs() {
    signal input z_y;
    signal input queried_value_for_z;
    signal input queried_value_for_conjugated_z;
    signal input a[2];
    signal input b[2];

    component a_times_z_y = cm31_mul_m31();
    a_times_z_y.a <== a;
    a_times_z_y.b <== z_y;

    signal output res_z[2];
    signal output res_conjugated_z[2];

    component res_z_s1 = cm31_sub();
    res_z_s1.a <== b;
    res_z_s1.b <== a_times_z_y.out;

    component res_z_s2 = cm31_add_m31();
    res_z_s2.a <== res_z_s1.out;
    res_z_s2.b <== queried_value_for_z;
    res_z <== res_z_s2.out;

    component res_conjugated_z_s1 = cm31_add();
    res_conjugated_z_s1.a <== b;
    res_conjugated_z_s1.b <== a_times_z_y.out;

    component res_conjugated_z_s2 = cm31_add_m31();
    res_conjugated_z_s2.a <== res_conjugated_z_s1.out;
    res_conjugated_z_s2.b <== queried_value_for_conjugated_z;
    res_conjugated_z <== res_conjugated_z_s2.out;
}