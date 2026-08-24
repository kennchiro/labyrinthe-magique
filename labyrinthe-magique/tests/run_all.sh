#!/usr/bin/env bash
# Lance toute la suite de tests en headless. Sortie non nulle si un test échoue.
#   ./tests/run_all.sh            tout
#   ./tests/run_all.sh maze       seulement tests/test_maze.gd
set -u
cd "$(dirname "$0")/.."
filter="${1:-}"
status=0
out=$(mktemp)
for test_file in tests/test_*.gd; do
	[[ -n "$filter" && "$test_file" != *"$filter"* ]] && continue
	echo "── ${test_file}"
	# Godot renvoie toujours 0 : c'est le quit(code) du script qui porte le
	# résultat, et il n'est pas propagé. On se fie donc au marqueur d'échec.
	godot --headless --path . --script "res://${test_file}" >"$out" 2>&1
	grep -vE '^Godot Engine|^$' "$out" || true
	grep -q '❌\|⚠️' "$out" && status=1
	echo ""
done
rm -f "$out"
[[ $status -eq 0 ]] && echo "═══ SUITE COMPLÈTE : OK ═══" || echo "═══ SUITE COMPLÈTE : ÉCHEC ═══"
exit $status
