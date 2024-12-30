pragma circom 2.0.0;

include "num_trace.circom";
include "num_interaction.circom";
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

    signal input trace_a_val_l;
    signal input trace_b_val_l;
    signal input trace_c_val_l;
    signal input trace_a_val_r;
    signal input trace_b_val_r;
    signal input trace_c_val_r;

    signal input interaction_ab_0_l;
    signal input interaction_ab_1_l;
    signal input interaction_ab_2_l;
    signal input interaction_ab_3_l;
    signal input interaction_sum_0_l;
    signal input interaction_sum_1_l;
    signal input interaction_sum_2_l;
    signal input interaction_sum_3_l;
    signal input interaction_ab_0_r;
    signal input interaction_ab_1_r;
    signal input interaction_ab_2_r;
    signal input interaction_ab_3_r;
    signal input interaction_sum_0_r;
    signal input interaction_sum_1_r;
    signal input interaction_sum_2_r;
    signal input interaction_sum_3_r;

    signal input coeffs_trace_a_val_a[2];
    signal input coeffs_trace_b_val_a[2];
    signal input coeffs_trace_c_val_a[2];
    signal input coeffs_trace_a_val_b[2];
    signal input coeffs_trace_b_val_b[2];
    signal input coeffs_trace_c_val_b[2];

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

    component num_trace = compute_num_trace();
    num_trace.y <== compute_point_z.out_y;
    num_trace.a_val_l <== trace_a_val_l;
    num_trace.a_val_r <== trace_a_val_r;
    num_trace.b_val_l <== trace_b_val_l;
    num_trace.b_val_r <== trace_b_val_r;
    num_trace.c_val_l <== trace_c_val_l;
    num_trace.c_val_r <== trace_c_val_r;
    num_trace.coeffs_trace_a_val_a <== coeffs_trace_a_val_a;
    num_trace.coeffs_trace_b_val_a <== coeffs_trace_b_val_a;
    num_trace.coeffs_trace_c_val_a <== coeffs_trace_c_val_a;
    num_trace.coeffs_trace_a_val_b <== coeffs_trace_a_val_b;
    num_trace.coeffs_trace_b_val_b <== coeffs_trace_b_val_b;
    num_trace.coeffs_trace_c_val_b <== coeffs_trace_c_val_b;
    num_trace.alpha <== alpha;

    component num_interaction = compute_num_interaction();
    num_interaction.y <== compute_point_z.out_y;
    num_interaction.interaction_ab_0_l <== interaction_ab_0_l;
    num_interaction.interaction_ab_1_l <== interaction_ab_1_l;
    num_interaction.interaction_ab_2_l <== interaction_ab_2_l;
    num_interaction.interaction_ab_3_l <== interaction_ab_3_l;
    num_interaction.interaction_sum_0_l <== interaction_sum_0_l;
    num_interaction.interaction_sum_1_l <== interaction_sum_1_l;
    num_interaction.interaction_sum_2_l <== interaction_sum_2_l;
    num_interaction.interaction_sum_3_l <== interaction_sum_3_l;

    num_interaction.interaction_ab_0_r <== interaction_ab_0_r;
    num_interaction.interaction_ab_1_r <== interaction_ab_1_r;
    num_interaction.interaction_ab_2_r <== interaction_ab_2_r;
    num_interaction.interaction_ab_3_r <== interaction_ab_3_r;
    num_interaction.interaction_sum_0_r <== interaction_sum_0_r;
    num_interaction.interaction_sum_1_r <== interaction_sum_1_r;
    num_interaction.interaction_sum_2_r <== interaction_sum_2_r;
    num_interaction.interaction_sum_3_r <== interaction_sum_3_r;

    num_interaction.coeffs_interaction_ab_0_a <== coeffs_interaction_ab_0_a;
    num_interaction.coeffs_interaction_ab_1_a <== coeffs_interaction_ab_1_a;
    num_interaction.coeffs_interaction_ab_2_a <== coeffs_interaction_ab_2_a;
    num_interaction.coeffs_interaction_ab_3_a <== coeffs_interaction_ab_3_a;
    num_interaction.coeffs_interaction_sum_0_a <== coeffs_interaction_sum_0_a;
    num_interaction.coeffs_interaction_sum_1_a <== coeffs_interaction_sum_1_a;
    num_interaction.coeffs_interaction_sum_2_a <== coeffs_interaction_sum_2_a;
    num_interaction.coeffs_interaction_sum_3_a <== coeffs_interaction_sum_3_a;

    num_interaction.coeffs_interaction_ab_0_b <== coeffs_interaction_ab_0_b;
    num_interaction.coeffs_interaction_ab_1_b <== coeffs_interaction_ab_1_b;
    num_interaction.coeffs_interaction_ab_2_b <== coeffs_interaction_ab_2_b;
    num_interaction.coeffs_interaction_ab_3_b <== coeffs_interaction_ab_3_b;
    num_interaction.coeffs_interaction_sum_0_b <== coeffs_interaction_sum_0_b;
    num_interaction.coeffs_interaction_sum_1_b <== coeffs_interaction_sum_1_b;
    num_interaction.coeffs_interaction_sum_2_b <== coeffs_interaction_sum_2_b;
    num_interaction.coeffs_interaction_sum_3_b <== coeffs_interaction_sum_3_b;
    num_interaction.alpha <== alpha;

    signal output alpha21_trace_l[4];
    signal output alpha21_trace_r[4];

    alpha21_trace_l <== num_trace.num_trace_l;
    alpha21_trace_r <== num_trace.num_trace_r;

    signal output alpha13_interaction_l[4];
    signal output alpha13_interaction_r[4];

    alpha13_interaction_l <== num_interaction.num_interaction_l;
    alpha13_interaction_r <== num_interaction.num_interaction_r;
}

