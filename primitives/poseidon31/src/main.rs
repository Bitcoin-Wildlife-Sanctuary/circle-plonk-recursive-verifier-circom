use poseidon2_m31::poseidon2_permute;
use serde_json::json;

fn main() {
    let test_input = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    let mut test_output = test_input.clone();
    poseidon2_permute(&mut test_output);
    poseidon2_permute(&mut test_output);

    let text = json!({
        "in": test_input,
        "out": test_output,
    });

    println!("{}", text.to_string());
}
