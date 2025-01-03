#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom folding.circom --r1cs --input_map --c || exit
cd folding_cpp || exit
cmake . || exit
make || exit
./folding ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs folding.r1cs || exit
circle-plonk preprocess --r1cs folding.r1cs --out-vk vk.tmp || exit
circle-plonk prove --r1cs folding.r1cs --witness output.wtns --out-proof proof.tmp || exit
circle-plonk verify --proof proof.tmp --map folding.map --input input.json --vk vk.tmp || exit
rm proof.tmp
rm vk.tmp
rm folding.map
rm -r folding_cpp
rm folding.r1cs
rm output.wtns
rm input.json