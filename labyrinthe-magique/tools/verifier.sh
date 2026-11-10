#!/bin/bash
# TOUT VÉRIFIER EN UNE COMMANDE, ET ÉCHOUER FORT.
#
#   tools/verifier.sh            # suites rapides + contrôles de planches
#   tools/verifier.sh --balance  # ajoute la passe rapide d'équilibrage
#
# ⚠️ POURQUOI CE SCRIPT EXISTE. Vérifier ce projet demandait sept commandes et
# la lecture de sept sorties. Résultat, sur une seule journée : quatre contrôles
# qui annonçaient un succès sans rien vérifier — un découpage rendu en carrés
# gris uniformes salué comme parfait, un contrôleur qui annonçait « 0 planches
# bien découpées » et concluait au succès, une barre tactile mesurée en pixels
# d'écran pendant que trois boutons sortaient de l'écran, et un test qui
# plantait sans faire échouer sa suite.
#
# ⚠️ LE PIÈGE PRINCIPAL : une erreur GDScript à l'exécution interrompt la
# fonction fautive et REND LA MAIN à l'appelant. La suite continue et conclut
# « TOUS LES TESTS PASSENT » sur un test qui n'a rien vérifié. On filtre donc la
# sortie autant qu'on lit le verdict.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

RED=$'\033[31m'; GREEN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'
fauts=0

verdict() {   # nom, sortie, motif de succès
	local nom="$1" sortie="$2" motif="$3"
	if grep -q "SCRIPT ERROR" <<<"$sortie"; then
		printf '%s✗ %-22s un test a PLANTÉ (voir SCRIPT ERROR)%s\n' "$RED" "$nom" "$OFF"
		grep "SCRIPT ERROR" <<<"$sortie" | head -2 | sed 's/^/      /'
		fauts=$((fauts + 1))
	elif grep -q "$motif" <<<"$sortie"; then
		printf '%s✓%s %-22s %s%s%s\n' "$GREEN" "$OFF" "$nom" "$DIM" \
			"$(grep -m1 "$motif" <<<"$sortie" | cut -c1-58)" "$OFF"
	else
		printf '%s✗ %-22s ÉCHEC%s\n' "$RED" "$nom" "$OFF"
		tail -6 <<<"$sortie" | sed 's/^/      /'
		fauts=$((fauts + 1))
	fi
}

echo "── Suites"
for suite in test_hero_progress test_transformation test_hero_game test_hero_cards test_hero_demo test_hero_skills test_combat test_portals test_grid_mover test_victory test_pad test_touch_layout test_hud test_select test_quest test_animation test_world test_creatures test_boss test_motion test_arena; do
	[ -f "tests/$suite.gd" ] || continue
	verdict "$suite" "$(godot --headless --path . --script "res://tests/$suite.gd" 2>&1)" \
		"TOUS LES TESTS PASSENT"
done
verdict "test_maze" "$(godot --headless --path . --script res://tests/test_maze.gd 2>&1)" \
	"TOUS LES TESTS PASSENT"

echo ""
echo "── Planches"
verdict "check_characters" "$(tools/.venv/bin/python tools/check_characters.py 2>&1)" \
	"BIEN DÉCOUPÉES"

if [ "${1:-}" = "--balance" ]; then
	echo ""
	echo "── Équilibrage (passe rapide)"
	verdict "test_balance" \
		"$(godot --headless --path . --script res://tests/test_balance.gd -- --quick 2>&1)" \
		"N'A DÉRIVÉ"
fi

echo ""
if [ "$fauts" -eq 0 ]; then
	printf '%sTOUT EST VERT%s\n' "$GREEN" "$OFF"
else
	printf '%s%d CONTRÔLE(S) EN ÉCHEC%s\n' "$RED" "$fauts" "$OFF"
fi
exit "$fauts"
