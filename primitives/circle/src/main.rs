use ark_std::{One, UniformRand};
use log::trace;
use rand::SeedableRng;
use rand_chacha::ChaCha20Rng;
use serde_json::json;
use std::ops::{Add, Mul, Neg};
use stwo_prover::core::circle::CirclePoint;
use stwo_prover::core::fields::qm31::{SecureField, QM31};
use stwo_prover::core::fields::{Field, FieldExpOps};
use stwo_prover::core::poly::circle::CanonicCoset;

fn main() {
    let mut prng = ChaCha20Rng::seed_from_u64(0);

    let a = QM31::rand(&mut prng);
    let b = QM31::rand(&mut prng);

    let a_plus_b = a + b;
    let a_minus_b = a - b;
    let a_times_b = a * b;
    let a_inv = a.inverse();
    let a_square = a.square();

    let t = QM31::rand(&mut prng);
    let (x, y) = {
        let t_square = t.square();

        let one_plus_tsquared_inv = t_square.add(SecureField::one()).inverse();

        let x = SecureField::one()
            .add(t_square.neg())
            .mul(one_plus_tsquared_inv);
        let y = t.double().mul(one_plus_tsquared_inv);
        (x, y)
    };

    let trace_step = CanonicCoset::new(15).step();
    let shift_minus_1 = trace_step.mul_signed(-1);

    let point = CirclePoint { x, y };
    let shifted_point = point.add(shift_minus_1.into_ef());

    let to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];

    let text = json!({
        "a": to_num_vec(a),
        "b": to_num_vec(b),
        "a_plus_b": to_num_vec(a_plus_b),
        "a_minus_b": to_num_vec(a_minus_b),
        "a_times_b": to_num_vec(a_times_b),
        "a_inv": to_num_vec(a_inv),
        "a_square": to_num_vec(a_square),
        "t": to_num_vec(t),
        "x": to_num_vec(x),
        "y": to_num_vec(y),
        "shifted_x": to_num_vec(shifted_point.x),
        "shifted_y": to_num_vec(shifted_point.y),
    });

    println!("{}", text.to_string());
}
