pragma circom 2.0.0;

include "../../primitives/circle/fields.circom";

template compute_res1() {
    signal input a_val[4];
    signal input b_val[4];
    signal input c_val[4];
    signal input op[4];
    signal input random_coeff[4];
    signal output res1[4];

    component a_val_times_b_val = qm31_mul();
    a_val_times_b_val.a <== a_val;
    a_val_times_b_val.b <== b_val;

    component a_val_plus_b_val = qm31_add();
    a_val_plus_b_val.a <== a_val;
    a_val_plus_b_val.b <== b_val;

    component sum_minus_product = qm31_sub();
    sum_minus_product.a <== a_val_plus_b_val.out;
    sum_minus_product.b <== a_val_times_b_val.out;

    component op_mul_sum_minus_product = qm31_mul();
    op_mul_sum_minus_product.a <== op;
    op_mul_sum_minus_product.b <== sum_minus_product.out;

    component res1_1 = qm31_add();
    res1_1.a <== op_mul_sum_minus_product.out;
    res1_1.b <== a_val_times_b_val.out;

    component res1_2 = qm31_sub();
    res1_2.a <== c_val;
    res1_2.b <== res1_1.out;

    component random_coeff_squared = qm31_mul();
    random_coeff_squared.a <== random_coeff;
    random_coeff_squared.b <== random_coeff;

    component res1_3 = qm31_mul();
    res1_3.a <== res1_2.out;
    res1_3.b <== random_coeff_squared.out;

    res1 <== res1_3.out;
}

template compute_res2() {
    signal input a_val[4];
    signal input b_val[4];
    signal input a_wire[4];
    signal input b_wire[4];
    signal input alpha[4];
    signal input z[4];

    signal input a_b_logup_0[4];
    signal input a_b_logup_1[4];
    signal input a_b_logup_2[4];
    signal input a_b_logup_3[4];

    signal input random_coeff[4];

    signal output res2[4];
    signal output a_b_logup[4];

    component alpha_times_a_val = qm31_mul();
    alpha_times_a_val.a <== a_val;
    alpha_times_a_val.b <== alpha;

    component alpha_times_b_val = qm31_mul();
    alpha_times_b_val.a <== b_val;
    alpha_times_b_val.b <== alpha;

    component denominator_1s1 = qm31_add();
    denominator_1s1.a <== a_wire;
    denominator_1s1.b <== alpha_times_a_val.out;

    component denominator_1 = qm31_sub();
    denominator_1.a <== denominator_1s1.out;
    denominator_1.b <== z;

    component denominator_2s1 = qm31_add();
    denominator_2s1.a <== b_wire;
    denominator_2s1.b <== alpha_times_b_val.out;

    component denominator_2 = qm31_sub();
    denominator_2.a <== denominator_2s1.out;
    denominator_2.b <== z;

    component num_aggregated = qm31_add();
    num_aggregated.a <== denominator_1.out;
    num_aggregated.b <== denominator_2.out;

    component denom_aggregated = qm31_mul();
    denom_aggregated.a <== denominator_1.out;
    denom_aggregated.b <== denominator_2.out;

    var unit_i[4] =[0, 1, 0, 0];
    var unit_j[4] = [0, 0, 1, 0];
    var unit_ij[4] = [0, 0, 0, 1];

    component a_b_logup_1_shifted = qm31_mul();
    a_b_logup_1_shifted.a <== a_b_logup_1;
    a_b_logup_1_shifted.b <== unit_i;

    component a_b_logup_2_shifted = qm31_mul();
    a_b_logup_2_shifted.a <== a_b_logup_2;
    a_b_logup_2_shifted.b <== unit_j;

    component a_b_logup_3_shifted = qm31_mul();
    a_b_logup_3_shifted.a <== a_b_logup_3;
    a_b_logup_3_shifted.b <== unit_ij;

    component a_b_logup_s1 = qm31_add();
    a_b_logup_s1.a <== a_b_logup_0;
    a_b_logup_s1.b <== a_b_logup_1_shifted.out;

    component a_b_logup_s2 = qm31_add();
    a_b_logup_s2.a <== a_b_logup_s1.out;
    a_b_logup_s2.b <== a_b_logup_2_shifted.out;

    component a_b_logup_s3 = qm31_add();
    a_b_logup_s3.a <== a_b_logup_s2.out;
    a_b_logup_s3.b <== a_b_logup_3_shifted.out;

    component res2_s1 = qm31_mul();
    res2_s1.a <== a_b_logup_s3.out;
    res2_s1.b <== denom_aggregated.out;

    component res2_s2 = qm31_sub();
    res2_s2.a <== res2_s1.out;
    res2_s2.b <== num_aggregated.out;

    component res2_s3 = qm31_mul();
    res2_s3.a <== res2_s2.out;
    res2_s3.b <== random_coeff;

    res2 <== res2_s3.out;
    a_b_logup <== a_b_logup_s3.out;
}

