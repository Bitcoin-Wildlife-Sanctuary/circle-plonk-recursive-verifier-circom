#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom test.circom --r1cs --input_map --c || exit
cd test_cpp || exit
cmake . || exit
make || exit
./test ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs test.r1cs || exit
circle-plonk dry-run --r1cs test.r1cs --witness output.wtns || exit
rm test.map
rm -r test_cpp
rm test.r1cs
rm output.wtns
rm input.json