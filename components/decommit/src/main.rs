use circle_plonk_circom_hints::{FiatShamirHints, MerkleProofPerQuery, PrepareHints, QuotientHints};
use serde_json::json;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);
    let quotient_hints = QuotientHints::new(&fiat_shamir_hints, &prepare_hints);
    let merkle_proofs = MerkleProofPerQuery::new(&fiat_shamir_hints);

    // test on the first proof
    let cur_proof = &merkle_proofs[0];

    let queries_parent = cur_proof.trace.queries_parent as u32;
    let left_quotient = quotient_hints.map.get(&(queries_parent << 1)).unwrap();
    let right_quotient = quotient_hints
        .map
        .get(&((queries_parent << 1) + 1))
        .unwrap();

    let m31_vec_to_num_vec = |a: &[M31]| a.iter().map(|x| x.0).collect::<Vec<_>>();
    let hash_to_num_vec = |v: Poseidon31Hash| v.as_limbs();
    let hash_vec_to_num_vec = |v: &[Poseidon31Hash]| {
        let mut arr = vec![];
        for vv in v.iter() {
            arr.extend(vv.as_limbs());
        }
        arr
    };

    let text = json!({
        "queries_parent": cur_proof.trace.queries_parent,
        "trace_left": m31_vec_to_num_vec(&left_quotient.trace),
        "trace_right": m31_vec_to_num_vec(&right_quotient.trace),
        "interaction_left": m31_vec_to_num_vec(&left_quotient.interaction),
        "interaction_right": m31_vec_to_num_vec(&right_quotient.interaction),
        "constant_left": m31_vec_to_num_vec(&left_quotient.constant),
        "constant_right": m31_vec_to_num_vec(&right_quotient.constant),
        "composition_left": m31_vec_to_num_vec(&left_quotient.composition),
        "composition_right": m31_vec_to_num_vec(&right_quotient.composition),
        "trace_siblings": hash_vec_to_num_vec(&cur_proof.trace.siblings),
        "trace_root": hash_to_num_vec(cur_proof.trace.root),
        "interaction_siblings": hash_vec_to_num_vec(&cur_proof.interaction.siblings),
        "interaction_root": hash_to_num_vec(cur_proof.interaction.root),
        "constant_siblings": hash_vec_to_num_vec(&cur_proof.constant.siblings),
        "constant_root": hash_to_num_vec(cur_proof.constant.root),
        "composition_siblings": hash_vec_to_num_vec(&cur_proof.composition.siblings),
        "composition_root": hash_to_num_vec(cur_proof.composition.root),
    });

    println!("{}", text);
}
