pragma circom 2.0.0;

include "num.circom";
include "pair_vanishing.circom";
include "../../primitives/bits/bits.circom";
include "../../primitives/circle/curve.circom";
include "../../primitives/circle/fields.circom";

template compute_quotient_for_individual_query(N) {
    signal input query;

    component decompose_bits = decompose_into_bits(N);
    decompose_bits.a <== query;

    component start = m31_subgroup_generator(20);
    component step = m31_subgroup_generator(18);

    component compute_step_for_z = circle_point_m31_only_mul_by_bits(N);
    compute_step_for_z.bits_le[N - 1] <== 0;
    for(var i = 1; i < N; i++) {
        compute_step_for_z.bits_le[N - 1 - i] <== decompose_bits.bits[i];
    }
    compute_step_for_z.x <== step.x;
    compute_step_for_z.y <== step.y;

    component compute_point_z = circle_point_m31_only_add();
    compute_point_z.x1 <== start.x;
    compute_point_z.y1 <== start.y;
    compute_point_z.x2 <== compute_step_for_z.out_x;
    compute_point_z.y2 <== compute_step_for_z.out_y;

    signal input trace_l[3];
    signal input trace_r[3];

    signal input interaction_l[8];
    signal input interaction_r[8];

    signal input constant_l[5];
    signal input constant_r[5];

    signal input composition_l[4];
    signal input composition_r[4];

    signal input coeffs_trace_a[6];
    signal input coeffs_trace_b[6];

    signal input coeffs_interaction_a[16];
    signal input coeffs_interaction_b[16];

    signal input coeffs_constant_a[10];
    signal input coeffs_constant_b[10];

    signal input coeffs_composition_a[8];
    signal input coeffs_composition_b[8];

    signal input coeffs_interaction_shifted_a[8];
    signal input coeffs_interaction_shifted_b[8];

    signal input alpha[4];

    component num_trace = compute_num(3);
    num_trace.y <== compute_point_z.out_y;
    num_trace.l <== trace_l;
    num_trace.r <== trace_r;
    num_trace.coeffs_a <== coeffs_trace_a;
    num_trace.coeffs_b <== coeffs_trace_b;
    num_trace.alpha <== alpha;

    component num_interaction = compute_num(8);
    num_interaction.y <== compute_point_z.out_y;
    num_interaction.l <== interaction_l;
    num_interaction.r <== interaction_r;
    num_interaction.coeffs_a <== coeffs_interaction_a;
    num_interaction.coeffs_b <== coeffs_interaction_b;
    num_interaction.alpha <== alpha;

    component num_constant = compute_num(5);
    num_constant.y <== compute_point_z.out_y;
    num_constant.l <== constant_l;
    num_constant.r <== constant_r;
    num_constant.coeffs_a <== coeffs_constant_a;
    num_constant.coeffs_b <== coeffs_constant_b;
    num_constant.alpha <== alpha;

    component num_composition = compute_num(4);
    num_composition.y <== compute_point_z.out_y;
    num_composition.l <== composition_l;
    num_composition.r <== composition_r;
    num_composition.coeffs_a <== coeffs_composition_a;
    num_composition.coeffs_b <== coeffs_composition_b;
    num_composition.alpha <== alpha;

    component num_interaction_shifted = compute_num(4);
    num_interaction_shifted.y <== compute_point_z.out_y;
    for(var i = 0; i < 4; i++) {
        num_interaction_shifted.l[i] <== interaction_l[i + 4];
        num_interaction_shifted.r[i] <== interaction_r[i + 4];
    }
    num_interaction_shifted.coeffs_a <== coeffs_interaction_shifted_a;
    num_interaction_shifted.coeffs_b <== coeffs_interaction_shifted_b;
    num_interaction_shifted.alpha <== alpha;

    signal trace_l_sum[4];
    signal trace_r_sum[4];

    trace_l_sum <== num_trace.num_l;
    trace_r_sum <== num_trace.num_r;

    signal interaction_l_sum[4];
    signal interaction_r_sum[4];

    interaction_l_sum <== num_interaction.num_l;
    interaction_r_sum <== num_interaction.num_r;

    signal constant_l_sum[4];
    signal constant_r_sum[4];

    constant_l_sum <== num_constant.num_l;
    constant_r_sum <== num_constant.num_r;

    signal composition_l_sum[4];
    signal composition_r_sum[4];

    composition_l_sum <== num_composition.num_l;
    composition_r_sum <== num_composition.num_r;

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

    component alpha12 = qm31_mul();
    alpha12.a <== alpha8.out;
    alpha12.b <== alpha4.out;

    component alpha13 = qm31_mul();
    alpha13.a <== alpha12.out;
    alpha13.b <== alpha;

    component alpha21 = qm31_mul();
    alpha21.a <== alpha13.out;
    alpha21.b <== alpha8.out;

    component alpha21_trace_l = qm31_mul();
    alpha21_trace_l.a <== alpha21.out;
    alpha21_trace_l.b <== trace_l_sum;

    component alpha21_trace_r = qm31_mul();
    alpha21_trace_r.a <== alpha21.out;
    alpha21_trace_r.b <== trace_r_sum;

    component alpha13_interaction_l = qm31_mul();
    alpha13_interaction_l.a <== alpha13.out;
    alpha13_interaction_l.b <== interaction_l_sum;

    component alpha13_interaction_r = qm31_mul();
    alpha13_interaction_r.a <== alpha13.out;
    alpha13_interaction_r.b <== interaction_r_sum;

    component alpha8_constant_l = qm31_mul();
    alpha8_constant_l.a <== alpha8.out;
    alpha8_constant_l.b <== constant_l_sum;

    component alpha8_constant_r = qm31_mul();
    alpha8_constant_r.a <== alpha8.out;
    alpha8_constant_r.b <== constant_r_sum;

    component alpha4_composition_l = qm31_mul();
    alpha4_composition_l.a <== alpha4.out;
    alpha4_composition_l.b <== composition_l_sum;

    component alpha4_composition_r = qm31_mul();
    alpha4_composition_r.a <== alpha4.out;
    alpha4_composition_r.b <== composition_r_sum;

    component oods_s1_l = qm31_add();
    oods_s1_l.a <== alpha21_trace_l.out;
    oods_s1_l.b <== alpha13_interaction_l.out;

    component oods_s2_l = qm31_add();
    oods_s2_l.a <== oods_s1_l.out;
    oods_s2_l.b <== alpha8_constant_l.out;

    component oods_s3_l = qm31_add();
    oods_s3_l.a <== oods_s2_l.out;
    oods_s3_l.b <== alpha4_composition_l.out;

    component oods_s1_r = qm31_add();
    oods_s1_r.a <== alpha21_trace_r.out;
    oods_s1_r.b <== alpha13_interaction_r.out;

    component oods_s2_r = qm31_add();
    oods_s2_r.a <== oods_s1_r.out;
    oods_s2_r.b <== alpha8_constant_r.out;

    component oods_s3_r = qm31_add();
    oods_s3_r.a <== oods_s2_r.out;
    oods_s3_r.b <== alpha4_composition_r.out;

    signal output alpha4_times_oods_part_l_sum[4];
    alpha4_times_oods_part_l_sum <== oods_s3_l.out;

    signal output alpha4_times_oods_part_r_sum[4];
    alpha4_times_oods_part_r_sum <== oods_s3_r.out;

    signal input oods_a[2];
    signal input oods_b[2];
    signal input oods_shifted_a[2];
    signal input oods_shifted_b[2];

    component denominator_inverses_oods = pair_vanishing_inverse();
    denominator_inverses_oods.a <== oods_a;
    denominator_inverses_oods.b <== oods_b;
    denominator_inverses_oods.z_x <== compute_point_z.out_x;
    denominator_inverses_oods.z_y <== compute_point_z.out_y;

    component denominator_inverses_oods_shifted = pair_vanishing_inverse();
    denominator_inverses_oods_shifted.a <== oods_shifted_a;
    denominator_inverses_oods_shifted.b <== oods_shifted_b;
    denominator_inverses_oods_shifted.z_x <== compute_point_z.out_x;
    denominator_inverses_oods_shifted.z_y <== compute_point_z.out_y;

    component sum_l_m1 = qm31_mul_cm31();
    sum_l_m1.a <== alpha4_times_oods_part_l_sum;
    sum_l_m1.b <== denominator_inverses_oods.inverse_res_for_z;

    component sum_l_m2 = qm31_mul_cm31();
    sum_l_m2.a <== num_interaction_shifted.num_l;
    sum_l_m2.b <== denominator_inverses_oods_shifted.inverse_res_for_z;

    component sum_l_s = qm31_add();
    sum_l_s.a <== sum_l_m1.out;
    sum_l_s.b <== sum_l_m2.out;

    component sum_r_m1 = qm31_mul_cm31();
    sum_r_m1.a <== alpha4_times_oods_part_r_sum;
    sum_r_m1.b <== denominator_inverses_oods.inverse_res_for_conjugated_z;

    component sum_r_m2 = qm31_mul_cm31();
    sum_r_m2.a <== num_interaction_shifted.num_r;
    sum_r_m2.b <== denominator_inverses_oods_shifted.inverse_res_for_conjugated_z;

    component sum_r_s = qm31_add();
    sum_r_s.a <== sum_r_m1.out;
    sum_r_s.b <== sum_r_m2.out;

    signal output sum_l[4];
    signal output sum_r[4];

    sum_l <== sum_l_s.out;
    sum_r <== sum_r_s.out;
}

