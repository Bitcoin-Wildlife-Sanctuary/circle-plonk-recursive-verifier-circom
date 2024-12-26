use circle_plonk_circom_hints::fiat_shamir::FiatShamirHints;
use circle_plonk_circom_hints::PrepareHints;
use serde_json::json;
use stwo_prover::core::fields::qm31::QM31;

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);

    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];

    let text = json!({
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
        "claimed_sum": qm31_to_num_vec(prepare_hints.claimed_sum),
    });

    println!("{}", text.to_string());
}
