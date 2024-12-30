use circle_plonk_circom_hints::{FiatShamirHints, PrepareHints, QuotientHints};
use serde_json::json;
use stwo_prover::core::fields::cm31::CM31;
use stwo_prover::core::fields::qm31::QM31;

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);
    let quotient_hints = QuotientHints::new(&fiat_shamir_hints, &prepare_hints);

    let query = fiat_shamir_hints.queries[0];
    let query_parent = query >> 1;

    let query_z = query_parent << 1;
    let query_conjugated_z = (query_parent << 1) + 1;

    let trace_a_val_l = quotient_hints.map.get(&query_z).unwrap().trace_a_val;
    let trace_b_val_l = quotient_hints.map.get(&query_z).unwrap().trace_b_val;
    let trace_c_val_l = quotient_hints.map.get(&query_z).unwrap().trace_c_val;

    let trace_a_val_r = quotient_hints
        .map
        .get(&query_conjugated_z)
        .unwrap()
        .trace_a_val;
    let trace_b_val_r = quotient_hints
        .map
        .get(&query_conjugated_z)
        .unwrap()
        .trace_b_val;
    let trace_c_val_r = quotient_hints
        .map
        .get(&query_conjugated_z)
        .unwrap()
        .trace_c_val;

    let coeffs_trace_a_val_a = prepare_hints.trace_column_line_coeffs_a[0];
    let coeffs_trace_b_val_a = prepare_hints.trace_column_line_coeffs_a[1];
    let coeffs_trace_c_val_a = prepare_hints.trace_column_line_coeffs_a[2];

    let coeffs_trace_a_val_b = prepare_hints.trace_column_line_coeffs_b[0];
    let coeffs_trace_b_val_b = prepare_hints.trace_column_line_coeffs_b[1];
    let coeffs_trace_c_val_b = prepare_hints.trace_column_line_coeffs_b[2];

    let interaction_ab_0_l = quotient_hints.map.get(&query_z).unwrap().interaction_ab_0;
    let interaction_ab_1_l = quotient_hints.map.get(&query_z).unwrap().interaction_ab_1;
    let interaction_ab_2_l = quotient_hints.map.get(&query_z).unwrap().interaction_ab_2;
    let interaction_ab_3_l = quotient_hints.map.get(&query_z).unwrap().interaction_ab_3;
    let interaction_sum_0_l = quotient_hints.map.get(&query_z).unwrap().interaction_sum_0;
    let interaction_sum_1_l = quotient_hints.map.get(&query_z).unwrap().interaction_sum_1;
    let interaction_sum_2_l = quotient_hints.map.get(&query_z).unwrap().interaction_sum_2;
    let interaction_sum_3_l = quotient_hints.map.get(&query_z).unwrap().interaction_sum_3;

    let interaction_ab_0_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_ab_0;
    let interaction_ab_1_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_ab_1;
    let interaction_ab_2_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_ab_2;
    let interaction_ab_3_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_ab_3;
    let interaction_sum_0_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_sum_0;
    let interaction_sum_1_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_sum_1;
    let interaction_sum_2_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_sum_2;
    let interaction_sum_3_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_sum_3;

    let coeffs_interaction_ab_0_a = prepare_hints.interaction_column_line_coeffs_a[0];
    let coeffs_interaction_ab_1_a = prepare_hints.interaction_column_line_coeffs_a[1];
    let coeffs_interaction_ab_2_a = prepare_hints.interaction_column_line_coeffs_a[2];
    let coeffs_interaction_ab_3_a = prepare_hints.interaction_column_line_coeffs_a[3];
    let coeffs_interaction_sum_0_a = prepare_hints.interaction_column_line_coeffs_a[4];
    let coeffs_interaction_sum_1_a = prepare_hints.interaction_column_line_coeffs_a[5];
    let coeffs_interaction_sum_2_a = prepare_hints.interaction_column_line_coeffs_a[6];
    let coeffs_interaction_sum_3_a = prepare_hints.interaction_column_line_coeffs_a[7];

    let coeffs_interaction_ab_0_b = prepare_hints.interaction_column_line_coeffs_b[0];
    let coeffs_interaction_ab_1_b = prepare_hints.interaction_column_line_coeffs_b[1];
    let coeffs_interaction_ab_2_b = prepare_hints.interaction_column_line_coeffs_b[2];
    let coeffs_interaction_ab_3_b = prepare_hints.interaction_column_line_coeffs_b[3];
    let coeffs_interaction_sum_0_b = prepare_hints.interaction_column_line_coeffs_b[4];
    let coeffs_interaction_sum_1_b = prepare_hints.interaction_column_line_coeffs_b[5];
    let coeffs_interaction_sum_2_b = prepare_hints.interaction_column_line_coeffs_b[6];
    let coeffs_interaction_sum_3_b = prepare_hints.interaction_column_line_coeffs_b[7];

    let alpha21_trace_l = quotient_hints.map.get(&query_z).unwrap().alpha21_trace;
    let alpha21_trace_r = quotient_hints
        .map
        .get(&query_conjugated_z)
        .unwrap()
        .alpha21_trace;

    let alpha13_interaction_l = quotient_hints.map.get(&query_z).unwrap().alpha13_interaction;
    let alpha13_interaction_r = quotient_hints.map.get(&query_conjugated_z).unwrap().alpha13_interaction;

    let qm31_to_num_vec = |a: QM31| [a.0.0.0, a.0.1.0, a.1.0.0, a.1.1.0];
    let cm31_to_num_vec = |a: CM31| [a.0.0, a.1.0];

    let mut text1 = json!({
        "query": query,
        "alpha": qm31_to_num_vec(fiat_shamir_hints.line_batch_random_coeff),
        "trace_a_val_l": trace_a_val_l.0,
        "trace_b_val_l": trace_b_val_l.0,
        "trace_c_val_l": trace_c_val_l.0,
        "trace_a_val_r": trace_a_val_r.0,
        "trace_b_val_r": trace_b_val_r.0,
        "trace_c_val_r": trace_c_val_r.0,
        "interaction_ab_0_l": interaction_ab_0_l.0,
        "interaction_ab_1_l": interaction_ab_1_l.0,
        "interaction_ab_2_l": interaction_ab_2_l.0,
        "interaction_ab_3_l": interaction_ab_3_l.0,
        "interaction_sum_0_l": interaction_sum_0_l.0,
        "interaction_sum_1_l": interaction_sum_1_l.0,
        "interaction_sum_2_l": interaction_sum_2_l.0,
        "interaction_sum_3_l": interaction_sum_3_l.0,
        "interaction_ab_0_r": interaction_ab_0_r.0,
        "interaction_ab_1_r": interaction_ab_1_r.0,
        "interaction_ab_2_r": interaction_ab_2_r.0,
        "interaction_ab_3_r": interaction_ab_3_r.0,
        "interaction_sum_0_r": interaction_sum_0_r.0,
        "interaction_sum_1_r": interaction_sum_1_r.0,
        "interaction_sum_2_r": interaction_sum_2_r.0,
        "interaction_sum_3_r": interaction_sum_3_r.0,
        "coeffs_trace_a_val_a": cm31_to_num_vec(coeffs_trace_a_val_a),
        "coeffs_trace_b_val_a": cm31_to_num_vec(coeffs_trace_b_val_a),
        "coeffs_trace_c_val_a": cm31_to_num_vec(coeffs_trace_c_val_a),
        "coeffs_trace_a_val_b": cm31_to_num_vec(coeffs_trace_a_val_b),
        "coeffs_trace_b_val_b": cm31_to_num_vec(coeffs_trace_b_val_b),
        "coeffs_trace_c_val_b": cm31_to_num_vec(coeffs_trace_c_val_b),
    });

    let text2 = json!( {
        "coeffs_interaction_ab_0_a": cm31_to_num_vec(coeffs_interaction_ab_0_a),
        "coeffs_interaction_ab_1_a": cm31_to_num_vec(coeffs_interaction_ab_1_a),
        "coeffs_interaction_ab_2_a": cm31_to_num_vec(coeffs_interaction_ab_2_a),
        "coeffs_interaction_ab_3_a": cm31_to_num_vec(coeffs_interaction_ab_3_a),
        "coeffs_interaction_sum_0_a": cm31_to_num_vec(coeffs_interaction_sum_0_a),
        "coeffs_interaction_sum_1_a": cm31_to_num_vec(coeffs_interaction_sum_1_a),
        "coeffs_interaction_sum_2_a": cm31_to_num_vec(coeffs_interaction_sum_2_a),
        "coeffs_interaction_sum_3_a": cm31_to_num_vec(coeffs_interaction_sum_3_a),
        "coeffs_interaction_ab_0_b": cm31_to_num_vec(coeffs_interaction_ab_0_b),
        "coeffs_interaction_ab_1_b": cm31_to_num_vec(coeffs_interaction_ab_1_b),
        "coeffs_interaction_ab_2_b": cm31_to_num_vec(coeffs_interaction_ab_2_b),
        "coeffs_interaction_ab_3_b": cm31_to_num_vec(coeffs_interaction_ab_3_b),
        "coeffs_interaction_sum_0_b": cm31_to_num_vec(coeffs_interaction_sum_0_b),
        "coeffs_interaction_sum_1_b": cm31_to_num_vec(coeffs_interaction_sum_1_b),
        "coeffs_interaction_sum_2_b": cm31_to_num_vec(coeffs_interaction_sum_2_b),
        "coeffs_interaction_sum_3_b": cm31_to_num_vec(coeffs_interaction_sum_3_b),
        "alpha21_trace_l": qm31_to_num_vec(alpha21_trace_l),
        "alpha21_trace_r": qm31_to_num_vec(alpha21_trace_r),
        "alpha13_interaction_l": qm31_to_num_vec(alpha13_interaction_l),
        "alpha13_interaction_r": qm31_to_num_vec(alpha13_interaction_r),
    });

    for (k, v) in text2.as_object().unwrap() {
        text1.as_object_mut().unwrap().insert(k.clone(), v.clone());
    }

    println!("{}", text1.to_string());
}
