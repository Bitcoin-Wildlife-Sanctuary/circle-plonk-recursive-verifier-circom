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
    let qm31_vec_to_num_vec = |a: &[QM31]| {
        let mut res = vec![];
        for entry in a {
            res.push(entry.0 .0 .0);
            res.push(entry.0 .1 .0);
            res.push(entry.1 .0 .0);
            res.push(entry.1 .1 .0);
        }
        res
    };

    let text = json!({
        "random_coeff": qm31_to_num_vec(fiat_shamir_hints.random_coeff),
        "alpha": qm31_to_num_vec(fiat_shamir_hints.alpha),
        "z": qm31_to_num_vec(fiat_shamir_hints.z),
        "constraint_num": qm31_to_num_vec(prepare_hints.constraint_num),
        "constraint_denom": qm31_to_num_vec(prepare_hints.constraint_denom),
        "oods_point_x": qm31_to_num_vec(fiat_shamir_hints.oods_point_x),
        "oods_point_y": qm31_to_num_vec(fiat_shamir_hints.oods_point_y),
        "oods_a": cm31_to_num_vec(prepare_hints.oods_a),
        "oods_b": cm31_to_num_vec(prepare_hints.oods_b),
        "oods_shifted_a": cm31_to_num_vec(prepare_hints.oods_shifted_a),
        "oods_shifted_b": cm31_to_num_vec(prepare_hints.oods_shifted_b),
        "claimed_sum": qm31_to_num_vec(prepare_hints.claimed_sum),
        "sampled_value_trace": qm31_vec_to_num_vec(
            &[fiat_shamir_hints.sampled_value_trace_a_val, fiat_shamir_hints.sampled_value_trace_b_val, fiat_shamir_hints.sampled_value_trace_c_val]
        ),
        "sampled_value_interaction": qm31_vec_to_num_vec(&[
            fiat_shamir_hints.sampled_value_interaction_ab_0,
            fiat_shamir_hints.sampled_value_interaction_ab_1,
            fiat_shamir_hints.sampled_value_interaction_ab_2,
            fiat_shamir_hints.sampled_value_interaction_ab_3,
            fiat_shamir_hints.sampled_value_interaction_sum_0,
            fiat_shamir_hints.sampled_value_interaction_sum_1,
            fiat_shamir_hints.sampled_value_interaction_sum_2,
            fiat_shamir_hints.sampled_value_interaction_sum_3,
        ]),
        "sampled_value_interaction_shifted": qm31_vec_to_num_vec(&[
            fiat_shamir_hints.sampled_value_interaction_shifted_sum_0,
            fiat_shamir_hints.sampled_value_interaction_shifted_sum_1,
            fiat_shamir_hints.sampled_value_interaction_shifted_sum_2,
            fiat_shamir_hints.sampled_value_interaction_shifted_sum_3,
        ]),
        "sampled_value_constant": qm31_vec_to_num_vec(&[
            fiat_shamir_hints.sampled_value_constant_mult,
            fiat_shamir_hints.sampled_value_constant_a_wire,
            fiat_shamir_hints.sampled_value_constant_b_wire,
            fiat_shamir_hints.sampled_value_constant_c_wire,
            fiat_shamir_hints.sampled_value_constant_op
        ]),
        "sampled_value_composition": qm31_vec_to_num_vec(&[
            fiat_shamir_hints.sampled_value_composition_0,
            fiat_shamir_hints.sampled_value_composition_1,
            fiat_shamir_hints.sampled_value_composition_2,
            fiat_shamir_hints.sampled_value_composition_3,
        ]),
        "coeffs_trace_a": flatten_cm31_vec(&prepare_hints.trace_column_line_coeffs_a),
        "coeffs_trace_b": flatten_cm31_vec(&prepare_hints.trace_column_line_coeffs_b),
        "coeffs_interaction_a": flatten_cm31_vec(&prepare_hints.interaction_column_line_coeffs_a),
        "coeffs_interaction_b": flatten_cm31_vec(&prepare_hints.interaction_column_line_coeffs_b),
        "coeffs_interaction_shifted_a": flatten_cm31_vec(&prepare_hints.interaction_shifted_column_line_coeffs_a),
        "coeffs_interaction_shifted_b": flatten_cm31_vec(&prepare_hints.interaction_shifted_column_line_coeffs_b),
        "coeffs_constant_a": flatten_cm31_vec(&prepare_hints.constant_column_line_coeffs_a),
        "coeffs_constant_b": flatten_cm31_vec(&prepare_hints.constant_column_line_coeffs_b),
        "coeffs_composition_a": flatten_cm31_vec(&prepare_hints.composition_column_line_coeffs_a),
        "coeffs_composition_b": flatten_cm31_vec(&prepare_hints.composition_column_line_coeffs_b),
    });

    println!("{}", text.to_string());
}
