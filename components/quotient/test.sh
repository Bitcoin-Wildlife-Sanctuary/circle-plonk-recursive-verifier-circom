#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom quotient.circom --r1cs --input_map --c || exit
cd quotient_cpp || exit
cmake . || exit
make || exit
./quotient ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs quotient.r1cs || exit
circle-plonk preprocess --r1cs quotient.r1cs --out-vk vk.tmp || exit
circle-plonk prove --r1cs quotient.r1cs --witness output.wtns --out-proof proof.tmp || exit
circle-plonk verify --proof proof.tmp --map quotient.map --input input.json --vk vk.tmp || exit
rm proof.tmp
rm vk.tmp
rm quotient.map
rm -r quotient_cpp
rm quotient.r1cs
rm output.wtns
rm input.json