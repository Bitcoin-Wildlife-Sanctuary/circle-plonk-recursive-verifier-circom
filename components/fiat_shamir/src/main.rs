use circle_plonk_circom_hints::fiat_shamir::FiatShamirHints;
use serde_json::json;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;

fn main() {
    let hints = FiatShamirHints::new();

    let hash_to_num_vec = |a: &Poseidon31Hash| a.as_limbs();
    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];
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
    let hash_vec_to_num_vec = |v: &[Poseidon31Hash]| {
        let mut arr = vec![];
        for vv in v.iter() {
            arr.extend(vv.as_limbs());
        }
        arr
    };

    let text = json!({
        "trace_commitment": hash_to_num_vec(&hints.trace_commitment),
        "alpha": qm31_to_num_vec(hints.alpha),
        "z": qm31_to_num_vec(hints.z),
        "interaction_commitment": hash_to_num_vec(&hints.interaction_commitment),
        "constant_commitment": hash_to_num_vec(&hints.constant_commitment),
        "composition_commitment": hash_to_num_vec(&hints.composition_commitment),
        "random_coeff": qm31_to_num_vec(hints.random_coeff),
        "oods_point_x": qm31_to_num_vec(hints.oods_point_x),
        "oods_point_y": qm31_to_num_vec(hints.oods_point_y),
        "sampled_value_trace": qm31_vec_to_num_vec(
            &[hints.sampled_value_trace_a_val, hints.sampled_value_trace_b_val, hints.sampled_value_trace_c_val]
        ),
        "sampled_value_interaction": qm31_vec_to_num_vec(&[
            hints.sampled_value_interaction_ab_0,
            hints.sampled_value_interaction_ab_1,
            hints.sampled_value_interaction_ab_2,
            hints.sampled_value_interaction_ab_3,
            hints.sampled_value_interaction_sum_0,
            hints.sampled_value_interaction_sum_1,
            hints.sampled_value_interaction_sum_2,
            hints.sampled_value_interaction_sum_3,
        ]),
        "sampled_value_interaction_shifted": qm31_vec_to_num_vec(&[
            hints.sampled_value_interaction_shifted_sum_0,
            hints.sampled_value_interaction_shifted_sum_1,
            hints.sampled_value_interaction_shifted_sum_2,
            hints.sampled_value_interaction_shifted_sum_3,
        ]),
        "sampled_value_constant": qm31_vec_to_num_vec(&[
            hints.sampled_value_constant_mult,
            hints.sampled_value_constant_a_wire,
            hints.sampled_value_constant_b_wire,
            hints.sampled_value_constant_c_wire,
            hints.sampled_value_constant_op
        ]),
        "sampled_value_composition": qm31_vec_to_num_vec(&[
            hints.sampled_value_composition_0,
            hints.sampled_value_composition_1,
            hints.sampled_value_composition_2,
            hints.sampled_value_composition_3,
        ]),
        "line_batch_random_coeff": qm31_to_num_vec(hints.line_batch_random_coeff),
        "fri_fold_random_coeff": qm31_to_num_vec(hints.fri_fold_random_coeff),
        "fri_layer_commitments": hash_vec_to_num_vec(&hints.fri_layer_commitments),
        "fri_alphas": qm31_vec_to_num_vec(&hints.fri_alphas),
        "last_layer": qm31_to_num_vec(hints.last_layer),
        "nonce": hints.nonce,
        "queries": hints.queries,
    });

    println!("{}", text.to_string());
}