template test_quotient() {
    signal input query;

    signal input trace_a_val_l;
    signal input trace_b_val_l;
    signal input trace_c_val_l;
    signal input trace_a_val_r;
    signal input trace_b_val_r;
    signal input trace_c_val_r;

    signal input coeffs_trace_a_val_a[2];
    signal input coeffs_trace_b_val_a[2];
    signal input coeffs_trace_c_val_a[2];

    signal input coeffs_trace_a_val_b[2];
    signal input coeffs_trace_b_val_b[2];
    signal input coeffs_trace_c_val_b[2];

    signal input alpha[4];

    component query_s = compute_quotient_for_individual_query(19);
    query_s.query <== query;
    query_s.trace_a_val_l <== trace_a_val_l;
    query_s.trace_a_val_r <== trace_a_val_r;
    query_s.trace_b_val_l <== trace_b_val_l;
    query_s.trace_b_val_r <== trace_b_val_r;
    query_s.trace_c_val_l <== trace_c_val_l;
    query_s.trace_c_val_r <== trace_c_val_r;
    query_s.coeffs_trace_a_val_a <== coeffs_trace_a_val_a;
    query_s.coeffs_trace_b_val_a <== coeffs_trace_b_val_a;
    query_s.coeffs_trace_c_val_a <== coeffs_trace_c_val_a;
    query_s.coeffs_trace_a_val_b <== coeffs_trace_a_val_b;
    query_s.coeffs_trace_b_val_b <== coeffs_trace_b_val_b;
    query_s.coeffs_trace_c_val_b <== coeffs_trace_c_val_b;
    query_s.alpha <== alpha;

    signal input interaction_ab_0_l;
    signal input interaction_ab_1_l;
    signal input interaction_ab_2_l;
    signal input interaction_ab_3_l;
    signal input interaction_sum_0_l;
    signal input interaction_sum_1_l;
    signal input interaction_sum_2_l;
    signal input interaction_sum_3_l;
    signal input interaction_ab_0_r;
    signal input interaction_ab_1_r;
    signal input interaction_ab_2_r;
    signal input interaction_ab_3_r;
    signal input interaction_sum_0_r;
    signal input interaction_sum_1_r;
    signal input interaction_sum_2_r;
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

    query_s.interaction_ab_0_l <== interaction_ab_0_l;
    query_s.interaction_ab_1_l <== interaction_ab_1_l;
    query_s.interaction_ab_2_l <== interaction_ab_2_l;
    query_s.interaction_ab_3_l <== interaction_ab_3_l;
    query_s.interaction_sum_0_l <== interaction_sum_0_l;
    query_s.interaction_sum_1_l <== interaction_sum_1_l;
    query_s.interaction_sum_2_l <== interaction_sum_2_l;
    query_s.interaction_sum_3_l <== interaction_sum_3_l;

    query_s.interaction_ab_0_r <== interaction_ab_0_r;
    query_s.interaction_ab_1_r <== interaction_ab_1_r;
    query_s.interaction_ab_2_r <== interaction_ab_2_r;
    query_s.interaction_ab_3_r <== interaction_ab_3_r;
    query_s.interaction_sum_0_r <== interaction_sum_0_r;
    query_s.interaction_sum_1_r <== interaction_sum_1_r;
    query_s.interaction_sum_2_r <== interaction_sum_2_r;
    query_s.interaction_sum_3_r <== interaction_sum_3_r;

    query_s.coeffs_interaction_ab_0_a <== coeffs_interaction_ab_0_a;
    query_s.coeffs_interaction_ab_1_a <== coeffs_interaction_ab_1_a;
    query_s.coeffs_interaction_ab_2_a <== coeffs_interaction_ab_2_a;
    query_s.coeffs_interaction_ab_3_a <== coeffs_interaction_ab_3_a;
    query_s.coeffs_interaction_sum_0_a <== coeffs_interaction_sum_0_a;
    query_s.coeffs_interaction_sum_1_a <== coeffs_interaction_sum_1_a;
    query_s.coeffs_interaction_sum_2_a <== coeffs_interaction_sum_2_a;
    query_s.coeffs_interaction_sum_3_a <== coeffs_interaction_sum_3_a;

    query_s.coeffs_interaction_ab_0_b <== coeffs_interaction_ab_0_b;
    query_s.coeffs_interaction_ab_1_b <== coeffs_interaction_ab_1_b;
    query_s.coeffs_interaction_ab_2_b <== coeffs_interaction_ab_2_b;
    query_s.coeffs_interaction_ab_3_b <== coeffs_interaction_ab_3_b;
    query_s.coeffs_interaction_sum_0_b <== coeffs_interaction_sum_0_b;
    query_s.coeffs_interaction_sum_1_b <== coeffs_interaction_sum_1_b;
    query_s.coeffs_interaction_sum_2_b <== coeffs_interaction_sum_2_b;
    query_s.coeffs_interaction_sum_3_b <== coeffs_interaction_sum_3_b;

    signal input alpha13_interaction_l[4];
    signal input alpha13_interaction_r[4];

    signal input alpha21_trace_l[4];
    signal input alpha21_trace_r[4];

    alpha21_trace_l === query_s.alpha21_trace_l;
    alpha21_trace_r === query_s.alpha21_trace_r;

    alpha13_interaction_l === query_s.alpha13_interaction_l;
    alpha13_interaction_r === query_s.alpha13_interaction_r;
}

