use serde_json::json;
use stwo_prover::core::fields::qm31::QM31;
use circle_plonk_circom_hints::{FiatShamirHints, FoldingHints, PrepareHints, QuotientHints};

fn main() {
    let fiat_shamir_hints = FiatShamirHints::new();
    let prepare_hints = PrepareHints::new(&fiat_shamir_hints);
    let quotient_hints = QuotientHints::new(&fiat_shamir_hints, &prepare_hints);
    let folding_hints = FoldingHints::new(&fiat_shamir_hints, &quotient_hints);

    let (_, first_folding_hint) = folding_hints.map.iter().next().unwrap();

    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];
    let qm31_vec_to_num_vec = |a: &[QM31]| {
        let mut res = vec![];
        for entry in a {
            res.push(entry.0. 0 .0);
            res.push(entry.0. 1 .0);
            res.push(entry.1. 0 .0);
            res.push(entry.1. 1 .0);
        }
        res
    };

    let text = json!( {
        "query_parent": first_folding_hint.queries_parent,
        "l": qm31_to_num_vec(first_folding_hint.quotient_left),
        "r": qm31_to_num_vec(first_folding_hint.quotient_right),
        "y": quotient_hints.map.get(&(first_folding_hint.queries_parent << 1)).unwrap().y.0,
        "fri_fold_random_coeff": qm31_to_num_vec(fiat_shamir_hints.fri_fold_random_coeff),
        "f_prime": qm31_to_num_vec(first_folding_hint.f_prime),
        "siblings": qm31_vec_to_num_vec(&first_folding_hint.siblings),
        "fri_alphas": qm31_vec_to_num_vec(&fiat_shamir_hints.fri_alphas),
        "last_layer": qm31_to_num_vec(fiat_shamir_hints.last_layer)
    });

    println!("{}", text.to_string());
}