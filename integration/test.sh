#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom integration.circom --r1cs --input_map --c || exit
cd integration_cpp || exit
cmake . || exit
make -j4 || exit
./integration ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs integration.r1cs || exit
circle-plonk dry-run --r1cs integration.r1cs --witness output.wtns || exit
rm integration.map
rm -r integration_cpp
rm integration.r1cs
rm output.wtns
rm input.json