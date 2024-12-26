#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom prepare.circom --r1cs --input_map --c || exit
cd prepare_cpp || exit
cmake . || exit
make || exit
./prepare ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs prepare.r1cs || exit
circle-plonk preprocess --r1cs prepare.r1cs --out-vk vk.tmp || exit
circle-plonk prove --r1cs prepare.r1cs --witness output.wtns --out-proof proof.tmp || exit
circle-plonk verify --proof proof.tmp --map prepare.map --input input.json --vk vk.tmp || exit
rm proof.tmp
rm vk.tmp
rm prepare.map
rm -r prepare_cpp
rm prepare.r1cs
rm output.wtns
rm input.json