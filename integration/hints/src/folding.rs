use crate::{FiatShamirHints, QuotientHints};
use itertools::Itertools;
use std::collections::{BTreeMap, HashMap};
use std::io::Cursor;
use stwo_prover::core::circle::M31_CIRCLE_GEN;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::fields::FieldExpOps;
use stwo_prover::core::prover::StarkProof;
use stwo_prover::core::utils::bit_reverse_index;
use stwo_prover::core::vcs::poseidon31_merkle::Poseidon31MerkleHasher;

#[derive(Debug)]
pub struct PerQueryFoldingHints {
    pub queries_parent: u32,

    pub quotient_left: QM31,
    pub quotient_right: QM31,

    pub f_prime: QM31,

    pub siblings: Vec<QM31>,
    pub twiddles: Vec<M31>,
}

#[derive(Debug)]
pub struct FoldingHints {
    pub map: HashMap<u32, PerQueryFoldingHints>,
}

impl FoldingHints {
    pub fn new(
        fiat_shamir_hints: &FiatShamirHints,
        quotient_hints: &QuotientHints,
    ) -> FoldingHints {
        // compute the first butterfly and merge with y
        let queries_parents = fiat_shamir_hints
            .queries
            .iter()
            .map(|x| x >> 1)
            .collect_vec();

        let mut all_maps = vec![];
        let mut queries_and_results = BTreeMap::new();

        for &queries_parent in queries_parents.iter() {
            let idx_l = queries_parent << 1;
            let idx_r = (queries_parent << 1) + 1u32;

            let l = quotient_hints.map.get(&idx_l).unwrap().sum;
            let r = quotient_hints.map.get(&idx_r).unwrap().sum;

            let y = quotient_hints.map.get(&idx_l).unwrap().y;

            let f0_px = l + r;
            let f1_px = (l - r) * y.inverse();

            let f_prime = fiat_shamir_hints.fri_fold_random_coeff * f1_px + f0_px;
            queries_and_results.insert(queries_parent, f_prime);
        }

        let proof_data = include_bytes!("../../test_data/proof.dat");
        let proof: StarkProof<Poseidon31MerkleHasher> =
            bincode::deserialize_from(Cursor::new(proof_data)).unwrap();

        let mut log_size = 18;
        for i in 0..13 {
            let mut iter = proof.commitment_scheme_proof.fri_proof.inner_layers[i]
                .evals_subset
                .iter();

            let mut queries_parent_sorted = queries_and_results.keys().copied().collect_vec();
            queries_parent_sorted.dedup();
            queries_parent_sorted.sort_unstable();

            for &queries_parent in queries_parent_sorted.iter() {
                let sibling = queries_parent ^ 1u32;
                queries_and_results
                    .entry(sibling)
                    .or_insert_with(|| *iter.next().unwrap());
            }
            assert_eq!(iter.next(), None);
            all_maps.push(queries_and_results.clone());

            let mut new_queries_and_results = BTreeMap::new();
            for &queries_parent in queries_parent_sorted.iter() {
                let f_p = *queries_and_results.get(&queries_parent).unwrap();
                let f_neg_p = *queries_and_results.get(&(queries_parent ^ 1u32)).unwrap();

                let itwid = M31_CIRCLE_GEN.repeated_double(31 - log_size - 2)
                    + M31_CIRCLE_GEN
                        .repeated_double(31 - log_size)
                        .mul(
                            bit_reverse_index((queries_parent & 0xfffffffeu32) as usize, log_size)
                                as u128,
                        );

                let (mut f0_px, mut f1_px) = if queries_parent % 2 == 0 {
                    (f_p, f_neg_p)
                } else {
                    (f_neg_p, f_p)
                };

                {
                    let tmp = f0_px;
                    f0_px = tmp + f1_px;
                    f1_px = (tmp - f1_px) * itwid.x.inverse()
                }

                let res = fiat_shamir_hints.fri_alphas[i] * f1_px + f0_px;
                new_queries_and_results.insert(queries_parent >> 1, res);
            }

            queries_and_results = new_queries_and_results;
            log_size -= 1;
        }

        for res in queries_and_results.values() {
            assert_eq!(*res, fiat_shamir_hints.last_layer);
        }

        let mut hints = HashMap::new();
        for &queries_parent in queries_parents.iter() {
            let idx_l = queries_parent << 1;
            let idx_r = (queries_parent << 1) as u32 + 1u32;

            let quotient_left = quotient_hints.map.get(&idx_l).unwrap().sum;
            let quotient_right = quotient_hints.map.get(&idx_r).unwrap().sum;

            let mut siblings = vec![];
            let mut twiddles = vec![];

            let mut cur = queries_parent;
            let mut log_size = 18;
            for i in 0..13 {
                let sibling = all_maps[i].get(&(cur ^ 1)).unwrap();
                siblings.push(*sibling);

                let itwid = M31_CIRCLE_GEN.repeated_double(31 - log_size - 2)
                    + M31_CIRCLE_GEN
                        .repeated_double(31 - log_size)
                        .mul(bit_reverse_index((cur & 0xfffffffeu32) as usize, log_size) as u128);
                twiddles.push(itwid.x.inverse());
                log_size -= 1;
                cur >>= 1;
            }

            hints.insert(
                queries_parent,
                PerQueryFoldingHints {
                    queries_parent,
                    f_prime: *all_maps[0].get(&queries_parent).unwrap(),
                    quotient_left,
                    quotient_right,
                    siblings,
                    twiddles,
                },
            );
        }

        FoldingHints { map: hints }
    }
}
