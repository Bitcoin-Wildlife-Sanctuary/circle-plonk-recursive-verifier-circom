use circle_plonk_lib::stwo::PlonkVerifierParams;
use num_traits::Zero;
use serde::Deserialize;
use serde_json::Value;
use std::io::Cursor;
use stwo_prover::constraint_framework::logup::LookupElements;
use stwo_prover::core::air::{Component, Components};
use stwo_prover::core::channel::poseidon31::Poseidon31Channel;
use stwo_prover::core::channel::{Channel, MerkleChannel};
use stwo_prover::core::circle::CirclePoint;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::{SecureField, QM31};
use stwo_prover::core::fields::secure_column::SECURE_EXTENSION_DEGREE;
use stwo_prover::core::fields::FieldExpOps;
use stwo_prover::core::fri::FriConfig;
use stwo_prover::core::pcs::{CommitmentSchemeVerifier, PcsConfig, TreeVec};
use stwo_prover::core::prover::StarkProof;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;
use stwo_prover::core::vcs::poseidon31_merkle::{Poseidon31MerkleChannel, Poseidon31MerkleHasher};
use stwo_prover::examples::plonk::PlonkComponent;

pub struct FiatShamirHint {
    pub trace_commitment: Poseidon31Hash,
    pub alpha: QM31,
    pub z: QM31,
    pub interaction_commitment: Poseidon31Hash,
    pub constant_commitment: Poseidon31Hash,
    pub composition_commitment: Poseidon31Hash,
    pub random_coeff: QM31,
    pub oods_point_x: QM31,
    pub oods_point_y: QM31,
    pub sampled_value_trace_a_val: QM31,
    pub sampled_value_trace_b_val: QM31,
    pub sampled_value_trace_c_val: QM31,
    pub sampled_value_interaction_ab_0: QM31,
    pub sampled_value_interaction_ab_1: QM31,
    pub sampled_value_interaction_ab_2: QM31,
    pub sampled_value_interaction_ab_3: QM31,
    pub sampled_value_interaction_sum_0: QM31,
    pub sampled_value_interaction_sum_1: QM31,
    pub sampled_value_interaction_sum_2: QM31,
    pub sampled_value_interaction_sum_3: QM31,
    pub sampled_value_interaction_shifted_sum_0: QM31,
    pub sampled_value_interaction_shifted_sum_1: QM31,
    pub sampled_value_interaction_shifted_sum_2: QM31,
    pub sampled_value_interaction_shifted_sum_3: QM31,
    pub sampled_value_constant_mult: QM31,
    pub sampled_value_constant_a_wire: QM31,
    pub sampled_value_constant_b_wire: QM31,
    pub sampled_value_constant_c_wire: QM31,
    pub sampled_value_constant_op: QM31,
    pub sampled_value_composition_0: QM31,
    pub sampled_value_composition_1: QM31,
    pub sampled_value_composition_2: QM31,
    pub sampled_value_composition_3: QM31,
    pub line_batch_random_coeff: QM31,
    pub fri_fold_random_coeff: QM31,

    pub last_layer: QM31,
    pub nonce: [u32; 3],
    pub channel_after_pow: [u32; 16],
    pub fri_layer_commitments: Vec<Poseidon31Hash>,
    pub fri_alphas: Vec<QM31>,
}