template compute_res3() {
    signal input c_val[4];
    signal input c_wire[4];
    signal input alpha[4];
    signal input z[4];

    signal input c_logup_0[4];
    signal input c_logup_1[4];
    signal input c_logup_2[4];
    signal input c_logup_3[4];

    signal input c_logup_next_0[4];
    signal input c_logup_next_1[4];
    signal input c_logup_next_2[4];
    signal input c_logup_next_3[4];

    signal input a_b_logup[4];

    signal input claimed_sum[4];

    signal input mult[4];
    signal output res3[4];

    var unit_i[4] =[0, 1, 0, 0];
    var unit_j[4] = [0, 0, 1, 0];
    var unit_ij[4] = [0, 0, 0, 1];

    component alpha_times_c_val = qm31_mul();
    alpha_times_c_val.a <== c_val;
    alpha_times_c_val.b <== alpha;

    component denominator_3_s1 = qm31_add();
    denominator_3_s1.a <== c_wire;
    denominator_3_s1.b <== alpha_times_c_val.out;

    component denominator_3 = qm31_sub();
    denominator_3.a <== denominator_3_s1.out;
    denominator_3.b <== z;

    component c_logup_1_shifted = qm31_mul();
    c_logup_1_shifted.a <== c_logup_1;
    c_logup_1_shifted.b <== unit_i;

    component c_logup_2_shifted = qm31_mul();
    c_logup_2_shifted.a <== c_logup_2;
    c_logup_2_shifted.b <== unit_j;

    component c_logup_3_shifted = qm31_mul();
    c_logup_3_shifted.a <== c_logup_3;
    c_logup_3_shifted.b <== unit_ij;

    component c_logup_next_1_shifted = qm31_mul();
    c_logup_next_1_shifted.a <== c_logup_next_1;
    c_logup_next_1_shifted.b <== unit_i;

    component c_logup_next_2_shifted = qm31_mul();
    c_logup_next_2_shifted.a <== c_logup_next_2;
    c_logup_next_2_shifted.b <== unit_j;

    component c_logup_next_3_shifted = qm31_mul();
    c_logup_next_3_shifted.a <== c_logup_next_3;
    c_logup_next_3_shifted.b <== unit_ij;

    component c_logup_s1 = qm31_add();
    c_logup_s1.a <== c_logup_0;
    c_logup_s1.b <== c_logup_1_shifted.out;

    component c_logup_s2 = qm31_add();
    c_logup_s2.a <== c_logup_s1.out;
    c_logup_s2.b <== c_logup_2_shifted.out;

    component c_logup = qm31_add();
    c_logup.a <== c_logup_s2.out;
    c_logup.b <== c_logup_3_shifted.out;

    component c_logup_next_s1 = qm31_add();
    c_logup_next_s1.a <== c_logup_next_0;
    c_logup_next_s1.b <== c_logup_next_1_shifted.out;

    component c_logup_next_s2 = qm31_add();
    c_logup_next_s2.a <== c_logup_next_s1.out;
    c_logup_next_s2.b <== c_logup_next_2_shifted.out;

    component c_logup_next = qm31_add();
    c_logup_next.a <== c_logup_next_s2.out;
    c_logup_next.b <== c_logup_next_3_shifted.out;

    var divisor = 1 / (1 << 13);

    signal claimed_sum_divided[4];
    for(var i = 0; i < 4; i++) {
        claimed_sum_divided[i] <== claimed_sum[i] * divisor;
    }

    component res3_s1 = qm31_sub();
    res3_s1.a <== c_logup.out;
    res3_s1.b <== c_logup_next.out;

    component res3_s2 = qm31_sub();
    res3_s2.a <== res3_s1.out;
    res3_s2.b <== a_b_logup;

    component res3_s3 = qm31_add();
    res3_s3.a <== res3_s2.out;
    res3_s3.b <== claimed_sum_divided;

    component res3_s4 = qm31_mul();
    res3_s4.a <== res3_s3.out;
    res3_s4.b <== denominator_3.out;

    component res3_s5 = qm31_add();
    res3_s5.a <== res3_s4.out;
    res3_s5.b <== mult;

    res3 <== res3_s5.out;
}

