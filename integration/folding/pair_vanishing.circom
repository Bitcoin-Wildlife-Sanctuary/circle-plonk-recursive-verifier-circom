pragma circom 2.0.0

include "../../primitives/circle/fields.circom";

template pair_vanishing_inverse() {
    signal input a[2];
    signal input b[2];

    signal input z_x;
    signal input z_y;

    signal output inverse_res_for_z[2];
    signal output inverse_res_for_conjugated_z[2];

    component b_plus_z_x = cm31_add_m31();
    b_plus_z_x.a <== b;
    b_plus_z_x.b <== z_x;

    component a_times_z_y = cm31_mul_m31();
    a_times_z_y.a <== a;
    a_times_z_y.b <== z_y;

    component res_for_z = cm31_sub();
    res_for_z.a <== b_plus_z_x.out;
    res_for_z.b <== a_times_z_y.out;

    component res_for_conjugated_z = cm31_add();
    res_for_conjugated_z.a <== b_plus_z_x.out;
    res_for_conjugated.z.b <== a_times_z_y.out;

    component inv_for_z = cm31_inv();
    inv_for_z.a <== res_for_z.out;
    inverse_res_for_z <== inv_for_z.out;

    component inv_for_conjugated_z = cm31_inv();
    inv_for_conjugated_z.a <== res_for_conjugated_z.out;
    inverse_res_for_conjugated_z <== inv_for_conjugated_z.out;
}