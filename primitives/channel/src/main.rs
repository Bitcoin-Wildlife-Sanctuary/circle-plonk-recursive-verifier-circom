use ark_std::UniformRand;
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha20Rng;
use serde_json::json;
use stwo_prover::core::channel::poseidon31::Poseidon31Channel;
use stwo_prover::core::channel::{Channel, MerkleChannel};
use stwo_prover::core::fields::m31::M31;
use stwo_prover::core::fields::qm31::{SecureField, QM31};
use stwo_prover::core::vcs::poseidon31_hash::Poseidon31Hash;
use stwo_prover::core::vcs::poseidon31_merkle::Poseidon31MerkleChannel;

fn main() {
    let mut prng = ChaCha20Rng::seed_from_u64(0);
    let root = {
        let test_root: [M31; 8] = prng.gen();
        Poseidon31Hash(test_root)
    };

    let mut channel = Poseidon31Channel::default();
    let iv = channel.sponge.state[8..16].to_vec();
    Poseidon31MerkleChannel::mix_root(&mut channel, root);
    let channel_mix_root = channel.sponge.state[8..16].to_vec();

    let channel_draw_felt1 = channel.draw_felt();
    let channel_draw_felt2 = channel.draw_felts(3);

    let a: SecureField = SecureField::rand(&mut prng);
    let b: SecureField = SecureField::rand(&mut prng);
    let c: SecureField = SecureField::rand(&mut prng);

    channel.mix_felts(&[a]);
    channel.sponge.squeeze(1);
    let channel_absorb_1 = channel.sponge.state[8..16].to_vec();

    channel.mix_felts(&[b, c]);
    let channel_absorb_2 = channel.sponge.state[8..16].to_vec();

    let hash_to_num_vec = |a: &Poseidon31Hash| a.as_limbs();
    let qm31_to_num_vec = |a: QM31| [a.0 .0 .0, a.0 .1 .0, a.1 .0 .0, a.1 .1 .0];

    let text = json!({
        "iv": iv,
        "root": hash_to_num_vec(&root),
        "channel_mix_root": channel_mix_root,
        "channel_draw_felt1": qm31_to_num_vec(channel_draw_felt1),
        "channel_draw_felt2_a": qm31_to_num_vec(channel_draw_felt2[0]),
        "channel_draw_felt2_b": qm31_to_num_vec(channel_draw_felt2[1]),
        "channel_draw_felt2_c": qm31_to_num_vec(channel_draw_felt2[2]),
        "a": qm31_to_num_vec(a),
        "b": qm31_to_num_vec(b),
        "c": qm31_to_num_vec(c),
        "channel_absorb_1": channel_absorb_1,
        "channel_absorb_2": channel_absorb_2,
    });

    println!("{}", text.to_string());
}