impl FiatShamirHint {
    pub fn new() -> FiatShamirHint {
        let vk_data = include_bytes!("../../test_data/vk.dat");
        let vk: PlonkVerifierParams<Poseidon31MerkleChannel> =
            bincode::deserialize_from(Cursor::new(vk_data)).unwrap();

        let map_data = include_bytes!("../../test_data/map.dat");

        #[derive(Deserialize, Debug)]
        struct InputMap(Vec<(String, usize, usize)>);
        let map: InputMap = bincode::deserialize_from(Cursor::new(map_data)).unwrap();

        let total_input = map.0.iter().map(|(_, _, n)| n).sum::<usize>();
        let mut input_vec = vec![0u32; total_input];

        let input_data = include_bytes!("../../test_data/input.json");
        let input: Value = serde_json::from_reader(Cursor::new(input_data)).unwrap();

        for (k, start, len) in map.0.iter() {
            assert!(input.get(&k).is_some());
            let entries = input.get(&k).unwrap();
            if *len == 1 {
                if entries.is_array() {
                    input_vec[*start - 1] = (entries[0].as_u64().unwrap() % ((1 << 31) - 1)) as u32;
                } else if entries.is_u64() {
                    input_vec[*start - 1] = (entries.as_u64().unwrap() % ((1 << 31) - 1)) as u32;
                } else {
                    unimplemented!()
                }
            } else {
                assert!(entries.is_array());
                assert_eq!(entries.as_array().unwrap().len(), *len);

                let arr = entries.as_array().unwrap();
                for i in 0..*len {
                    input_vec[*start - 1 + i] = (arr[i].as_u64().unwrap() % ((1 << 31) - 1)) as u32;
                }
            }
        }

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
        let commitment_scheme =
            &mut CommitmentSchemeVerifier::<Poseidon31MerkleChannel>::new(config);
        let proof: StarkProof<Poseidon31MerkleHasher> =
            bincode::deserialize_from(Cursor::new(proof_data)).unwrap();

        commitment_scheme.commit(proof.commitments[0], &sizes[0], channel);
        let lookup_elements = LookupElements::<2>::draw(channel);
        commitment_scheme.commit(proof.commitments[1], &sizes[1], channel);
        commitment_scheme.commit(proof.commitments[2], &sizes[2], channel);
        assert_eq!(vk.constant_tree_hash, proof.commitments[2]);
        let random_coeff = channel.draw_felt();

        let claimed_sum = {
            let mut denominators = vec![M31::from(1) + lookup_elements.alpha - lookup_elements.z];
            for (i, v) in input_vec.iter().enumerate() {
                denominators.push(
                    M31::from(i + 2) + lookup_elements.alpha * M31::from(*v) - lookup_elements.z,
                );
            }

            let mut denominator_inverses = vec![QM31::zero(); denominators.len()];
            QM31::batch_inverse(&denominators, &mut denominator_inverses);
            denominator_inverses.iter().sum::<QM31>()
        };

        let component = PlonkComponent {
            log_n_rows: vk.log_n_rows,
            lookup_elements: lookup_elements.clone(),
            claimed_sum,
        };

        let components = Components([&component as &dyn Component].to_vec());
        commitment_scheme.commit(
            *proof.commitments.last().unwrap(),
            &[components.composition_log_degree_bound(); SECURE_EXTENSION_DEGREE],
            channel,
        );

        let oods_point = CirclePoint::<SecureField>::get_random_point(channel);

        // step 4: draw fri folding coefficient with all oods values
        channel.mix_felts(
            &proof
                .commitment_scheme_proof
                .sampled_values
                .clone()
                .flatten_cols(),
        );
        let line_batch_random_coeff = channel.draw_felt();
        let fri_fold_random_coeff = channel.draw_felt();

        let mut sampled_points = components.mask_points(oods_point);
        sampled_points.push(vec![vec![oods_point]; SECURE_EXTENSION_DEGREE]);

        assert_eq!(
            proof.commitment_scheme_proof.fri_proof.inner_layers.len(),
            13
        );
        let mut fri_layer_commitments = vec![];
        let mut fri_alphas = vec![];
        for proof in proof.commitment_scheme_proof.fri_proof.inner_layers.iter() {
            Poseidon31MerkleChannel::mix_root(channel, proof.commitment);
            fri_alphas.push(channel.draw_felt());
            fri_layer_commitments.push(proof.commitment);
        }

        assert_eq!(
            proof
                .commitment_scheme_proof
                .fri_proof
                .last_layer_poly
                .len(),
            1
        );
        let last_layer = proof.commitment_scheme_proof.fri_proof.last_layer_poly[0];

        channel.mix_felts(&[last_layer]);

        let nonce = proof.commitment_scheme_proof.proof_of_work;
        channel.mix_nonce(nonce);

        let n1 = nonce % ((1 << 22) - 1); // 22 bytes
        let n2 = (nonce >> 22) & ((1 << 21) - 1); // 21 bytes
        let n3 = (nonce >> 43) & ((1 << 21) - 1); // 21 bytes

        let channel_after_pow = channel.sponge.state;

        FiatShamirHint {
            trace_commitment: proof.commitments[0],
            alpha: lookup_elements.alpha,
            z: lookup_elements.z,
            interaction_commitment: proof.commitments[1],
            constant_commitment: proof.commitments[2],
            composition_commitment: proof.commitments[3],
            random_coeff,
            oods_point_x: oods_point.x,
            oods_point_y: oods_point.y,
            sampled_value_trace_a_val: proof.commitment_scheme_proof.sampled_values[0][0][0],
            sampled_value_trace_b_val: proof.commitment_scheme_proof.sampled_values[0][1][0],
            sampled_value_trace_c_val: proof.commitment_scheme_proof.sampled_values[0][2][0],
            sampled_value_interaction_ab_0: proof.commitment_scheme_proof.sampled_values[1][0][0],
            sampled_value_interaction_ab_1: proof.commitment_scheme_proof.sampled_values[1][1][0],
            sampled_value_interaction_ab_2: proof.commitment_scheme_proof.sampled_values[1][2][0],
            sampled_value_interaction_ab_3: proof.commitment_scheme_proof.sampled_values[1][3][0],
            sampled_value_interaction_sum_0: proof.commitment_scheme_proof.sampled_values[1][4][0],
            sampled_value_interaction_sum_1: proof.commitment_scheme_proof.sampled_values[1][5][0],
            sampled_value_interaction_sum_2: proof.commitment_scheme_proof.sampled_values[1][6][0],
            sampled_value_interaction_sum_3: proof.commitment_scheme_proof.sampled_values[1][7][0],
            sampled_value_interaction_shifted_sum_0: proof.commitment_scheme_proof.sampled_values
                [1][4][1],
            sampled_value_interaction_shifted_sum_1: proof.commitment_scheme_proof.sampled_values
                [1][5][1],
            sampled_value_interaction_shifted_sum_2: proof.commitment_scheme_proof.sampled_values
                [1][6][1],
            sampled_value_interaction_shifted_sum_3: proof.commitment_scheme_proof.sampled_values
                [1][7][1],
            sampled_value_constant_mult: proof.commitment_scheme_proof.sampled_values[2][0][0],
            sampled_value_constant_a_wire: proof.commitment_scheme_proof.sampled_values[2][1][0],
            sampled_value_constant_b_wire: proof.commitment_scheme_proof.sampled_values[2][2][0],
            sampled_value_constant_c_wire: proof.commitment_scheme_proof.sampled_values[2][3][0],
            sampled_value_constant_op: proof.commitment_scheme_proof.sampled_values[2][4][0],
            sampled_value_composition_0: proof.commitment_scheme_proof.sampled_values[3][0][0],
            sampled_value_composition_1: proof.commitment_scheme_proof.sampled_values[3][1][0],
            sampled_value_composition_2: proof.commitment_scheme_proof.sampled_values[3][2][0],
            sampled_value_composition_3: proof.commitment_scheme_proof.sampled_values[3][3][0],
            line_batch_random_coeff,
            fri_fold_random_coeff,
            last_layer,
            channel_after_pow,
            fri_layer_commitments,
            fri_alphas,
            nonce: [n1 as u32, n2 as u32, n3 as u32],
        }
    }
}
