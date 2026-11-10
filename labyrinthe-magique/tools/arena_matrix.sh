#!/bin/bash
# La matrice de l'arène en parallèle : qui bat qui en 1 contre 1, du plus fort au plus faible.
# Chaque personnage joue chacun des autres, des deux côtés. Environ 2 minutes sur 6 cœurs.
cd "$(dirname "$0")/.." || exit 1
N=${1:-6}
tmp=$(mktemp -d)
for ((k=0; k<N; k++)); do
	godot --headless --path . --script res://tests/test_arena.gd -- --matrice --part "$k/$N" > "$tmp/$k.log" 2>&1 &
done
wait
grep -h "^LIGNE" "$tmp"/*.log | sed 's/^LIGNE //' | sort -k2 -n -r
grep -h "SCRIPT ERROR" "$tmp"/*.log | sort | uniq -c
rm -rf "$tmp"
