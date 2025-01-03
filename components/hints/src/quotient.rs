use crate::{FiatShamirHints, PrepareHints};
use itertools::Itertools;
use num_traits::Zero;
use std::collections::HashMap;
use std::io::Cursor;
use stwo_prover::core::circle::M31_CIRCLE_GEN;
use stwo_prover::core::fields::cm31::CM31;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::fields::FieldExpOps;
use stwo_prover::core::prover::StarkProof;
use stwo_prover::core::utils::bit_reverse_index;
use stwo_prover::core::vcs::poseidon31_merkle::Poseidon31MerkleHasher;

#[derive(Clone, Default)]
pub struct PerQuotientEntry {
    pub x: M31,
    pub y: M31,

    pub trace: Vec<M31>,
    pub interaction: Vec<M31>,
    pub constant: Vec<M31>,
    pub composition: Vec<M31>,

    pub trace_sum: QM31,
    pub interaction_sum: QM31,
    pub constant_sum: QM31,
    pub composition_sum: QM31,
    pub interaction_shifted_sum: QM31,

    pub sum: QM31,
}

pub struct QuotientHints {
    pub map: HashMap<u32, PerQuotientEntry>,
}

impl QuotientHints {
    pub fn new(fiat_shamir_hints: &FiatShamirHints, prepare_hints: &PrepareHints) -> QuotientHints {
        let proof_data = include_bytes!("../../test_data/proof.dat");
        let proof: StarkProof<Poseidon31MerkleHasher> =
            bincode::deserialize_from(Cursor::new(proof_data)).unwrap();

        let queries_parents = fiat_shamir_hints
            .queries
            .iter()
            .map(|x| x >> 1)
            .collect_vec();

        let mut queries = vec![];
        for queries_parent in queries_parents.iter() {
            queries.push(queries_parent << 1);
            queries.push((queries_parent << 1) + 1u32);
        }
        queries.sort_unstable();
        queries.dedup();

        let trace_values = &proof.commitment_scheme_proof.queried_values.0[0];
        let interaction_values = &proof.commitment_scheme_proof.queried_values.0[1];
        let constant_values = &proof.commitment_scheme_proof.queried_values.0[2];
        let composition_values = &proof.commitment_scheme_proof.queried_values.0[3];

        let mut all_values = HashMap::new();
        for (idx, query) in queries.iter().enumerate() {
            let mut values = PerQuotientEntry::default();

            let start = M31_CIRCLE_GEN.repeated_double(31 - 20);
            let step = M31_CIRCLE_GEN.repeated_double(31 - 18);

            let point = if *query & 1u32 == 0u32 {
                start + step.mul(bit_reverse_index(*query as usize, 19) as u128)
            } else {
                -start - step.mul(bit_reverse_index(*query as usize, 19) as u128)
            };

            values.x = point.x;
            values.y = point.y;

            values.trace = vec![
                trace_values[0][idx],
                trace_values[1][idx],
                trace_values[2][idx],
            ];
            values.interaction = vec![];
            for i in 0..8 {
                values.interaction.push(interaction_values[i][idx]);
            }

            values.constant = vec![];
            for i in 0..5 {
                values.constant.push(constant_values[i][idx]);
            }

            values.composition = vec![];
            for i in 0..4 {
                values.composition.push(composition_values[i][idx]);
            }

            all_values.insert(*query, values);
        }

        // The computation will look as follows
        //   (alpha^21) * (alpha^2 * g_a_val(X) + alpha * g_b_val(X) + g_c_val(X))
        // + (alpha^13) * (alpha^7 * g_logab1(X) + alpha^6 * g_logab2(X) + alpha^5 * g_logab3(X) + alpha^4 * g_logab4(X)
        //             + alpha^3 * g_logc1(X) + alpha^2 * g_logc2(X) + alpha^1 * g_logc3(X) + g_logc4(X))
        // + (alpha^8) * (alpha^4 * g_mult(X) + alpha^3 * g_a_wire(X) + alpha^2 * g_b_wire(X) + alpha * g_c_wire(X) + g_op(X))
        // + (alpha^4) * (alpha^3 * g_compose1(X) + alpha^2 * g_compose2(X) + alpha * g_compose3(X) + g_compose4(X))
        //
        // divided by v_0(X)
        //
        // plus
        //
        // (alpha^3 * g_logc_shifted_1(X) + alpha^2 * g_logc_shifted_2(X) + alpha^2 * g_logc_shifted_3(X) + g_logc_shifted_4(X))
        //
        // divided by v_1(X)

        let alpha = fiat_shamir_hints.line_batch_random_coeff;

        let apply_column_line_coeffs =
            |y: M31, a: &[CM31], b: &[CM31], eval_l: &[M31], eval_r: &[M31]| {
                assert_eq!(a.len(), b.len());
                assert_eq!(eval_l.len(), eval_r.len());
                assert_eq!(a.len(), eval_l.len());

                let mut v_l = QM31::zero();
                let mut v_r = QM31::zero();

                for (((&a, &b), &l), &r) in
                    a.iter().zip(b.iter()).zip(eval_l.iter()).zip(eval_r.iter())
                {
                    let a_times_z_y = a * y;
                    let res_z = b - a_times_z_y + l;
                    let res_conjugated_z = b + a_times_z_y + r;

                    v_l *= alpha;
                    v_l += QM31::from(res_z);

                    v_r *= alpha;
                    v_r += QM31::from(res_conjugated_z);
                }

                (v_l, v_r)
            };

        let denominator_inverses = |a: CM31, b: CM31, x: M31, y: M31| {
            let res_for_z = b + x - a * y;
            let res_for_conjugated_z = b + x + a * y;

            let inv_res_for_z = res_for_z.inverse();
            let inv_res_for_conjugated_z = res_for_conjugated_z.inverse();

            (inv_res_for_z, inv_res_for_conjugated_z)
        };

        for queries_parent in queries_parents.iter() {
            let idx_l = queries_parent << 1;
            let idx_r = (queries_parent << 1) + 1u32;

            let l = all_values.get(&idx_l).unwrap();
            let r = all_values.get(&idx_r).unwrap();

            let x = l.x;
            let y = l.y;

            let trace = apply_column_line_coeffs(
                y,
                &prepare_hints.trace_column_line_coeffs_a,
                &prepare_hints.trace_column_line_coeffs_b,
                &l.trace,
                &r.trace,
            );

            let interaction = apply_column_line_coeffs(
                y,
                &prepare_hints.interaction_column_line_coeffs_a,
                &prepare_hints.interaction_column_line_coeffs_b,
                &l.interaction,
                &r.interaction,
            );

            let interaction_shifted = apply_column_line_coeffs(
                y,
                &prepare_hints.interaction_shifted_column_line_coeffs_a,
                &prepare_hints.interaction_shifted_column_line_coeffs_b,
                &l.interaction[4..],
                &r.interaction[4..],
            );

            let constant = apply_column_line_coeffs(
                y,
                &prepare_hints.constant_column_line_coeffs_a,
                &prepare_hints.constant_column_line_coeffs_b,
                &l.constant,
                &r.constant,
            );

            let composition = apply_column_line_coeffs(
                y,
                &prepare_hints.composition_column_line_coeffs_a,
                &prepare_hints.composition_column_line_coeffs_b,
                &l.composition,
                &r.composition,
            );

            all_values.get_mut(&idx_l).unwrap().trace_sum = trace.0;
            all_values.get_mut(&idx_r).unwrap().trace_sum = trace.1;

            all_values.get_mut(&idx_l).unwrap().interaction_sum = interaction.0;
            all_values.get_mut(&idx_r).unwrap().interaction_sum = interaction.1;

            all_values.get_mut(&idx_l).unwrap().constant_sum = constant.0;
            all_values.get_mut(&idx_r).unwrap().constant_sum = constant.1;

            all_values.get_mut(&idx_l).unwrap().composition_sum = composition.0;
            all_values.get_mut(&idx_r).unwrap().composition_sum = composition.1;

            all_values.get_mut(&idx_l).unwrap().interaction_shifted_sum = interaction_shifted.0;
            all_values.get_mut(&idx_r).unwrap().interaction_shifted_sum = interaction_shifted.1;

            let oods_part_sum_l = alpha.pow(17) * trace.0
                + alpha.pow(9) * interaction.0
                + alpha.pow(4) * constant.0
                + composition.0;
            let oods_shifted_part_sum_l = interaction_shifted.0;

            let oods_part_sum_r = alpha.pow(17) * trace.1
                + alpha.pow(9) * interaction.1
                + alpha.pow(4) * constant.1
                + composition.1;
            let oods_shifted_part_sum_r = interaction_shifted.1;

            let (oods_l, oods_r) =
                denominator_inverses(prepare_hints.oods_a, prepare_hints.oods_b, x, y);
            let (oods_shifted_l, oods_shifted_r) = denominator_inverses(
                prepare_hints.oods_shifted_a,
                prepare_hints.oods_shifted_b,
                x,
                y,
            );

            let sum_l = alpha.pow(4) * oods_part_sum_l * QM31::from(oods_l)
                + oods_shifted_part_sum_l * QM31::from(oods_shifted_l);
            let sum_r = alpha.pow(4) * oods_part_sum_r * QM31::from(oods_r)
                + oods_shifted_part_sum_r * QM31::from(oods_shifted_r);

            all_values.get_mut(&idx_l).unwrap().sum = sum_l;
            all_values.get_mut(&idx_r).unwrap().sum = sum_r;
        }

        QuotientHints { map: all_values }
    }
}
