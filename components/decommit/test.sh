#!/bin/sh
cd "$(dirname "$0")" || exit
cargo run > input.json || exit
circom decommit.circom --r1cs --input_map --c || exit
cd decommit_cpp || exit
cmake . || exit
make || exit
./decommit ../input.json ../output.wtns || exit
cd .. || exit
circle-plonk info --r1cs decommit.r1cs || exit
circle-plonk preprocess --r1cs decommit.r1cs --out-vk vk.tmp || exit
circle-plonk prove --r1cs decommit.r1cs --witness output.wtns --out-proof proof.tmp || exit
circle-plonk verify --proof proof.tmp --map decommit.map --input input.json --vk vk.tmp || exit
rm proof.tmp
rm vk.tmp
rm decommit.map
rm -r decommit_cpp
rm decommit.r1cs
rm output.wtns
rm input.json