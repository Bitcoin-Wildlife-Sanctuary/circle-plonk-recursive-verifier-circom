use crate::FiatShamirHints;
use itertools::Itertools;
use poseidon2_m31::Poseidon31CRH;
use std::collections::{BTreeSet, HashMap};
use std::io::Cursor;
use stwo_prover::core::fields::m31::{BaseField, M31};
use stwo_prover::core::prover::StarkProof;
use stwo_prover::core::vcs::ops::MerkleHasher;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;
use stwo_prover::core::vcs::poseidon31_merkle::Poseidon31MerkleHasher;
use stwo_prover::core::vcs::prover::MerkleDecommitment;

#[derive(Clone, Debug)]
pub struct StandaloneMerkleProof {
    pub queries_parent: usize,
    pub parent_hash: Poseidon31Hash,
    pub siblings: Vec<Poseidon31Hash>,
    pub root: Poseidon31Hash,
    pub depth: usize,
}

impl StandaloneMerkleProof {
    pub fn verify(&self) {
        assert_eq!(self.siblings.len(), self.depth - 1);

        let mut cur_elem = self.parent_hash;
        let mut cur_idx = self.queries_parent;

        for i in 0..self.depth - 1 {
            let (left, right) = if cur_idx & 1 == 0 {
                (cur_elem, self.siblings[i])
            } else {
                (self.siblings[i], cur_elem)
            };

            let mut v = vec![];
            for i in 0..8 {
                v.push(left.0[i].0);
            }
            for i in 0..8 {
                v.push(right.0[i].0);
            }
            assert_eq!(v.len(), 16);

            let hash = Poseidon31CRH::hash_fixed_length(&v);
            let res = [
                M31(hash[0]),
                M31(hash[1]),
                M31(hash[2]),
                M31(hash[3]),
                M31(hash[4]),
                M31(hash[5]),
                M31(hash[6]),
                M31(hash[7]),
            ];

            cur_elem = Poseidon31Hash(res);
            cur_idx >>= 1;
        }

        assert_eq!(cur_elem, self.root);
    }

    pub fn from_stwo_proof(
        logn: usize,
        queries_parents: &[usize],
        values: &[Vec<BaseField>],
        root: Poseidon31Hash,
        merkle_decommitment: &MerkleDecommitment<Poseidon31MerkleHasher>,
    ) -> Vec<StandaloneMerkleProof> {
        // find out all the queried positions and sort them
        let mut queries = vec![];
        for &queries_parent in queries_parents.iter() {
            queries.push(queries_parent << 1);
            queries.push((queries_parent << 1) + 1);
        }
        queries.sort_unstable();
        queries.dedup();

        // get the number of columns
        let column_num = values.len();

        // create the new value map
        let mut queries_values_map = HashMap::new();
        for (idx, &query) in queries.iter().enumerate() {
            let mut v = vec![];
            for value in values.iter().take(column_num) {
                v.push(value[idx]);
            }
            queries_values_map.insert(query, v);
        }

        // require the column witness to be empty
        assert!(merkle_decommitment.column_witness.is_empty());

        // turn hash witness into an iterator
        let mut hash_iterator = merkle_decommitment.hash_witness.iter();

        // create the merkle partial tree
        let mut layers: Vec<HashMap<usize, Poseidon31Hash>> = vec![];

        // create the leaf layer
        let mut layer = HashMap::new();
        for (&query, value) in queries_values_map.iter() {
            layer.insert(query, Poseidon31MerkleHasher::hash_node(None, value));
        }
        layers.push(layer);

        let mut positions = queries_parents.to_vec();
        positions.sort_unstable();

        // create the intermediate layers
        for i in 0..(logn - 1) {
            let mut layer = HashMap::new();
            let mut parents = BTreeSet::new();

            for &position in positions.iter() {
                layer.insert(
                    position,
                    Poseidon31MerkleHasher::hash_node(
                        Some((
                            *layers[i].get(&(position << 1)).unwrap(),
                            *layers[i].get(&((position << 1) + 1)).unwrap(),
                        )),
                        &[],
                    ),
                );

                if !positions.contains(&(position ^ 1)) && !layer.contains_key(&(position ^ 1)) {
                    layer.insert(position ^ 1, *hash_iterator.next().unwrap());
                }
                parents.insert(position >> 1);
            }

            layers.push(layer);
            positions = parents.iter().copied().collect::<Vec<usize>>();
        }

        assert_eq!(hash_iterator.next(), None);

        // cheery-pick the Merkle tree paths to construct the deterministic proofs
        let mut res = vec![];
        for &queries_parent in queries_parents.iter() {
            let mut siblings = vec![];

            let mut cur = queries_parent;
            for layer in layers.iter().take(logn).skip(1) {
                siblings.push(*layer.get(&(cur ^ 1)).unwrap());
                cur >>= 1;
            }

            res.push(StandaloneMerkleProof {
                queries_parent: queries_parent,
                parent_hash: *layers[1].get(&queries_parent).unwrap(),
                siblings,
                root: root.clone(),
                depth: logn,
            });
        }
        res
    }
}

