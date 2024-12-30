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

    pub trace_a_val: M31,
    pub trace_b_val: M31,
    pub trace_c_val: M31,

    pub interaction_ab_0: M31,
    pub interaction_ab_1: M31,
    pub interaction_ab_2: M31,
    pub interaction_ab_3: M31,

    pub interaction_sum_0: M31,
    pub interaction_sum_1: M31,
    pub interaction_sum_2: M31,
    pub interaction_sum_3: M31,

    pub constant_mult: M31,
    pub constant_a_wire: M31,
    pub constant_b_wire: M31,
    pub constant_c_wire: M31,
    pub constant_op: M31,

    pub composition_0: M31,
    pub composition_1: M31,
    pub composition_2: M31,
    pub composition_3: M31,

    pub alpha21_trace: QM31,
    pub alpha13_interaction: QM31,
    pub alpha8_constant: QM31,
    pub alpha4_composition: QM31,
    pub interaction_shifted: QM31,
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

            values.trace_a_val = trace_values[0][idx];
            values.trace_b_val = trace_values[1][idx];
            values.trace_c_val = trace_values[2][idx];

            values.interaction_ab_0 = interaction_values[0][idx];
            values.interaction_ab_1 = interaction_values[1][idx];
            values.interaction_ab_2 = interaction_values[2][idx];
            values.interaction_ab_3 = interaction_values[3][idx];

            values.interaction_sum_0 = interaction_values[4][idx];
            values.interaction_sum_1 = interaction_values[5][idx];
            values.interaction_sum_2 = interaction_values[6][idx];
            values.interaction_sum_3 = interaction_values[7][idx];

            values.constant_mult = constant_values[0][idx];
            values.constant_a_wire = constant_values[1][idx];
            values.constant_b_wire = constant_values[2][idx];
            values.constant_c_wire = constant_values[3][idx];
            values.constant_op = constant_values[4][idx];

            values.composition_0 = composition_values[0][idx];
            values.composition_1 = composition_values[1][idx];
            values.composition_2 = composition_values[2][idx];
            values.composition_3 = composition_values[3][idx];

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

        for queries_parent in queries_parents.iter() {
            let idx_l = queries_parent << 1;
            let idx_r = (queries_parent << 1) + 1u32;

            let l = all_values.get(&idx_l).unwrap();
            let r = all_values.get(&idx_r).unwrap();

            let trace = apply_column_line_coeffs(
                l.y,
                &prepare_hints.trace_column_line_coeffs_a,
                &prepare_hints.trace_column_line_coeffs_b,
                &[l.trace_a_val, l.trace_b_val, l.trace_c_val],
                &[r.trace_a_val, r.trace_b_val, r.trace_c_val],
            );

            let interaction = apply_column_line_coeffs(
                l.y,
                &prepare_hints.interaction_column_line_coeffs_a,
                &prepare_hints.interaction_column_line_coeffs_b,
                &[
                    l.interaction_ab_0,
                    l.interaction_ab_1,
                    l.interaction_ab_2,
                    l.interaction_ab_3,
                    l.interaction_sum_0,
                    l.interaction_sum_1,
                    l.interaction_sum_2,
                    l.interaction_sum_3,
                ],
                &[
                    r.interaction_ab_0,
                    r.interaction_ab_1,
                    r.interaction_ab_2,
                    r.interaction_ab_3,
                    r.interaction_sum_0,
                    r.interaction_sum_1,
                    r.interaction_sum_2,
                    r.interaction_sum_3,
                ],
            );

            let interaction_shifted = apply_column_line_coeffs(
                l.y,
                &prepare_hints.interaction_shifted_column_line_coeffs_a,
                &prepare_hints.interaction_shifted_column_line_coeffs_b,
                &[
                    l.interaction_sum_0,
                    l.interaction_sum_1,
                    l.interaction_sum_2,
                    l.interaction_sum_3,
                ],
                &[
                    r.interaction_sum_0,
                    r.interaction_sum_1,
                    r.interaction_sum_2,
                    r.interaction_sum_3,
                ],
            );

            let constant = apply_column_line_coeffs(
                l.y,
                &prepare_hints.constant_column_line_coeffs_a,
                &prepare_hints.constant_column_line_coeffs_b,
                &[
                    l.constant_mult,
                    l.constant_a_wire,
                    l.constant_b_wire,
                    l.constant_c_wire,
                    l.constant_op,
                ],
                &[
                    r.constant_mult,
                    r.constant_a_wire,
                    r.constant_b_wire,
                    r.constant_c_wire,
                    r.constant_op,
                ],
            );

            let composition = apply_column_line_coeffs(
                l.y,
                &prepare_hints.composition_column_line_coeffs_a,
                &prepare_hints.composition_column_line_coeffs_b,
                &[
                    l.composition_0,
                    l.composition_1,
                    l.composition_2,
                    l.composition_3,
                ],
                &[
                    r.composition_0,
                    r.composition_1,
                    r.composition_2,
                    r.composition_3,
                ],
            );

            all_values.get_mut(&idx_l).unwrap().alpha21_trace = alpha.pow(21) * trace.0;
            all_values.get_mut(&idx_r).unwrap().alpha21_trace = alpha.pow(21) * trace.1;

            all_values.get_mut(&idx_l).unwrap().alpha13_interaction = alpha.pow(13) * interaction.0;
            all_values.get_mut(&idx_r).unwrap().alpha13_interaction = alpha.pow(13) * interaction.1;

            all_values.get_mut(&idx_l).unwrap().alpha8_constant = alpha.pow(8) * constant.0;
            all_values.get_mut(&idx_r).unwrap().alpha8_constant = alpha.pow(8) * constant.1;

            all_values.get_mut(&idx_l).unwrap().alpha4_composition = alpha.pow(4) * composition.0;
            all_values.get_mut(&idx_r).unwrap().alpha4_composition = alpha.pow(4) * composition.1;

            all_values.get_mut(&idx_l).unwrap().interaction_shifted = interaction_shifted.0;
            all_values.get_mut(&idx_r).unwrap().interaction_shifted = interaction_shifted.1;
        }

        QuotientHints { map: all_values }
    }
}
