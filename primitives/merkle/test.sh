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
circle-plonk preprocess --r1cs test.r1cs --out-vk vk.tmp || exit
circle-plonk prove --r1cs test.r1cs --witness output.wtns --out-proof proof.tmp || exit
circle-plonk verify --proof proof.tmp --map test.map --input input.json --vk vk.tmp || exit
rm proof.tmp
rm vk.tmp
rm test.map
rm -r test_cpp
rm test.r1cs
rm output.wtns
rm input.json