component main { public [
    query, alpha, trace_a_val_l, trace_b_val_l, trace_c_val_l,
    trace_a_val_r, trace_b_val_r, trace_c_val_r,
    coeffs_trace_a_val_a, coeffs_trace_b_val_a, coeffs_trace_c_val_a,
    coeffs_trace_a_val_b, coeffs_trace_b_val_b, coeffs_trace_c_val_b,
    alpha21_trace_l, alpha21_trace_r,
    interaction_ab_0_l, interaction_ab_0_r, interaction_ab_1_l, interaction_ab_1_r,
    interaction_ab_2_l, interaction_ab_2_r, interaction_ab_3_l, interaction_ab_3_r,
    interaction_sum_0_l, interaction_sum_0_r, interaction_sum_1_l, interaction_sum_1_r,
    interaction_sum_2_l, interaction_sum_2_r, interaction_sum_3_l, interaction_sum_3_r,
    coeffs_interaction_ab_0_a, coeffs_interaction_ab_0_b, coeffs_interaction_ab_1_a, coeffs_interaction_ab_1_b,
    coeffs_interaction_ab_2_a, coeffs_interaction_ab_2_b, coeffs_interaction_ab_3_a, coeffs_interaction_ab_3_b,
    coeffs_interaction_sum_0_a, coeffs_interaction_sum_0_b,
    coeffs_interaction_sum_1_a, coeffs_interaction_sum_1_b,
    coeffs_interaction_sum_2_a, coeffs_interaction_sum_2_b,
    coeffs_interaction_sum_3_a, coeffs_interaction_sum_3_b,
    alpha13_interaction_l, alpha13_interaction_r
] } = test_quotient();