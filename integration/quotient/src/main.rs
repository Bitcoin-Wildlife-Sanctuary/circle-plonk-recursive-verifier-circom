use circle_plonk_circom_hints::{FiatShamirHints, PrepareHints, QuotientHints};
use serde_json::json;
use stwo_prover::core::fields::cm31::CM31;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::QM31;

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);
    let quotient_hints = QuotientHints::new(&fiat_shamir_hints, &prepare_hints);

    let query = fiat_shamir_hints.queries[0];
    let query_parent = query >> 1;

    let query_z = query_parent << 1;
    let query_conjugated_z = (query_parent << 1) + 1;

    let trace_l = quotient_hints.map.get(&query_z).unwrap().trace.clone();
    let trace_r = quotient_hints.map.get(&query_conjugated_z).unwrap().trace.clone();

    let coeffs_trace_a = prepare_hints.trace_column_line_coeffs_a;
    let coeffs_trace_b = prepare_hints.trace_column_line_coeffs_b;

    let interaction_l = quotient_hints.map.get(&query_z).unwrap().interaction.clone();
    let interaction_r = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction.clone();

    let coeffs_interaction_a = prepare_hints.interaction_column_line_coeffs_a;
    let coeffs_interaction_b = prepare_hints.interaction_column_line_coeffs_b;

    let constant_l = quotient_hints.map.get(&query_z).unwrap().constant.clone();
    let constant_r = quotient_hints.map.get(&query_conjugated_z).unwrap().constant.clone();

    let coeffs_constant_a = prepare_hints.constant_column_line_coeffs_a;
    let coeffs_constant_b = prepare_hints.constant_column_line_coeffs_b;

    let composition_l = quotient_hints.map.get(&query_z).unwrap().composition.clone();
    let composition_r = quotient_hints.map.get(&query_conjugated_z).unwrap().composition.clone();

    let coeffs_composition_a = prepare_hints.composition_column_line_coeffs_a;
    let coeffs_composition_b = prepare_hints.composition_column_line_coeffs_b;

    let coeffs_interaction_shifted_a = prepare_hints.interaction_shifted_column_line_coeffs_a;
    let coeffs_interaction_shifted_b = prepare_hints.interaction_shifted_column_line_coeffs_b;

    let trace_l_sum = quotient_hints.map.get(&query_z).unwrap().trace_sum;
    let trace_r_sum = quotient_hints
        .map
        .get(&query_conjugated_z)
        .unwrap()
        .trace_sum;

    let interaction_l_sum = quotient_hints.map.get(&query_z).unwrap().interaction_sum;
    let interaction_r_sum = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_sum;

    let constant_l_sum = quotient_hints.map.get(&query_z).unwrap().constant_sum;
    let constant_r_sum = quotient_hints.map.get(&query_conjugated_z).unwrap().constant_sum;

    let composition_l_sum = quotient_hints.map.get(&query_z).unwrap().composition_sum;
    let composition_r_sum = quotient_hints.map.get(&query_conjugated_z).unwrap().composition_sum;

    let interaction_shifted_l_sum = quotient_hints.map.get(&query_z).unwrap().interaction_shifted_sum;
    let interaction_shifted_r_sum = quotient_hints.map.get(&query_conjugated_z).unwrap().interaction_shifted_sum;

    let alpha4_times_oods_part_l_sum = quotient_hints.map.get(&query_z).unwrap().alpha4_times_oods_part_sum;
    let alpha4_times_oods_part_r_sum = quotient_hints.map.get(&query_conjugated_z).unwrap().alpha4_times_oods_part_sum;

    let qm31_to_num_vec = |a: QM31| [a.0.0.0, a.0.1.0, a.1.0.0, a.1.1.0];
    let m31_vec_to_num_vec = |a: &[M31]| a.iter().map(|x| x.0).collect::<Vec<_>>();
    let cm31_vec_to_num_vec = |a: &[CM31]| {
        let mut res = vec![];
        for entry in a {
            res.push(entry.0.0);
            res.push(entry.1.0);
        }
        res
    };

    let mut text1 = json!({
        "query": query,
        "alpha": qm31_to_num_vec(fiat_shamir_hints.line_batch_random_coeff),
        "trace_l": m31_vec_to_num_vec(&trace_l),
        "trace_r": m31_vec_to_num_vec(&trace_r),
        "interaction_l": m31_vec_to_num_vec(&interaction_l),
        "interaction_r": m31_vec_to_num_vec(&interaction_r),
        "constant_l": m31_vec_to_num_vec(&constant_l),
        "constant_r": m31_vec_to_num_vec(&constant_r),
        "composition_l": m31_vec_to_num_vec(&composition_l),
        "composition_r": m31_vec_to_num_vec(&composition_r),
        "coeffs_trace_a": cm31_vec_to_num_vec(&coeffs_trace_a),
        "coeffs_trace_b": cm31_vec_to_num_vec(&coeffs_trace_b),
        "coeffs_interaction_a": cm31_vec_to_num_vec(&coeffs_interaction_a),
        "coeffs_interaction_b": cm31_vec_to_num_vec(&coeffs_interaction_b),
    });

    let text2 = json!( {
        "coeffs_constant_a": cm31_vec_to_num_vec(&coeffs_constant_a),
        "coeffs_constant_b": cm31_vec_to_num_vec(&coeffs_constant_b),
        "coeffs_composition_a": cm31_vec_to_num_vec(&coeffs_composition_a),
        "coeffs_composition_b": cm31_vec_to_num_vec(&coeffs_composition_b),
        "coeffs_interaction_shifted_a": cm31_vec_to_num_vec(&coeffs_interaction_shifted_a),
        "coeffs_interaction_shifted_b": cm31_vec_to_num_vec(&coeffs_interaction_shifted_b),
        "interaction_shifted_l_sum": qm31_to_num_vec(interaction_shifted_l_sum),
        "interaction_shifted_r_sum": qm31_to_num_vec(interaction_shifted_r_sum),
        "alpha4_times_oods_part_l_sum": qm31_to_num_vec(alpha4_times_oods_part_l_sum),
        "alpha4_times_oods_part_r_sum": qm31_to_num_vec(alpha4_times_oods_part_r_sum)
    });

    for (k, v) in text2.as_object().unwrap() {
        text1.as_object_mut().unwrap().insert(k.clone(), v.clone());
    }

    println!("{}", text1.to_string());
}
