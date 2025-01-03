use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha20Rng;
use serde_json::json;

fn main() {
    let mut prng = ChaCha20Rng::seed_from_u64(0);

    let a22 = prng.gen_range(0..((1 << 22) - 1));
    let a23 = prng.gen_range(0..((1 << 23) - 1));
    let a15 = prng.gen_range(0..((1 << 15) - 1));

    let in_a = prng.gen_range(0..((1u32 << 31) - 1));
    let out_low = in_a & ((1 << 18) - 1);

    let text = json!({
        "a22": a22,
        "a23": a23,
        "a15": a15,
        "in_a": in_a,
        "out_low": out_low,
    });

    println!("{}", text.to_string());
}
