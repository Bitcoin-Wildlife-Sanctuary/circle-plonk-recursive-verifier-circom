use circle_plonk_circom_hints::fiat_shamir::FiatShamirHints;
use circle_plonk_circom_hints::PrepareHints;
use serde_json::json;
use stwo_prover::core::fields::cm31::CM31;
use stwo_prover::core::fields::qm31::QM31;

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);

    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];
    let cm31_to_num_vec = |a: CM31| [a.0 .0, a.1 .0];

    let flatten_cm31_vec = |a: &[CM31]| {
        a.iter()
            .map(|x| cm31_to_num_vec(*x))
            .flatten()
            .collect::<Vec<u32>>()
    };

    let mut text1 = json!({
        "random_coeff": qm31_to_num_vec(fiat_shamir_hints.random_coeff),
        "a_val": qm31_to_num_vec(fiat_shamir_hints.sampled_value_trace_a_val),
        "b_val": qm31_to_num_vec(fiat_shamir_hints.sampled_value_trace_b_val),
        "c_val": qm31_to_num_vec(fiat_shamir_hints.sampled_value_trace_c_val),
        "op": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_op),
        "a_wire": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_a_wire),
        "b_wire": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_b_wire),
        "c_wire": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_c_wire),
        "alpha": qm31_to_num_vec(fiat_shamir_hints.alpha),
        "z": qm31_to_num_vec(fiat_shamir_hints.z),
        "a_b_logup_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_0),
        "a_b_logup_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_1),
        "a_b_logup_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_2),
        "a_b_logup_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_3),
        "c_logup_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_0),
        "c_logup_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_1),
        "c_logup_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_2),
        "c_logup_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_3),
        "c_logup_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_3),
        "c_logup_next_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_0),
        "c_logup_next_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_1),
        "c_logup_next_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_2),
        "c_logup_next_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_3),
        "mult": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_mult),
        "constraint_num": qm31_to_num_vec(prepare_hints.constraint_num),
        "constraint_denom": qm31_to_num_vec(prepare_hints.constraint_denom),
        "oods_point_x": qm31_to_num_vec(fiat_shamir_hints.oods_point_x),
        "oods_point_y": qm31_to_num_vec(fiat_shamir_hints.oods_point_y),
        "oods_a": cm31_to_num_vec(prepare_hints.oods_a),
        "oods_b": cm31_to_num_vec(prepare_hints.oods_b),
        "oods_shifted_a": cm31_to_num_vec(prepare_hints.oods_shifted_a),
        "oods_shifted_b": cm31_to_num_vec(prepare_hints.oods_shifted_b),
        "claimed_sum": qm31_to_num_vec(prepare_hints.claimed_sum),
    });

    let text2 = json!({
        "trace_column_line_coeffs_a": flatten_cm31_vec(&prepare_hints.trace_column_line_coeffs_a),
        "trace_column_line_coeffs_b": flatten_cm31_vec(&prepare_hints.trace_column_line_coeffs_b),
        "interaction_column_line_coeffs_a": flatten_cm31_vec(&prepare_hints.interaction_column_line_coeffs_a),
        "interaction_column_line_coeffs_b": flatten_cm31_vec(&prepare_hints.interaction_column_line_coeffs_b),
        "interaction_shifted_column_line_coeffs_a": flatten_cm31_vec(&prepare_hints.interaction_shifted_column_line_coeffs_a),
        "interaction_shifted_column_line_coeffs_b": flatten_cm31_vec(&prepare_hints.interaction_shifted_column_line_coeffs_b),
        "constant_column_line_coeffs_a": flatten_cm31_vec(&prepare_hints.constant_column_line_coeffs_a),
        "constant_column_line_coeffs_b": flatten_cm31_vec(&prepare_hints.constant_column_line_coeffs_b),
        "composition_column_line_coeffs_a": flatten_cm31_vec(&prepare_hints.composition_column_line_coeffs_a),
        "composition_column_line_coeffs_b": flatten_cm31_vec(&prepare_hints.composition_column_line_coeffs_b),
        "sampled_value_trace_a_val": qm31_to_num_vec(fiat_shamir_hints.sampled_value_trace_a_val),
        "sampled_value_trace_b_val": qm31_to_num_vec(fiat_shamir_hints.sampled_value_trace_b_val),
        "sampled_value_trace_c_val": qm31_to_num_vec(fiat_shamir_hints.sampled_value_trace_c_val),
        "sampled_value_interaction_ab_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_0),
        "sampled_value_interaction_ab_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_1),
        "sampled_value_interaction_ab_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_2),
        "sampled_value_interaction_ab_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_ab_3),
        "sampled_value_interaction_sum_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_0),
        "sampled_value_interaction_sum_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_1),
        "sampled_value_interaction_sum_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_2),
        "sampled_value_interaction_sum_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_sum_3),
        "sampled_value_interaction_shifted_sum_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_0),
        "sampled_value_interaction_shifted_sum_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_1),
        "sampled_value_interaction_shifted_sum_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_2),
        "sampled_value_interaction_shifted_sum_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_interaction_shifted_sum_3),
        "sampled_value_constant_mult": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_mult),
        "sampled_value_constant_a_wire": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_a_wire),
        "sampled_value_constant_b_wire": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_b_wire),
        "sampled_value_constant_c_wire": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_c_wire),
        "sampled_value_constant_op": qm31_to_num_vec(fiat_shamir_hints.sampled_value_constant_op),
        "sampled_value_composition_0": qm31_to_num_vec(fiat_shamir_hints.sampled_value_composition_0),
        "sampled_value_composition_1": qm31_to_num_vec(fiat_shamir_hints.sampled_value_composition_1),
        "sampled_value_composition_2": qm31_to_num_vec(fiat_shamir_hints.sampled_value_composition_2),
        "sampled_value_composition_3": qm31_to_num_vec(fiat_shamir_hints.sampled_value_composition_3),
    });

    for (k, v) in text2.as_object().unwrap() {
        text1.as_object_mut().unwrap().insert(k.clone(), v.clone());
    }

    println!("{}", text1.to_string());
}
