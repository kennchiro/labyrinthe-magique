extends SceneTree

## La barre d'action tactile : AUCUN BOUTON N'EN CHEVAUCHE UN AUTRE.
##
##   godot --headless --path . --script res://tests/test_pad.gd
##
## Ce test existe à cause d'un défaut précis : la fuite et le troisième sort
## étaient posés au MÊME ANGLE, à dix pixels l'un de l'autre pour des rayons de
## 33 et 39 — soixante-deux pixels de recouvrement. On visait un sort, on
## déclenchait l'autre, et rien dans le code ne pouvait le dire : les deux
## placements étaient écrits séparément, chacun raisonnable pris seul.
##
## La géométrie d'une interface tactile se VÉRIFIE, elle ne se relit pas. Un
## chevauchement se voit sur une capture quand on sait où regarder, et pas
## autrement.

## Jeu minimal entre deux boutons, en pixels. Un doigt vise à quelques
## millimètres près : deux boutons qui se frôlent sont deux boutons qu'on
## confond.
const MIN_GAP := 8.0


func _init() -> void:
	var failures: Array[String] = []
	var pad := CombatPad.new()
	# ⚠️ CE SONT DES TAILLES D'INTERFACE, pas des tailles d'écran. La barre est
	# dessinée en unités de mise en page, et `Platform.apply_ui_scale` en change
	# le nombre selon l'appareil : un téléphone en paysage n'en offre qu'environ
	# 690 x 330 là où l'écran fait 960 x 460. Éprouvé sur les pixels bruts, le
	# test passait pendant que les trois boutons du haut sortaient de l'écran.
	for viewport in [Vector2(1280.0, 720.0), Vector2(960.0, 460.0),
			Vector2(690.0, 330.0), Vector2(600.0, 300.0), Vector2(480.0, 270.0)]:
		pad.size = viewport
		var entries: Array[Dictionary] = []
		for i in 6:
			entries.append({"slot": i})
		pad.entries = entries

		for i in 6:
			var here: Vector2 = pad._centre(i)
			var radius: float = pad._radius(i)
			# 1. DANS L'ÉCRAN. Un bouton à moitié dehors est un bouton qu'on ne
			#    peut pas presser, et la moitié visible ment sur sa taille.
			if here.x - radius < 0.0 or here.x + radius > viewport.x \
					or here.y - radius < 0.0 or here.y + radius > viewport.y:
				failures.append("%s : le bouton %d sort de l'écran (centre %s, rayon %.0f)"
					% [viewport, i, here, radius])
			# 2. SANS CHEVAUCHEMENT avec aucun autre.
			for j in range(i + 1, 6):
				var gap: float = here.distance_to(pad._centre(j)) - radius - pad._radius(j)
				if gap < MIN_GAP:
					failures.append("%s : les boutons %d et %d ne laissent que %.1f px "
						% [viewport, i, j, gap] + "(minimum %.0f)" % MIN_GAP)
		if failures.is_empty():
			var narrow := 1e9
			for i in 6:
				for j in range(i + 1, 6):
					narrow = minf(narrow, pad._centre(i).distance_to(pad._centre(j))
						- pad._radius(i) - pad._radius(j))
			print("%s : six boutons, jeu minimal %.1f px : OK" % [viewport, narrow])
	pad.free()

	print("")
	if failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT")
	else:
		print("❌  %d ÉCHEC(S) :" % failures.size())
		for line in failures:
			print("   - ", line)
	quit(0 if failures.is_empty() else 1)
