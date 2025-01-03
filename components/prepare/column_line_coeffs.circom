pragma circom 2.0.0;

include "../../primitives/circle/fields.circom";

template compute_column_line_coeffs_individual(N) {
    signal input y[4];
    signal input evals[N][4];

    signal output a[N][2];
    signal output b[N][2];

    signal y_second[2];
    y_second[0] <== y[2];
    y_second[1] <== y[3];

    signal y_first[2];
    y_first[0] <== y[0];
    y_first[1] <== y[1];

    component y_second_inv = cm31_inv();
    y_second_inv.a <== y_second;

    component y_first_times_y_second_inv = cm31_mul();
    y_first_times_y_second_inv.a <== y_first;
    y_first_times_y_second_inv.b <== y_second_inv.out;

    signal eval_first[N][2];
    signal eval_second[N][2];

    for(var i = 0; i < N; i++) {
        eval_first[i][0] <== evals[i][0];
        eval_first[i][1] <== evals[i][1];
        eval_second[i][0] <== evals[i][2];
        eval_second[i][1] <== evals[i][3];
    }

    component a_c[N];
    for(var i = 0; i < N; i++) {
        a_c[i] = cm31_mul();
        a_c[i].a <== eval_second[i];
        a_c[i].b <== y_second_inv.out;

        a[i] <== a_c[i].out;
    }

    component b_c1[N];
    component b_c2[N];
    for(var i = 0; i < N; i++) {
        b_c1[i] = cm31_mul();
        b_c1[i].a <== eval_second[i];
        b_c1[i].b <== y_first_times_y_second_inv.out;

        b_c2[i] = cm31_sub();
        b_c2[i].a <== b_c1[i].out;
        b_c2[i].b <== eval_first[i];

        b[i] <== b_c2[i].out;
    }
}

template compute_column_line_coeffs() {
    signal input oods_y[4];
    signal input oods_shifted_y[4];

    signal input trace_a_val[4];
    signal input trace_b_val[4];
    signal input trace_c_val[4];

    signal input interaction_ab_0[4];
    signal input interaction_ab_1[4];
    signal input interaction_ab_2[4];
    signal input interaction_ab_3[4];

    signal input interaction_sum_0[4];
    signal input interaction_sum_1[4];
    signal input interaction_sum_2[4];
    signal input interaction_sum_3[4];

    signal input interaction_shifted_sum_0[4];
    signal input interaction_shifted_sum_1[4];
    signal input interaction_shifted_sum_2[4];
    signal input interaction_shifted_sum_3[4];

    signal input composition_0[4];
    signal input composition_1[4];
    signal input composition_2[4];
    signal input composition_3[4];

    signal input constant_mult[4];
    signal input constant_a_wire[4];
    signal input constant_b_wire[4];
    signal input constant_c_wire[4];
    signal input constant_op[4];

    signal output trace_column_line_coeffs_a[3][2];
    signal output trace_column_line_coeffs_b[3][2];

    signal output interaction_column_line_coeffs_a[8][2];
    signal output interaction_column_line_coeffs_b[8][2];

    signal output interaction_shifted_column_line_coeffs_a[4][2];
    signal output interaction_shifted_column_line_coeffs_b[4][2];

    signal output constant_column_line_coeffs_a[5][2];
    signal output constant_column_line_coeffs_b[5][2];

    signal output composition_column_line_coeffs_a[4][2];
    signal output composition_column_line_coeffs_b[4][2];

    component trace = compute_column_line_coeffs_individual(3);
    trace.y <== oods_y;
    trace.evals[0] <== trace_a_val;
    trace.evals[1] <== trace_b_val;
    trace.evals[2] <== trace_c_val;
    trace_column_line_coeffs_a <== trace.a;
    trace_column_line_coeffs_b <== trace.b;

    component interaction = compute_column_line_coeffs_individual(8);
    interaction.y <== oods_y;
    interaction.evals[0] <== interaction_ab_0;
    interaction.evals[1] <== interaction_ab_1;
    interaction.evals[2] <== interaction_ab_2;
    interaction.evals[3] <== interaction_ab_3;
    interaction.evals[4] <== interaction_sum_0;
    interaction.evals[5] <== interaction_sum_1;
    interaction.evals[6] <== interaction_sum_2;
    interaction.evals[7] <== interaction_sum_3;
    interaction_column_line_coeffs_a <== interaction.a;
    interaction_column_line_coeffs_b <== interaction.b;

    component interaction_shifted = compute_column_line_coeffs_individual(4);
    interaction_shifted.y <== oods_shifted_y;
    interaction_shifted.evals[0] <== interaction_shifted_sum_0;
    interaction_shifted.evals[1] <== interaction_shifted_sum_1;
    interaction_shifted.evals[2] <== interaction_shifted_sum_2;
    interaction_shifted.evals[3] <== interaction_shifted_sum_3;
    interaction_shifted_column_line_coeffs_a <== interaction_shifted.a;
    interaction_shifted_column_line_coeffs_b <== interaction_shifted.b;

    component constant = compute_column_line_coeffs_individual(5);
    constant.y <== oods_y;
    constant.evals[0] <== constant_mult;
    constant.evals[1] <== constant_a_wire;
    constant.evals[2] <== constant_b_wire;
    constant.evals[3] <== constant_c_wire;
    constant.evals[4] <== constant_op;
    constant_column_line_coeffs_a <== constant.a;
    constant_column_line_coeffs_b <== constant.b;

    component composition = compute_column_line_coeffs_individual(4);
    composition.y <== oods_y;
    composition.evals[0] <== composition_0;
    composition.evals[1] <== composition_1;
    composition.evals[2] <== composition_2;
    composition.evals[3] <== composition_3;
    composition_column_line_coeffs_a <== composition.a;
    composition_column_line_coeffs_b <== composition.b;
}