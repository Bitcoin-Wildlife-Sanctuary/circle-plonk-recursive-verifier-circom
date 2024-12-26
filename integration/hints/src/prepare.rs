use crate::FiatShamirHints;
use num_traits::Zero;
use serde::Deserialize;
use serde_json::Value;
use std::io::Cursor;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::fields::FieldExpOps;

pub struct PrepareHints {
    pub claimed_sum: QM31,
    pub constraint_num: QM31,
}

impl PrepareHints {
    pub fn new(fiat_shamir_hints: &FiatShamirHints) -> PrepareHints {
        let h = fiat_shamir_hints;

        let a_val = h.sampled_value_trace_a_val;
        let b_val = h.sampled_value_trace_b_val;
        let c_val = h.sampled_value_trace_c_val;
        let op = h.sampled_value_constant_op;

        let a_val_times_b_val = a_val * b_val;
        let mut res1 = op * (a_val + b_val - a_val_times_b_val) + a_val_times_b_val - c_val;

        let composition_fold_random_coeff = h.random_coeff;
        let composition_fold_random_coeff_squared =
            composition_fold_random_coeff * composition_fold_random_coeff;

        res1 *= composition_fold_random_coeff_squared;

        let a_wire = h.sampled_value_constant_a_wire;
        let b_wire = h.sampled_value_constant_b_wire;
        let alpha = h.alpha;
        let z = h.z;

        let denominator_1 = a_wire + alpha * a_val - z;
        let denominator_2 = b_wire + alpha * b_val - z;

        let num_aggregated = denominator_1 + denominator_2;
        let denom_aggregated = denominator_1 * denominator_2;

        let a_b_logup_0 = h.sampled_value_interaction_ab_0;
        let a_b_logup_1 = h.sampled_value_interaction_ab_1;
        let a_b_logup_2 = h.sampled_value_interaction_ab_2;
        let a_b_logup_3 = h.sampled_value_interaction_ab_3;

        let a_b_logup = a_b_logup_0
            + a_b_logup_1 * QM31::from_u32_unchecked(0, 1, 0, 0)
            + a_b_logup_2 * QM31::from_u32_unchecked(0, 0, 1, 0)
            + a_b_logup_3 * QM31::from_u32_unchecked(0, 0, 0, 1);

        let mut res2 = a_b_logup * denom_aggregated - num_aggregated;
        res2 *= composition_fold_random_coeff;

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

        let claimed_sum = {
            let mut denominators =
                vec![M31::from(1) + fiat_shamir_hints.alpha - fiat_shamir_hints.z];
            for (i, v) in input_vec.iter().enumerate() {
                denominators.push(
                    M31::from(i + 2) + fiat_shamir_hints.alpha * M31::from(*v)
                        - fiat_shamir_hints.z,
                );
            }

            let mut denominator_inverses = vec![QM31::zero(); denominators.len()];
            QM31::batch_inverse(&denominators, &mut denominator_inverses);
            denominator_inverses.iter().sum::<QM31>()
        };

        let c_wire = fiat_shamir_hints.sampled_value_constant_c_wire;

        let denominator_3 = c_wire + alpha * c_val - z;

        let c_logup_0 = fiat_shamir_hints.sampled_value_interaction_sum_0;
        let c_logup_1 = fiat_shamir_hints.sampled_value_interaction_sum_1;
        let c_logup_2 = fiat_shamir_hints.sampled_value_interaction_sum_2;
        let c_logup_3 = fiat_shamir_hints.sampled_value_interaction_sum_3;

        let c_logup_next_0 = fiat_shamir_hints.sampled_value_interaction_shifted_sum_0;
        let c_logup_next_1 = fiat_shamir_hints.sampled_value_interaction_shifted_sum_1;
        let c_logup_next_2 = fiat_shamir_hints.sampled_value_interaction_shifted_sum_2;
        let c_logup_next_3 = fiat_shamir_hints.sampled_value_interaction_shifted_sum_3;

        let c_logup = c_logup_0
            + c_logup_1 * QM31::from_u32_unchecked(0, 1, 0, 0)
            + c_logup_2 * QM31::from_u32_unchecked(0, 0, 1, 0)
            + c_logup_3 * QM31::from_u32_unchecked(0, 0, 0, 1);

        let c_logup_next = c_logup_next_0
            + c_logup_next_1 * QM31::from_u32_unchecked(0, 1, 0, 0)
            + c_logup_next_2 * QM31::from_u32_unchecked(0, 0, 1, 0)
            + c_logup_next_3 * QM31::from_u32_unchecked(0, 0, 0, 1);

        let claimed_sum_divided = claimed_sum * M31::from(1 << 13).inverse();

        let mult = fiat_shamir_hints.sampled_value_constant_mult;

        let mut res3 = c_logup - c_logup_next - a_b_logup + claimed_sum_divided;
        res3 *= denominator_3;
        res3 += mult;

        let constraint_num = res1 + res2 + res3;

        PrepareHints {
            constraint_num,
            claimed_sum,
        }
    }
}
