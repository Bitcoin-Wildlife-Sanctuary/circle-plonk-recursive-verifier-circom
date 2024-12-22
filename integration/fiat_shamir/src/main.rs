use circle_plonk_lib::stwo::PlonkVerifierParams;
use serde_json::json;
use std::io::Cursor;
use stwo_prover::constraint_framework::logup::LookupElements;
use stwo_prover::core::channel::poseidon31::Poseidon31Channel;
use stwo_prover::core::channel::Channel;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::fri::FriConfig;
use stwo_prover::core::pcs::{CommitmentSchemeVerifier, PcsConfig, TreeVec};
use stwo_prover::core::prover::StarkProof;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;
use stwo_prover::core::vcs::poseidon31_merkle::{Poseidon31MerkleChannel, Poseidon31MerkleHasher};

fn main() {
    let vk_data = include_bytes!("../../test_data/vk.dat");
    let vk: PlonkVerifierParams<Poseidon31MerkleChannel> =
        bincode::deserialize_from(Cursor::new(vk_data)).unwrap();

    let proof_data = include_bytes!("../../test_data/proof.dat");
    let max_degree = vk.log_n_rows + 1;
    let sizes = TreeVec::new(vec![
        vec![max_degree; 3],
        vec![max_degree; 8],
        vec![max_degree; 5],
    ]);
    let channel = &mut Poseidon31Channel::default();
    let config = PcsConfig {
        pow_bits: 10,
        fri_config: FriConfig::new(0, 4, 64),
    };
    let commitment_scheme = &mut CommitmentSchemeVerifier::<Poseidon31MerkleChannel>::new(config);
    let proof: StarkProof<Poseidon31MerkleHasher> =
        bincode::deserialize_from(Cursor::new(proof_data)).unwrap();

    commitment_scheme.commit(proof.commitments[0], &sizes[0], channel);
    let lookup_elements = LookupElements::<2>::draw(channel);
    commitment_scheme.commit(proof.commitments[1], &sizes[1], channel);
    commitment_scheme.commit(proof.commitments[2], &sizes[2], channel);
    assert_eq!(vk.constant_tree_hash, proof.commitments[2]);
    let random_coeff = channel.draw_felt();

    let hash_to_num_vec = |a: &Poseidon31Hash| a.as_limbs();
    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];

    let text = json!({
        "trace_commitment": hash_to_num_vec(&proof.commitments[0]),
        "alpha": qm31_to_num_vec(lookup_elements.alpha),
        "z": qm31_to_num_vec(lookup_elements.z),
        "interaction_commitment": hash_to_num_vec(&proof.commitments[1]),
        "constant_commitment": hash_to_num_vec(&proof.commitments[2]),
        "random_coeff": qm31_to_num_vec(random_coeff),
    });

    println!("{}", text.to_string());
}