template test_quotient() {
    signal input query;

    signal input trace_l[3];
    signal input trace_r[3];

    signal input interaction_l[8];
    signal input interaction_r[8];

    signal input constant_l[5];
    signal input constant_r[5];

    signal input composition_l[4];
    signal input composition_r[4];

    signal input coeffs_trace_a[6];
    signal input coeffs_trace_b[6];

    signal input coeffs_interaction_a[16];
    signal input coeffs_interaction_b[16];

    signal input coeffs_constant_a[10];
    signal input coeffs_constant_b[10];

    signal input coeffs_composition_a[8];
    signal input coeffs_composition_b[8];

    signal input coeffs_interaction_shifted_a[8];
    signal input coeffs_interaction_shifted_b[8];

    signal input alpha[4];

    component query_s = compute_quotient_for_individual_query(19);
    query_s.query <== query;
    query_s.alpha <== alpha;

    query_s.trace_l <== trace_l;
    query_s.trace_r <== trace_r;
    query_s.coeffs_trace_a <== coeffs_trace_a;
    query_s.coeffs_trace_b <== coeffs_trace_b;

    query_s.interaction_l <== interaction_l;
    query_s.interaction_r <== interaction_r;
    query_s.coeffs_interaction_a <== coeffs_interaction_a;
    query_s.coeffs_interaction_b <== coeffs_interaction_b;

    query_s.constant_l <== constant_l;
    query_s.constant_r <== constant_r;
    query_s.coeffs_constant_a <== coeffs_constant_a;
    query_s.coeffs_constant_b <== coeffs_constant_b;

    query_s.composition_l <== composition_l;
    query_s.composition_r <== composition_r;
    query_s.coeffs_composition_a <== coeffs_composition_a;
    query_s.coeffs_composition_b <== coeffs_composition_b;

    query_s.coeffs_interaction_shifted_a <== coeffs_interaction_shifted_a;
    query_s.coeffs_interaction_shifted_b <== coeffs_interaction_shifted_b;

    signal input oods_a[2];
    signal input oods_b[2];
    signal input oods_shifted_a[2];
    signal input oods_shifted_b[2];

    query_s.oods_a <== oods_a;
    query_s.oods_b <== oods_b;
    query_s.oods_shifted_a <== oods_shifted_a;
    query_s.oods_shifted_b <== oods_shifted_b;

    signal input sum_l[4];
    signal input sum_r[4];
    sum_l === query_s.sum_l;
    sum_r === query_s.sum_r;
}

component main = test_quotient();