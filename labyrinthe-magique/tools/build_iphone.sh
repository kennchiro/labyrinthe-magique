#!/bin/bash
#
# Pose le jeu sur l'iPhone, SANS CÂBLE.
#
#     tools/build_iphone.sh            # DEPUIS LA RACINE du projet
#     tools/build_iphone.sh --release  # sans le débogueur, pour montrer le jeu
#
# Trois étapes, et la première fait le gros du travail : Godot ne se contente
# pas d'écrire le projet Xcode, il l'archive et le signe. On lui donne l'équipe
# et l'identifiant depuis `export_presets.cfg` — rien n'est à retaper ici.
#
#     1. godot --export-*    ->  build/ios/LabyrintheMagique.ipa
#     2. devicectl install   ->  le téléphone, par le Wi-Fi
#     3. devicectl launch    ->  et il démarre
#
# POURQUOI SANS CÂBLE, ET CE QUE ÇA SUPPOSE
#
# L'iPhone a été appairé une fois, par USB, dans Xcode (Fenêtre > Devices and
# Simulators, case « Connect via network »). Depuis, `devicectl` le retrouve
# tout seul sur le réseau local — c'est ce que dit `transportType: localNetwork`
# dans `xcrun devicectl list devices -v`.
#
# Il faut donc, à chaque fois :
#   · le Mac et le téléphone sur le MÊME réseau Wi-Fi ;
#   · le téléphone DÉVERROUILLÉ — un iPhone verrouillé refuse le tunnel ;
#   · et la patience du transfert : la .ipa fait plus de 140 Mo, ce qui prend
#     à peu près une minute là où le câble en mettrait dix secondes.
#
# ⚠️ LA PREMIÈRE FOIS APRÈS UN CHANGEMENT DE CERTIFICAT, iOS refuse de lancer
# l'app tant que le profil n'est pas approuvé à la main sur le téléphone :
# Réglages > Général > VPN et gestion de l'appareil > faire confiance.
set -e

DEVICE="${LABY_IPHONE:-41D22099-3FDF-5FCA-8983-CC94BED2459F}"
BUNDLE="com.elie.labyrinthemagique"
IPA="build/ios/LabyrintheMagique.ipa"

# DÉBOGUAGE PAR DÉFAUT. C'est le mode dans lequel on va regarder le jeu tourner
# sur le téléphone : il garde les messages d'erreur, que la version release
# avale. `--release` est là pour le jour où on le montre à quelqu'un.
MODE="--export-debug"
if [ "$1" = "--release" ]; then
	MODE="--export-release"
fi

if [ ! -f project.godot ]; then
	echo "À lancer DEPUIS LA RACINE du projet (là où est project.godot)." >&2
	exit 1
fi

echo "── Export iOS ($MODE) — Godot archive et signe, ça prend une minute"
godot --headless --path . "$MODE" "iOS" "$IPA"

# On vérifie que le téléphone répond AVANT de tenter le transfert : sans ça,
# `install` part quand même et échoue une minute plus tard sur un message qui
# ne dit pas que le Wi-Fi ou l'écran verrouillé sont en cause.
# ⚠️ ON VÉRIFIE QU'IL EST JOIGNABLE, pas seulement qu'il est CONNU.
#
# La première version cherchait l'identifiant dans la liste — or `devicectl`
# liste aussi les téléphones appairés mais hors de portée, avec la mention
# « unavailable ». Le contrôle passait donc sur un téléphone éteint, et l'échec
# arrivait une minute plus tard, au milieu du transfert, sur un message qui ne
# disait pas que l'écran était verrouillé.
echo "── Le téléphone répond-il ?"
# ⚠️ « unavailable » CONTIENT « available ». On écarte donc la ligne fautive
# avant de chercher le bon mot — un piège que ce script a payé une fois.
if ! xcrun devicectl list devices | grep "$DEVICE" | grep -v "unavailable" \
		| grep -q "available"; then
	echo "Téléphone injoignable. Même Wi-Fi ? Écran DÉVERROUILLÉ ?" >&2
	xcrun devicectl list devices | grep "$DEVICE" >&2
	exit 1
fi

echo "── Transfert ($(du -h "$IPA" | cut -f1)) par le réseau"
xcrun devicectl device install app --device "$DEVICE" "$IPA"

echo "── Démarrage"
xcrun devicectl device process launch --device "$DEVICE" "$BUNDLE"
