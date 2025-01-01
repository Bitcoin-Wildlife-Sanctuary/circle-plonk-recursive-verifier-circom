use poseidon2_m31::Poseidon31CRH;
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha20Rng;
use serde_json::json;
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;

fn random_poseidon31_hash<R: Rng>(prng: &mut R) -> Poseidon31Hash {
    let v: [M31; 8] = prng.gen();
    Poseidon31Hash(v)
}

fn main() {
    let mut prng = ChaCha20Rng::seed_from_u64(0);

    let mut leaf_hashes = vec![];
    for _ in 0..256 {
        leaf_hashes.push(random_poseidon31_hash(&mut prng));
    }

    let mut layers = vec![];
    layers.push(leaf_hashes);

    while layers.last().unwrap().len() > 1 {
        let mut new_layer = vec![];
        for chunk in layers.last().unwrap().chunks(2) {
            let mut v = vec![];
            for elem in chunk[0].0.iter() {
                v.push(elem.0);
            }
            for elem in chunk[1].0.iter() {
                v.push(elem.0);
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
            new_layer.push(Poseidon31Hash(res));
        }
        layers.push(new_layer);
    }

    assert_eq!(layers.last().unwrap().len(), 1);

    let root = layers.last().unwrap()[0];

    let idx = prng.gen_range(0..256) as usize;

    let leaf = layers[0][idx].clone();
    let mut siblings = vec![];
    let mut cur = idx;
    for layer in layers.iter().take(layers.len() - 1) {
        siblings.push(layer[cur ^ 1]);
        cur >>= 1;
    }

    // integration test
    let mut cur_idx = idx;
    let mut cur_elem = leaf;
    for &sibling in siblings.iter() {
        let (left, right) = if cur_idx % 2 == 0 {
            (cur_elem, sibling)
        } else {
            (sibling, cur_elem)
        };

        let mut v = vec![];
        for elem in left.0.iter() {
            v.push(elem.0);
        }
        for elem in right.0.iter() {
            v.push(elem.0);
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
    assert_eq!(cur_elem, root);

    let hash_to_num_vec = |v: Poseidon31Hash| v.as_limbs();
    let hash_vec_to_num_vec = |v: &[Poseidon31Hash]| {
        let mut arr = vec![];
        for vv in v.iter() {
            arr.extend(vv.as_limbs());
        }
        arr
    };

    let text = json!({
        "idx": idx,
        "leaf_hash": hash_to_num_vec(leaf),
        "siblings": hash_vec_to_num_vec(&siblings),
        "root": hash_to_num_vec(root),
    });

    println!("{}", text.to_string());
}