pub struct MerkleProofPerQuery {
    pub trace: StandaloneMerkleProof,
    pub interaction: StandaloneMerkleProof,
    pub constant: StandaloneMerkleProof,
    pub composition: StandaloneMerkleProof,
}

impl MerkleProofPerQuery {
    pub fn new(fiat_shamir_hints: &FiatShamirHints) -> Vec<MerkleProofPerQuery> {
        let proof_data = include_bytes!("../../test_data/proof.dat");
        let proof: StarkProof<Poseidon31MerkleHasher> =
            bincode::deserialize_from(Cursor::new(proof_data)).unwrap();

        let queries_parents = fiat_shamir_hints
            .queries
            .iter()
            .map(|x| (x >> 1) as usize)
            .collect_vec();

        let mut queries = vec![];
        for queries_parent in queries_parents.iter() {
            queries.push(queries_parent << 1);
            queries.push((queries_parent << 1) + 1usize);
        }
        queries.sort_unstable();
        queries.dedup();

        let logn = 19;
        let trace_merkle_proofs = StandaloneMerkleProof::from_stwo_proof(
            logn,
            &queries_parents,
            &proof.commitment_scheme_proof.queried_values[0],
            proof.commitments.0[0],
            &proof.commitment_scheme_proof.decommitments.0[0],
        );
        for proof in trace_merkle_proofs.iter() {
            proof.verify();
        }

        let interaction_merkle_proofs = StandaloneMerkleProof::from_stwo_proof(
            logn,
            &queries_parents,
            &proof.commitment_scheme_proof.queried_values[1],
            proof.commitments.0[1],
            &proof.commitment_scheme_proof.decommitments.0[1],
        );
        for proof in interaction_merkle_proofs.iter() {
            proof.verify();
        }

        let constant_merkle_proofs = StandaloneMerkleProof::from_stwo_proof(
            logn,
            &queries_parents,
            &proof.commitment_scheme_proof.queried_values[2],
            proof.commitments.0[2],
            &proof.commitment_scheme_proof.decommitments.0[2],
        );
        for proof in constant_merkle_proofs.iter() {
            proof.verify();
        }

        let composition_merkle_proofs = StandaloneMerkleProof::from_stwo_proof(
            logn,
            &queries_parents,
            &proof.commitment_scheme_proof.queried_values[3],
            proof.commitments.0[3],
            &proof.commitment_scheme_proof.decommitments.0[3],
        );
        for proof in composition_merkle_proofs.iter() {
            proof.verify();
        }

        let mut merkle_proofs = vec![];
        for i in 0..trace_merkle_proofs.len() {
            merkle_proofs.push(MerkleProofPerQuery {
                trace: trace_merkle_proofs[i].clone(),
                interaction: interaction_merkle_proofs[i].clone(),
                constant: constant_merkle_proofs[i].clone(),
                composition: composition_merkle_proofs[i].clone(),
            });
        }
        merkle_proofs
    }
}
