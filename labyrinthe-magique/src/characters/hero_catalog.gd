class_name HeroCatalog
extends RefCounted

const NAMES := ["Apprenti", "Éveillé", "Ascendant", "Prisme", "Dragon d’or"]

static func at_level(hero_level: int, prism := false, dragon := false) -> CharacterStats:
	var rank := clampi(hero_level, 1, HeroProgress.MAX_LEVEL)
	var form := 3 if prism and rank >= 30 else (2 if rank >= 20 else (1 if rank >= 10 else 0))
	if dragon and rank >= Transformation.DRAGON_LEVEL:
		form = 4
	var c := CharacterCatalog.ael()
	c.hero_level = rank
	c.description += " Niveau %d." % rank
	c.hero_form = form
	c.display_name = "Aël · " + NAMES[form]
	c.base_health = 3 if form == 0 else 4
	c.move_speed = [5.0, 5.2, 5.4, 6.0, 6.4][form]
	c.ultimate_required_kills = 6 if form >= 2 else 5
	c.base_plates = 1 if form >= 2 else 0
	if form == 1:
		c.attack = spell("lame", "Lame d’éclat", Ability.Kind.BLAST, 26, 0.45, {"radius": 2.2, "range": 2, "arc": 150.0, "follow_wave": 3})
		c.abilities = [
			spell("gerbe", "Gerbe de gemmes", Ability.Kind.BLADES, 22, 5.0, {"blade_count": 3, "range": 6}),
			# LE SORT 2 LE DÉPLACE, dans toutes ses formes (demande du joueur, 2026-11-06) : une charge qui frappe ce
			# qu'elle traverse. Elle remplace la protection de la forme ; le sort 3 reste celui d'origine.
			spell("percee", "Percée de cristal", Ability.Kind.BLINK, 0, 6.0, {"range": 5, "trail_damage": 30, "blow_cells": 1}),
			spell("eclair", "Frappe éclair", Ability.Kind.LINE, 28, 6.0, {"range": 7, "duration": 1.5}),
		]
		c.escape = spell("pas", "Pas de lumière", Ability.Kind.BLINK, 0, 5.0, {"range": 5})
		c.ultimate = spell("rayon", "Rayon de gemme", Ability.Kind.BEAM, 70, 1.0, {"range": 12})
	elif form == 2:
		c.attack = spell("double", "Double coup", Ability.Kind.BLAST, 26, 0.8, {"radius": 2.2, "range": 2, "arc": 150.0, "charges": 2})
		c.abilities = [
			spell("pluie", "Pluie d’éclats", Ability.Kind.STARFALL, 22, 7.0, {"star_falls": 6, "radius": 5.0}),
			spell("fente", "Fente prismatique", Ability.Kind.BLINK, 0, 6.0, {"range": 6, "trail_damage": 34, "blow_cells": 2}),
			spell("onde", "Onde prismatique", Ability.Kind.CHAIN, 28, 6.0, {"range": 7, "chain_jumps": 4}),
		]
		c.escape = spell("ailes", "Ailes de lumière", Ability.Kind.BLINK, 0, 6.0, {"range": 5, "pierces_walls": true})
		# La Transformation a son propre bouton (2026-11-04) : l'Extra de l'Ascendant reste sa Nova.
		c.ultimate = spell("nova", "Nova prismatique", Ability.Kind.BLAST, 70, 1.0, {"radius": 3.5})
	elif form == 4:
		# LE DRAGON D'OR (niveau 80) : un dragon humanoïde qui rôde. Des gestes de bête — griffes, souffle,
		# écailles, chute, ailes, rugissement — chacun avec son effet (section « Aël » de `level.gd`).
		c.attack = spell("griffes", "Griffes de soleil", Ability.Kind.BLAST, 30, 0.35, {"radius": 2.2, "arc": 160.0})
		c.abilities = [
			spell("souffle", "Souffle du Dragon", Ability.Kind.BLAST, 36, 5.0, {"radius": 5.0, "arc": 70.0, "residue_duration": 3.0}),
			spell("chute", "Chute du Dragon", Ability.Kind.COMET, 45, 6.0, {"range": 6, "radius": 2.5}),
			spell("ecailles", "Écailles de soleil", Ability.Kind.SHIELD, 0, 10.0, {"immune": true, "duration": 2.0, "reflect_damage": 30}),
		]
		c.escape = spell("envol", "Ailes d’or", Ability.Kind.BLINK, 0, 5.0, {"range": 7, "pierces_walls": true})
		c.ultimate = spell("rugissement", "Rugissement du Roi-Dragon", Ability.Kind.BLAST, 140, 1.0, {"radius": 9.0, "pierces_walls": true})
	elif form == 3:
		c.attack = spell("rafale", "Rafale de lumière", Ability.Kind.PROJECTILE, 20, 0.22, {"range": 9})
		c.abilities = [
			spell("comete", "Comète", Ability.Kind.COMET, 35, 5.0, {"range": 8, "radius": 2.0}),
			spell("lames", "Lames filantes", Ability.Kind.BLINK, 0, 5.0, {"range": 7, "trail_damage": 40, "blow_cells": 2, "pierces_walls": true}),
			spell("orbite", "Éclats en orbite", Ability.Kind.STORM, 18, 9.0, {"range": 5, "radius": 4.0, "duration": 6.0}),
		]
		c.escape = spell("transmission", "Transmission", Ability.Kind.TRANSMISSION, 0, 5.0, {"range": 10})
		# UNE DÉFLAGRATION, PLUS UN RAYON (2026-11-04) : le rayon droit ne touchait que l'axe de son regard, et
		# rien du tout près d'un bord. Elle part dans tous les sens et traverse les haies (`pierces_walls`).
		c.ultimate = spell("ultime", "Prisme ultime", Ability.Kind.BLAST, 100, 1.0, {"radius": 7.0, "pierces_walls": true})
	var bonus := [1.0, 1.25, 1.5, 2.0, 2.6][form] as float
	var floor_level := [1, 10, 20, 30, 80][form] as int
	bonus *= 1.0 + float(rank - floor_level) * 0.02
	for a in c.action_bar():
		# Les boucliers comptent des PV du joueur, pas des dégâts d’ennemi.
		if a.kind != Ability.Kind.SHIELD:
			a.damage = roundi(float(a.damage) * bonus)
		if a.reflect_damage > 0:
			a.reflect_damage = roundi(float(a.reflect_damage) * bonus)
		if a.trail_damage > 0:
			a.trail_damage = roundi(float(a.trail_damage) * bonus)
	c.ultimate.is_ultimate = true
	return c

static func spell(key: String, title: String, kind: Ability.Kind, damage: int, cooldown: float, extra: Dictionary = {}) -> Ability:
	var data := {"id": "ael_" + key, "display_name": title, "description": title,
		"kind": kind, "damage": damage, "cooldown": cooldown, "element": Element.Kind.PRISM}
	data.merge(extra, true)
	return Ability.make(data)
