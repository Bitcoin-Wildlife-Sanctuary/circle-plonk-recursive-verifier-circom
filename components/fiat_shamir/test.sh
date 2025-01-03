#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom fiat_shamir.circom --r1cs --input_map --c || exit
cd fiat_shamir_cpp || exit
cmake . || exit
make || exit
./fiat_shamir ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs fiat_shamir.r1cs || exit
circle-plonk preprocess --r1cs fiat_shamir.r1cs --out-vk vk.tmp || exit
circle-plonk prove --r1cs fiat_shamir.r1cs --witness output.wtns --out-proof proof.tmp || exit
circle-plonk verify --proof proof.tmp --map fiat_shamir.map --input input.json --vk vk.tmp || exit
rm proof.tmp
rm vk.tmp
rm fiat_shamir.map
rm -r fiat_shamir_cpp
rm fiat_shamir.r1cs
rm output.wtns
rm input.json