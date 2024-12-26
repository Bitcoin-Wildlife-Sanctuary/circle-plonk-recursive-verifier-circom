use circle_plonk_circom_hints::fiat_shamir::FiatShamirHints;
use serde_json::json;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;

fn main() {
    let hints = FiatShamirHints::new();

    let hash_to_num_vec = |a: &Poseidon31Hash| a.as_limbs();
    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];

    let mut text1 = json!({
        "trace_commitment": hash_to_num_vec(&hints.trace_commitment),
        "alpha": qm31_to_num_vec(hints.alpha),
        "z": qm31_to_num_vec(hints.z),
        "interaction_commitment": hash_to_num_vec(&hints.interaction_commitment),
        "constant_commitment": hash_to_num_vec(&hints.constant_commitment),
        "composition_commitment": hash_to_num_vec(&hints.composition_commitment),
        "random_coeff": qm31_to_num_vec(hints.random_coeff),
        "oods_point_x": qm31_to_num_vec(hints.oods_point_x),
        "oods_point_y": qm31_to_num_vec(hints.oods_point_y),
        "sampled_value_trace_a_val": qm31_to_num_vec(hints.sampled_value_trace_a_val),
        "sampled_value_trace_b_val": qm31_to_num_vec(hints.sampled_value_trace_b_val),
        "sampled_value_trace_c_val": qm31_to_num_vec(hints.sampled_value_trace_c_val),
        "sampled_value_interaction_ab_0": qm31_to_num_vec(hints.sampled_value_interaction_ab_0),
        "sampled_value_interaction_ab_1": qm31_to_num_vec(hints.sampled_value_interaction_ab_1),
        "sampled_value_interaction_ab_2": qm31_to_num_vec(hints.sampled_value_interaction_ab_2),
        "sampled_value_interaction_ab_3": qm31_to_num_vec(hints.sampled_value_interaction_ab_3),
        "sampled_value_interaction_sum_0": qm31_to_num_vec(hints.sampled_value_interaction_sum_0),
        "sampled_value_interaction_sum_1": qm31_to_num_vec(hints.sampled_value_interaction_sum_1),
        "sampled_value_interaction_sum_2": qm31_to_num_vec(hints.sampled_value_interaction_sum_2),
        "sampled_value_interaction_sum_3": qm31_to_num_vec(hints.sampled_value_interaction_sum_3),
        "sampled_value_interaction_shifted_sum_0": qm31_to_num_vec(hints.sampled_value_interaction_shifted_sum_0),
        "sampled_value_interaction_shifted_sum_1": qm31_to_num_vec(hints.sampled_value_interaction_shifted_sum_1),
        "sampled_value_interaction_shifted_sum_2": qm31_to_num_vec(hints.sampled_value_interaction_shifted_sum_2),
        "sampled_value_interaction_shifted_sum_3": qm31_to_num_vec(hints.sampled_value_interaction_shifted_sum_3),
        "sampled_value_constant_mult": qm31_to_num_vec(hints.sampled_value_constant_mult),
        "sampled_value_constant_a_wire": qm31_to_num_vec(hints.sampled_value_constant_a_wire),
        "sampled_value_constant_b_wire": qm31_to_num_vec(hints.sampled_value_constant_b_wire),
        "sampled_value_constant_c_wire": qm31_to_num_vec(hints.sampled_value_constant_c_wire),
        "sampled_value_constant_op": qm31_to_num_vec(hints.sampled_value_constant_op),
        "sampled_value_composition_0": qm31_to_num_vec(hints.sampled_value_composition_0),
        "sampled_value_composition_1": qm31_to_num_vec(hints.sampled_value_composition_1),
        "sampled_value_composition_2": qm31_to_num_vec(hints.sampled_value_composition_2),
        "sampled_value_composition_3": qm31_to_num_vec(hints.sampled_value_composition_3),
        "line_batch_random_coeff": qm31_to_num_vec(hints.line_batch_random_coeff),
        "fri_fold_random_coeff": qm31_to_num_vec(hints.fri_fold_random_coeff)
    });

    let text2 = json!({
        "fri_layer_commitment0": hash_to_num_vec(&hints.fri_layer_commitments[0]),
        "fri_layer_commitment1": hash_to_num_vec(&hints.fri_layer_commitments[1]),
        "fri_layer_commitment2": hash_to_num_vec(&hints.fri_layer_commitments[2]),
        "fri_layer_commitment3": hash_to_num_vec(&hints.fri_layer_commitments[3]),
        "fri_layer_commitment4": hash_to_num_vec(&hints.fri_layer_commitments[4]),
        "fri_layer_commitment5": hash_to_num_vec(&hints.fri_layer_commitments[5]),
        "fri_layer_commitment6": hash_to_num_vec(&hints.fri_layer_commitments[6]),
        "fri_layer_commitment7": hash_to_num_vec(&hints.fri_layer_commitments[7]),
        "fri_layer_commitment8": hash_to_num_vec(&hints.fri_layer_commitments[8]),
        "fri_layer_commitment9": hash_to_num_vec(&hints.fri_layer_commitments[9]),
        "fri_layer_commitment10": hash_to_num_vec(&hints.fri_layer_commitments[10]),
        "fri_layer_commitment11": hash_to_num_vec(&hints.fri_layer_commitments[11]),
        "fri_layer_commitment12": hash_to_num_vec(&hints.fri_layer_commitments[12]),
        "fri_alpha0": qm31_to_num_vec(hints.fri_alphas[0]),
        "fri_alpha1": qm31_to_num_vec(hints.fri_alphas[1]),
        "fri_alpha2": qm31_to_num_vec(hints.fri_alphas[2]),
        "fri_alpha3": qm31_to_num_vec(hints.fri_alphas[3]),
        "fri_alpha4": qm31_to_num_vec(hints.fri_alphas[4]),
        "fri_alpha5": qm31_to_num_vec(hints.fri_alphas[5]),
        "fri_alpha6": qm31_to_num_vec(hints.fri_alphas[6]),
        "fri_alpha7": qm31_to_num_vec(hints.fri_alphas[7]),
        "fri_alpha8": qm31_to_num_vec(hints.fri_alphas[8]),
        "fri_alpha9": qm31_to_num_vec(hints.fri_alphas[9]),
        "fri_alpha10": qm31_to_num_vec(hints.fri_alphas[10]),
        "fri_alpha11": qm31_to_num_vec(hints.fri_alphas[11]),
        "fri_alpha12": qm31_to_num_vec(hints.fri_alphas[12]),
        "last_layer": qm31_to_num_vec(hints.last_layer),
        "nonce": hints.nonce,
        "queries": hints.queries,
    });

    for (k, v) in text2.as_object().unwrap() {
        text1.as_object_mut().unwrap().insert(k.clone(), v.clone());
    }

    println!("{}", text1.to_string());
}
