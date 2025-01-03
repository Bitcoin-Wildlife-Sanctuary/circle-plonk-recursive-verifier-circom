use circle_plonk_circom_hints::{
    FiatShamirHints, FoldingHints, MerkleProofPerQuery, PrepareHints, QuotientHints,
    StandaloneMerkleProof,
};
use serde_json::json;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);
    let quotient_hints = QuotientHints::new(&fiat_shamir_hints, &prepare_hints);
    let folding_hints = FoldingHints::new(&fiat_shamir_hints, &quotient_hints);
    let merkle_proofs = MerkleProofPerQuery::new(&fiat_shamir_hints);

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
    let m31_vec_to_num_vec = |a: &[M31]| a.iter().map(|x| x.0).collect::<Vec<_>>();

    let mut all_trace_l = vec![];
    let mut all_trace_r = vec![];
    let mut all_interaction_l = vec![];
    let mut all_interaction_r = vec![];
    let mut all_constant_l = vec![];
    let mut all_constant_r = vec![];
    let mut all_composition_l = vec![];
    let mut all_composition_r = vec![];
    let mut all_siblings = vec![];
    let mut all_siblings_vec = vec![];

    let siblings_to_num_vec = |a: &[StandaloneMerkleProof]| {
        let mut all_siblings = vec![];
        for proof in a.iter() {
            all_siblings.extend_from_slice(&hash_vec_to_num_vec(&proof.siblings));
        }
        all_siblings
    };

    for query_idx in 0..16 {
        let folding_hint = folding_hints
            .map
            .get(&(fiat_shamir_hints.queries[query_idx] >> 1))
            .unwrap();

        let query = fiat_shamir_hints.queries[query_idx];
        let query_parent = query >> 1;

        let query_z = query_parent << 1;
        let query_conjugated_z = (query_parent << 1) + 1;

        let trace_l = quotient_hints.map.get(&query_z).unwrap().trace.clone();
        let trace_r = quotient_hints
            .map
            .get(&query_conjugated_z)
            .unwrap()
            .trace
            .clone();

        let interaction_l = quotient_hints
            .map
            .get(&query_z)
            .unwrap()
            .interaction
            .clone();
        let interaction_r = quotient_hints
            .map
            .get(&query_conjugated_z)
            .unwrap()
            .interaction
            .clone();

        let constant_l = quotient_hints.map.get(&query_z).unwrap().constant.clone();
        let constant_r = quotient_hints
            .map
            .get(&query_conjugated_z)
            .unwrap()
            .constant
            .clone();

        let composition_l = quotient_hints
            .map
            .get(&query_z)
            .unwrap()
            .composition
            .clone();
        let composition_r = quotient_hints
            .map
            .get(&query_conjugated_z)
            .unwrap()
            .composition
            .clone();

        all_trace_l.extend(trace_l);
        all_trace_r.extend(trace_r);
        all_interaction_l.extend(interaction_l);
        all_interaction_r.extend(interaction_r);
        all_constant_l.extend(constant_l);
        all_constant_r.extend(constant_r);
        all_composition_l.extend(composition_l);
        all_composition_r.extend(composition_r);

        all_siblings.extend_from_slice(&folding_hint.siblings);
        assert_eq!(
            folding_hint.queries_parent,
            fiat_shamir_hints.queries[query_idx] >> 1
        );

        let siblings_vec = siblings_to_num_vec(&folding_hint.merkle_proofs);
        all_siblings_vec.extend(siblings_vec);
    }

    let mut all_trace_siblings = vec![];
    let mut all_interaction_siblings = vec![];
    let mut all_constant_siblings = vec![];
    let mut all_composition_siblings = vec![];

    for proof in merkle_proofs.iter() {
        all_trace_siblings.extend(hash_vec_to_num_vec(&proof.trace.siblings));
        all_interaction_siblings.extend(hash_vec_to_num_vec(&proof.interaction.siblings));
        all_constant_siblings.extend(hash_vec_to_num_vec(&proof.constant.siblings));
        all_composition_siblings.extend(hash_vec_to_num_vec(&proof.composition.siblings));
    }

    let text_fiat_shamir = json!({
        "trace_commitment": hash_to_num_vec(&fiat_shamir_hints.trace_commitment),
        "interaction_commitment": hash_to_num_vec(&fiat_shamir_hints.interaction_commitment),
        "constant_commitment": hash_to_num_vec(&fiat_shamir_hints.constant_commitment),
        "composition_commitment": hash_to_num_vec(&fiat_shamir_hints.composition_commitment),
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
        "fri_layer_commitments": hash_vec_to_num_vec(&fiat_shamir_hints.fri_layer_commitments),
        "last_layer": qm31_to_num_vec(fiat_shamir_hints.last_layer),
        "nonce": fiat_shamir_hints.nonce,
        "claimed_sum": qm31_to_num_vec(prepare_hints.claimed_sum),
        "all_trace_l": m31_vec_to_num_vec(&all_trace_l),
        "all_trace_r": m31_vec_to_num_vec(&all_trace_r),
        "all_interaction_l": m31_vec_to_num_vec(&all_interaction_l),
        "all_interaction_r": m31_vec_to_num_vec(&all_interaction_r),
        "all_constant_l": m31_vec_to_num_vec(&all_constant_l),
        "all_constant_r": m31_vec_to_num_vec(&all_constant_r),
        "all_composition_l": m31_vec_to_num_vec(&all_composition_l),
        "all_composition_r": m31_vec_to_num_vec(&all_composition_r),
        "all_siblings": qm31_vec_to_num_vec(&all_siblings),
        "all_fri_siblings": all_siblings_vec,
        "all_trace_siblings": all_trace_siblings,
        "all_interaction_siblings": all_interaction_siblings,
        "all_constant_siblings": all_constant_siblings,
        "all_composition_siblings": all_composition_siblings,
    });

    println!("{}", text_fiat_shamir.to_string());
}
