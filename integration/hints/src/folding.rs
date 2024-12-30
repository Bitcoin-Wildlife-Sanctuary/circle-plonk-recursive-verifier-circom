use std::collections::HashMap;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::QM31;

pub struct PerQueryFoldingHints {
    pub left: Vec<QM31>,
    pub right: Vec<QM31>,
    pub twiddles: Vec<M31>,
}

pub struct FoldingHints {
    pub map: HashMap<usize, PerQueryFoldingHints>,
}
