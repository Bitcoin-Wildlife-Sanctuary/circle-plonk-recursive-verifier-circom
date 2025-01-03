use crate::{FiatShamirHints, QuotientHints, StandaloneMerkleProof};
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

    pub merkle_proofs: Vec<StandaloneMerkleProof>,
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


        let mut cur_fri_queries = Vec::new();
        for queries_parent in queries_parents.iter() {
            cur_fri_queries.push((queries_parent >> 1) as usize);
        }
        let mut all_fri_proofs = vec![];
        for i in 0..13 {
            // find out all the queried positions and sort them
            let mut queries = vec![];
            for &queries_parent in cur_fri_queries.iter() {
                queries.push((queries_parent << 1) as u32);
                queries.push(((queries_parent << 1) + 1usize) as u32);
            }
            queries.sort_unstable();
            queries.dedup();

            let mut values = [vec![], vec![], vec![], vec![]];
            for query in queries.iter() {
                let v = all_maps[i].get(&query).unwrap();
                values[0].push(v.0.0);
                values[1].push(v.0.1);
                values[2].push(v.1.0);
                values[3].push(v.1.1);
            }

            let proofs = StandaloneMerkleProof::from_stwo_proof(
                19 - 1 - i,
                &cur_fri_queries,
                &values,
                proof.commitment_scheme_proof.fri_proof.inner_layers[i].commitment,
                &proof.commitment_scheme_proof.fri_proof.inner_layers[i].decommitment,
            );

            for proof in proofs.iter() {
                proof.verify();
            }

            let mut map = HashMap::new();
            let mut new_fri_queries = Vec::new();
            for (&queries_parent, proof) in cur_fri_queries.iter().zip(proofs.iter()) {
                map.insert(queries_parent, proof.clone());
                new_fri_queries.push(queries_parent >> 1);
            }
            new_fri_queries.sort_unstable();
            new_fri_queries.dedup();

            all_fri_proofs.push(map);

            cur_fri_queries = new_fri_queries;
        }

        let mut hints = HashMap::new();
        for &queries_parent in queries_parents.iter() {
            let idx_l = queries_parent << 1;
            let idx_r = (queries_parent << 1) as u32 + 1u32;

            let quotient_left = quotient_hints.map.get(&idx_l).unwrap().sum;
            let quotient_right = quotient_hints.map.get(&idx_r).unwrap().sum;

            let mut intermediates = vec![];
            let mut siblings = vec![];
            let mut twiddles = vec![];

            let mut cur = queries_parent;
            let mut log_size = 18;
            for i in 0..13 {
                let intermediate = all_maps[i].get(&cur).unwrap();
                intermediates.push(*intermediate);

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

            let mut merkle_proofs = vec![];
            {
                let mut queries_parent = (queries_parent as usize) >> 1;
                for j in 0..13 {
                    merkle_proofs.push(all_fri_proofs[j].get(&queries_parent).unwrap().clone());
                    queries_parent >>= 1;
                }
            }

            hints.insert(
                queries_parent,
                PerQueryFoldingHints {
                    queries_parent,
                    f_prime: *all_maps[0].get(&queries_parent).unwrap(),
                    quotient_left,
                    quotient_right,
                    merkle_proofs,
                    siblings,
                    twiddles,
                },
            );
        }

        FoldingHints { map: hints }
    }
}
