use ark_std::UniformRand;
use rand::SeedableRng;
use rand_chacha::ChaCha20Rng;
use serde_json::json;
use stwo_prover::core::fields::qm31::QM31;
use stwo_prover::core::fields::FieldExpOps;

fn main() {
    let mut prng = ChaCha20Rng::seed_from_u64(0);

    let a = QM31::rand(&mut prng);
    let b = QM31::rand(&mut prng);

    let a_plus_b = a + b;
    let a_minus_b = a - b;
    let a_times_b = a * b;
    let a_inv = a.inverse();
    let a_square = a.square();

    let to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];

    let text = json!({
        "a": to_num_vec(a),
        "b": to_num_vec(b),
        "a_plus_b": to_num_vec(a_plus_b),
        "a_minus_b": to_num_vec(a_minus_b),
        "a_times_b": to_num_vec(a_times_b),
        "a_inv": to_num_vec(a_inv),
        "a_square": to_num_vec(a_square),
    });

    println!("{}", text.to_string());
}