template compute_constraint_num() {
    signal input a_val[4];
    signal input b_val[4];
    signal input c_val[4];
    signal input op[4];
    signal input random_coeff[4];

    component res1_c = compute_res1();
    res1_c.a_val <== a_val;
    res1_c.b_val <== b_val;
    res1_c.c_val <== c_val;
    res1_c.op <== op;
    res1_c.random_coeff <== random_coeff;

    signal input a_wire[4];
    signal input b_wire[4];
    signal input alpha[4];
    signal input z[4];
    signal input a_b_logup_0[4];
    signal input a_b_logup_1[4];
    signal input a_b_logup_2[4];
    signal input a_b_logup_3[4];

    component res2_c = compute_res2();
    res2_c.a_val <== a_val;
    res2_c.b_val <== b_val;
    res2_c.a_wire <== a_wire;
    res2_c.b_wire <== b_wire;
    res2_c.alpha <== alpha;
    res2_c.z <== z;
    res2_c.a_b_logup_0 <== a_b_logup_0;
    res2_c.a_b_logup_1 <== a_b_logup_1;
    res2_c.a_b_logup_2 <== a_b_logup_2;
    res2_c.a_b_logup_3 <== a_b_logup_3;
    res2_c.random_coeff <== random_coeff;

    component res12_c = qm31_add();
    res12_c.a <== res1_c.res1;
    res12_c.b <== res2_c.res2;

    signal input c_wire[4];

    signal input c_logup_0[4];
    signal input c_logup_1[4];
    signal input c_logup_2[4];
    signal input c_logup_3[4];

    signal input c_logup_next_0[4];
    signal input c_logup_next_1[4];
    signal input c_logup_next_2[4];
    signal input c_logup_next_3[4];

    signal input claimed_sum[4];

    signal input mult[4];

    component res3_c = compute_res3();
    res3_c.c_val <== c_val;
    res3_c.c_wire <== c_wire;
    res3_c.alpha <== alpha;
    res3_c.z <== z;
    res3_c.c_logup_0 <== c_logup_0;
    res3_c.c_logup_1 <== c_logup_1;
    res3_c.c_logup_2 <== c_logup_2;
    res3_c.c_logup_3 <== c_logup_3;
    res3_c.c_logup_next_0 <== c_logup_next_0;
    res3_c.c_logup_next_1 <== c_logup_next_1;
    res3_c.c_logup_next_2 <== c_logup_next_2;
    res3_c.c_logup_next_3 <== c_logup_next_3;
    res3_c.a_b_logup <== res2_c.a_b_logup;
    res3_c.claimed_sum <== claimed_sum;
    res3_c.mult <== mult;

    component res_c = qm31_add();
    res_c.a <== res12_c.out;
    res_c.b <== res3_c.res3;

    signal output out[4];
    out <== res_c.out;
}