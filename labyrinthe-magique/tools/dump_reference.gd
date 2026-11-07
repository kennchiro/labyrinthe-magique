extends SceneTree

## Écrit les fiches de référence des personnages et du bestiaire :
##   godot --headless --path . --script res://tools/dump_reference.gd
##
## GÉNÉRÉ, jamais écrit à la main — et c'est tout l'intérêt. Une fiche
## recopiée à la main ment dès le premier réglage d'équilibrage, et une fiche
## qui ment est pire que pas de fiche : on corrige le jeu pour qu'il colle au
## document au lieu de l'inverse. Ici la source est le code lui-même
## (CharacterCatalog, Bestiary, LevelConfig, CombatSystem), donc l'écart est
## impossible.
##
## Sortie : docs/PERSONNAGES.md et docs/BESTIAIRE.md

const OUT_CHARACTERS := "res://docs/PERSONNAGES.md"
const OUT_BESTIARY := "res://docs/BESTIAIRE.md"

## Noms des créneaux de la barre d'action, dans l'ordre de `action_bar()`.
const SLOTS := ["ATTAQUE", "SKILL 1", "SKILL 2", "SKILL 3", "FUITE", "EXTRA"]

## Ce que l'élément d'un mage ajoute à CHACUN de ses coups. Les chiffres sont
## lus dans CombatSystem : le texte, lui, est ici — c'est la seule chose de ce
## fichier qui soit une interprétation et non une donnée.
const TRAIT_TEXT := {
	Element.Kind.FIRE: "**Brûlure** — %d %% de dégâts en plus, étalés sur %.1f s",
	Element.Kind.WATER: "**Trempe** — la cible ralentit de %d %% pendant %.1f s",
	Element.Kind.EARTH: "**Ébranlement** — la cible s'arrête net %.1f s (une fois toutes les %.0f s)",
	Element.Kind.SHADOW: "**Ponction** — le mage récupère %d PV, au plus toutes les %.0f s",
	Element.Kind.THUNDER: "**Arc** — le coup saute à un voisin à %d cases (%d %% des dégâts)",
	Element.Kind.AIR: "**Bourrasque** — la cible est repoussée de %d cases",
	Element.Kind.SUPREME: "**Écho** — %d %% des dégâts se répètent %.1f s plus tard",
	Element.Kind.STARS: "**Astre** — au %de coup sur une cible, ses étoiles explosent pour %d dégâts",
	Element.Kind.STEEL: "**Plaques** — %d plaques encaissent chacune un coup à la place des PV ; %d kills en reforgent une",
	Element.Kind.BLOOD: "**Rage** — jusqu'à +%d %% de dégâts selon les PV perdus, au maximum à 1 PV",
	Element.Kind.CHARM: "**Trouble** — au %de murmure, la cible ralentit de %d %% pendant %.1f s, et sa possession dure %.1f s de plus",
	Element.Kind.HUNGER: "**Faim insatiable** — chaque kill est une bouchée, %d au plus : +%d %% de dégâts et +%d %% de taille chacune ; une fond toutes les %.0f s sans manger",
	Element.Kind.LUCK: "**Coup de chance** — %d %% des coups sont critiques et frappent %d fois plus fort",
	Element.Kind.INFERNO: "**Terre brûlée** — chaque crachat enflamme la case de sa cible %.0f s, à %d dégâts/s ; dans le feu, il va %d %% plus vite",
	Element.Kind.COLDFIRE: "**Entraves** — au %de poing sur le même ennemi, il est cloué au sol %.1f s",
	Element.Kind.BLADE: "**Entailles** — jusqu'à %d par ennemi, %.0f s depuis la dernière ; elles éclatent quand il rengaine",
	Element.Kind.EMBER: "**Armure vivante** — %d pièces encaissent chacune un coup et blessent pour %d dégâts ; chacune lancée ajoute %.1f de vitesse, et rentre seule après %.0f s",
	Element.Kind.DEATH: "**Sentence** — un ennemi sous %d %% de ses PV après un coup est achevé",
	Element.Kind.TIME: "**Retard** — la cible ralentit de %d %% pendant %.1f s",
	Element.Kind.POISON: "**Venin** — jusqu'à %d doses, %d dégâts par seconde chacune pendant %.0f s",
	Element.Kind.LIGHT: "**Éblouissement** — la cible perd sa trace %.1f s, au plus toutes les %.0f s",
	Element.Kind.SKY: "**Vue d'en haut** — ses coups visés tombent du ciel : leur portée se mesure à vol d'oiseau, par-dessus les haies",
	Element.Kind.SACRED: "**Nul n'approche** — chaque coup ouvre un œil ; l'ennemi marqué qui arrive au contact brûle pour %d dégâts, puis %.0f s passent avant un nouvel œil",
}


func _init() -> void:
	_write(OUT_CHARACTERS, _characters())
	_write(OUT_BESTIARY, _bestiary())
	quit()


func _write(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Écriture impossible : " + path)
		return
	file.store_string(text)
	print("écrit : %s (%d lignes)" % [path, text.split("\n").size()])


# --- Personnages ------------------------------------------------------------------

func _characters() -> String:
	var characters := CharacterCatalog.roster()
	var out := PackedStringArray()
	out.append("# Les mages — fiches de référence\n")
	out.append("> ⚙️ **Fichier GÉNÉRÉ.** Ne pas éditer à la main : "
		+ "`godot --headless --path . --script res://tools/dump_reference.gd`.")
	out.append("> Les sources sont `src/characters/character_catalog.gd` et `hero_catalog.gd` ; "
		+ "corriger un chiffre se fait là-bas, puis on régénère.\n")
	out.append("%d profils jouables, formes comprises. La barre d'action a toujours la même forme —"
		% characters.size())
	out.append("attaque, trois sorts, fuite, extra — et c'est ce qui rend les fiches")
	out.append("comparables d'un personnage à l'autre.\n")

	out.append("## Vue d'ensemble\n")
	out.append("| Mage | Élément | Vie | Vitesse | Extra à | Trait élémentaire |")
	out.append("|---|---|---:|---:|---:|---|")
	for character in characters:
		out.append("| **%s** | %s | %d | %.1f | %d kills | %s |" % [
			character.display_name, Element.label(character.element),
			character.base_health, character.move_speed,
			character.ultimate_required_kills, _trait_line(character.element)])
	out.append("")
	out.append("La **vie** est celle de base : le stage y ajoute son bonus "
		+ "(`LevelConfig.player_health_bonus`, de 0 au stage 1 à +7 au stage 10).")
	out.append("La **vitesse** est en cases par seconde ; celle des poursuivants "
		+ "ne s'en déduit pas — voir la fiche du bestiaire.\n")

	for character in characters:
		out.append(_character_sheet(character))
	return "\n".join(out)


func _trait_line(element: Element.Kind) -> String:
	# Les chiffres viennent de CombatSystem : la fiche ne peut pas diverger.
	match element:
		Element.Kind.FIRE:
			return TRAIT_TEXT[element] % [int(CombatSystem.BURN_RATIO * 100.0),
				CombatSystem.BURN_TICKS * CombatSystem.BURN_TICK]
		Element.Kind.WATER:
			return TRAIT_TEXT[element] % [int(round((1.0 - CombatSystem.SOAK_FACTOR) * 100.0)),
				CombatSystem.SOAK_DURATION]
		Element.Kind.EARTH:
			return TRAIT_TEXT[element] % [CombatSystem.STAGGER_DURATION,
				CombatSystem.STAGGER_LOCK]
		Element.Kind.SHADOW:
			return TRAIT_TEXT[element] % [CombatSystem.LEECH_HEAL, CombatSystem.LEECH_LOCK]
		Element.Kind.THUNDER:
			return TRAIT_TEXT[element] % [CombatSystem.CHAIN_RANGE,
				int(CombatSystem.CHAIN_RATIO * 100.0)]
		Element.Kind.AIR:
			return TRAIT_TEXT[element] % CombatSystem.PUSH_CELLS
		Element.Kind.SUPREME:
			return TRAIT_TEXT[element] % [int(CombatSystem.ECHO_RATIO * 100.0),
				CombatSystem.ECHO_DELAY]
		Element.Kind.LIGHT:
			return TRAIT_TEXT[element] % [CombatSystem.GLARE_SECONDS, CombatSystem.BLIND_LOCK]
		Element.Kind.STARS:
			return TRAIT_TEXT[element] % [CombatSystem.ASTRE_MARKS, CombatSystem.ASTRE_DAMAGE]
		Element.Kind.STEEL:
			return TRAIT_TEXT[element] % [CombatSystem.PLATE_MAX, CombatSystem.PLATE_KILLS]
		Element.Kind.BLOOD:
			return TRAIT_TEXT[element] % int(CombatSystem.RAGE_MAX * 100.0)
		Element.Kind.CHARM:
			return TRAIT_TEXT[element] % [CombatSystem.WHISPER_MARKS,
				int((1.0 - CombatSystem.TROUBLE_FACTOR) * 100.0), CombatSystem.TROUBLE_SECONDS,
				CombatSystem.TROUBLE_BONUS]
		Element.Kind.COLDFIRE:
			return TRAIT_TEXT[element] % [CombatSystem.SHACKLE_HITS, CombatSystem.SHACKLE_SECONDS]
		Element.Kind.HUNGER:
			return TRAIT_TEXT[element] % [CombatSystem.BITES_MAX, int(CombatSystem.BITE_DAMAGE * 100.0),
				int(CombatSystem.BITE_SIZE * 100.0), CombatSystem.BITE_DECAY]
		Element.Kind.LUCK:
			return TRAIT_TEXT[element] % [int(CombatSystem.LUCK_CHANCE * 100.0), CombatSystem.LUCK_MULT]
		Element.Kind.INFERNO:
			return TRAIT_TEXT[element] % [CombatSystem.FIRE_CELL_SECONDS, CombatSystem.FIRE_CELL_DAMAGE,
				int(CombatSystem.INFERNO_SPEED * 100.0)]
		Element.Kind.BLADE:
			return TRAIT_TEXT[element] % [CombatSystem.CUTS_MAX, CombatSystem.CUT_SECONDS]
		Element.Kind.EMBER:
			return TRAIT_TEXT[element] % [CombatSystem.PIECES_MAX, CombatSystem.EJECT_DAMAGE,
				CombatSystem.PIECE_SPEED_BONUS, CombatSystem.PIECE_AUTO_RETURN]
		Element.Kind.DEATH:
			return TRAIT_TEXT[element] % int(CombatSystem.SENTENCE_BELOW * 100.0)
		Element.Kind.POISON:
			return TRAIT_TEXT[element] % [CombatSystem.VENOM_MAX, CombatSystem.VENOM_DAMAGE,
				CombatSystem.VENOM_DURATION]
		Element.Kind.TIME:
			return TRAIT_TEXT[element] % [int((1.0 - CombatSystem.RETARD_FACTOR) * 100.0),
				CombatSystem.RETARD_DURATION]
		Element.Kind.SKY:
			return TRAIT_TEXT[element]
		Element.Kind.SACRED:
			return TRAIT_TEXT[element] % [CombatSystem.EYE_DAMAGE, CombatSystem.EYE_LOCK]
	return "—"


func _character_sheet(character: CharacterStats) -> String:
	var out := PackedStringArray()
	out.append("\n---\n")
	out.append("## %s — %s\n" % [character.display_name, Element.label(character.element)])
	out.append("> %s\n" % character.description)
	out.append("`id: %s` · puissance affichée %d/5 · vie %d · vitesse %.1f · extra à %d kills"
		% [character.id, character.power_level, character.base_health,
			character.move_speed, character.ultimate_required_kills])
	out.append("")
	out.append("Trait : %s\n" % _trait_line(character.element))
	out.append("| Créneau | Sort | Forme | Effet | Recharge |")
	out.append("|---|---|---|---|---:|")
	var bar := character.action_bar()
	for index in bar.size():
		var ability: Ability = bar[index]
		var slot: String = SLOTS[index] if index < SLOTS.size() else "?"
		var form := _kind_label(ability.kind)
		# Une invocation sans le nom de la bête n'apprend rien : c'est ELLE que
		# le joueur regarde courir, pas la forme du sort.
		if ability.kind == Ability.Kind.SUMMON and ability.summon_id != "":
			form += " (%s)" % ability.summon_id
		out.append("| %s | **%s** | %s | %s | %.1f s |" % [
			slot, ability.display_name, form, ability.summary(), ability.cooldown])
	out.append("")
	for index in bar.size():
		var ability: Ability = bar[index]
		out.append("- **%s** — %s" % [ability.display_name, ability.description])
	return "\n".join(out)


func _kind_label(kind: Ability.Kind) -> String:
	match kind:
		Ability.Kind.PROJECTILE: return "projectile"
		Ability.Kind.BLAST: return "explosion"
		Ability.Kind.ZONE: return "zone"
		Ability.Kind.SHIELD: return "bouclier"
		Ability.Kind.HEAL: return "soin"
		Ability.Kind.WALL: return "mur"
		Ability.Kind.BLINK: return "translation"
		Ability.Kind.SUMMON: return "invocation"
		Ability.Kind.STORM: return "phénomène"
		Ability.Kind.HUNTERS: return "chasseurs"
		Ability.Kind.CHEST: return "piège"
		Ability.Kind.RECALL: return "rappel"
		Ability.Kind.CAGES: return "cages"
		Ability.Kind.DASH: return "ruée"
		Ability.Kind.HOOK: return "crochet"
		Ability.Kind.SOUL_CHAINS: return "chaînes"
		Ability.Kind.GAOL: return "geôle"
		Ability.Kind.BLADES: return "volée"
		Ability.Kind.FLIGHT: return "envol"
		Ability.Kind.WHIRL: return "ronde"
		Ability.Kind.WHEELS: return "roues"
		Ability.Kind.GARDEN: return "jardin"
		Ability.Kind.BREATH: return "souffle"
		Ability.Kind.BITE: return "morsure"
		Ability.Kind.MAGMA_SCALES: return "carapace"
		Ability.Kind.WINGBEAT: return "ailes"
		Ability.Kind.DRAGON_SHADOW: return "ombre"
		Ability.Kind.DICE: return "dés"
		Ability.Kind.TRAP_CARD: return "piège"
		Ability.Kind.COIN: return "pari"
		Ability.Kind.ROULETTE: return "roulette"
		Ability.Kind.GULF: return "gouffre"
		Ability.Kind.DEVOUR: return "dévoration"
		Ability.Kind.REGURGITATE: return "salve"
		Ability.Kind.LEAP: return "bond"
		Ability.Kind.FEAST: return "festin"
		Ability.Kind.GUARD: return "parade"
		Ability.Kind.SHEATHE: return "éclat"
		Ability.Kind.CHAIN: return "chaîne"
		Ability.Kind.WAVE: return "vague"
		Ability.Kind.LINE: return "ligne"
		Ability.Kind.TURRET: return "tourelle"
		Ability.Kind.ECHO: return "écho"
		Ability.Kind.HOURGLASS: return "sablier"
		Ability.Kind.TIME_STOP: return "arrêt du temps"
		Ability.Kind.TRAIL: return "traînée"
		Ability.Kind.CONTAGION: return "contagion"
		Ability.Kind.TRANSFUSION: return "transfusion"
		Ability.Kind.PANDEMIC: return "pandémie"
		Ability.Kind.BEAM: return "rayon"
		Ability.Kind.DAWN: return "aube"
		Ability.Kind.SOULS: return "âmes"
		Ability.Kind.CONSTELLATION: return "constellation"
		Ability.Kind.STARFALL: return "pluie"
		Ability.Kind.LAST_HOUR: return "heure dernière"
		Ability.Kind.ANVIL: return "enclume"
		Ability.Kind.PACT: return "pacte"
		Ability.Kind.POSSESS: return "possession"
		Ability.Kind.BOND: return "lien"
		Ability.Kind.SWAP: return "échange"
		Ability.Kind.HERO_TRANSFORM: return "transformation"
		Ability.Kind.COMET: return "comète"
		Ability.Kind.TRANSMISSION: return "transmission"
	# ⚠️ Un « ? » dans une fiche GÉNÉRÉE est un trou que personne ne remarque :
	# la ligne reste lisible, le tableau reste droit, et le type du sort a
	# simplement disparu. Trois familles manquaient ici depuis leur création.
	push_warning("Type de sort sans nom dans la fiche : %d" % kind)
	return "?"


# --- Bestiaire --------------------------------------------------------------------

func _bestiary() -> String:
	var out := PackedStringArray()
	out.append("# Le bestiaire — fiches de référence\n")
	out.append("> ⚙️ **Fichier GÉNÉRÉ.** Ne pas éditer à la main : "
		+ "`godot --headless --path . --script res://tools/dump_reference.gd`.")
	out.append("> La source est `src/entities/bestiary.gd` et `src/core/level_config.gd`.\n")
	out.append("Les valeurs sont des **rapports**, pas des absolus. Le Spectre est")
	out.append("l'unité — c'est sur lui que tout l'équilibrage a été mesuré — et les")
	out.append("points de vie de chaque espèce s'en déduisent :")
	out.append("`PV = LevelConfig.hunter_health × robustesse`.\n")

	out.append("## Vue d'ensemble\n")
	out.append("| Créature | Apparaît | Robustesse | Vélocité | Coup | Repos | Ce qu'elle est |")
	out.append("|---|---:|---:|---:|---:|---:|---|")
	var ids := _all_species()
	for id in ids:
		var species: Dictionary = Bestiary.of(id)
		out.append("| **%s** | stage %d | ×%.2f | ×%.2f | %.2f s | %.2f s | %s |" % [
			species["name"], _first_stage(id), species["toughness"], species["swiftness"],
			species["strike"], species["repos"], species["trait"]])
	out.append("")
	out.append("**Robustesse** multiplie les PV, **vélocité** la vitesse du stage.")
	out.append("**Coup** est la durée de la pose de frappe, **repos** le temps mort")
	out.append("qui la suit — sans lui, un ennemi collé au mage relance son geste à")
	out.append("la frame près et l'animation devient un battement continu.\n")

	out.append("## Points de vie, stage par stage\n")
	out.append("Ce que chaque espèce encaisse réellement, une fois le rapport appliqué")
	out.append("à la référence du stage.\n")
	var header := "| Créature |"
	var rule := "|---|"
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		header += " St.%d |" % stage
		rule += "---:|"
	out.append(header)
	out.append(rule)
	for id in ids:
		var line := "| **%s** |" % Bestiary.display_name(id)
		for stage in range(1, LevelConfig.STAGE_COUNT + 1):
			var config := LevelConfig.for_stage(stage)
			line += (" %d |" % config.enemy_health(id)) if id in config.species else " — |"
		out.append(line)
	out.append("")

	out.append("## Qui rencontre-t-on, et où\n")
	out.append("Le roster est **cumulatif** : le stage 7 contient encore le spectre du")
	out.append("stage 1. C'est ce qui fait sentir la progression — non pas « d'autres")
	out.append("ennemis » mais « les mêmes, plus quelque chose de neuf ».\n")
	out.append("| Stage | Nom | Nouveauté | Effectif | Vitesse | Détection |")
	out.append("|---:|---|---|---:|---:|---:|")
	for stage in range(1, LevelConfig.STAGE_COUNT + 1):
		var config := LevelConfig.for_stage(stage)
		var newcomers := PackedStringArray()
		for id in Bestiary.NEWCOMERS[stage - 1]:
			newcomers.append(Bestiary.display_name(str(id)))
		out.append("| %d | %s | %s | %d | ×%.2f | %d cases |" % [
			stage, config.level_name, ", ".join(newcomers), config.enemy_count,
			config.enemy_speed_ratio, config.enemy_detection_radius])
	out.append("")
	out.append("## Les créatures de l'Invocateur\n")
	out.append("Elles ne sont pas du bestiaire : ce sont des **alliées**, invoquées par")
	out.append("l'Invocateur, et elles chassent les créatures ci-dessus. Leurs règles")
	out.append("vivent dans `CombatSystem.SUMMON_KINDS`.\n")
	# Le sort qui les appelle porte leur nom, leur nombre et leur durée : on les
	# relit dans le catalogue plutôt que de les réécrire ici, sinon la fiche
	# finirait par annoncer une durée que le jeu n'applique plus.
	var callers := {}
	for ability in CharacterCatalog.invocateur().action_bar():
		if ability.kind == Ability.Kind.SUMMON:
			callers[ability.summon_id] = ability
	out.append("| Créature | Appelée par | Nombre | Durée | Vitesse | Dégâts | Cadence | Portée | Déplacement |")
	out.append("|---|---|---:|---:|---:|---:|---:|---:|---|")
	for kind_id in CombatSystem.SUMMON_KINDS:
		var kind: Dictionary = CombatSystem.SUMMON_KINDS[kind_id]
		var caller: Ability = callers.get(kind_id)
		out.append("| **%s** | %s | %d | %.0f s | %.1f c/s | %d | %.1f s | %.1f case | %s |" % [
			kind_id,
			caller.display_name if caller != null else "—",
			caller.summon_count if caller != null else 0,
			caller.duration if caller != null else 0.0,
			kind["speed"], kind["damage"], kind["period"], kind["reach"],
			"vole par-dessus les murs" if kind["flies"] else "suit les couloirs"])
	out.append("")
	out.append("Il n'y en a jamais plus de **%d** à la fois (au-delà, la plus ancienne"
		% CombatSystem.MAX_SUMMONS)
	out.append("cède la place). Leurs kills nourrissent l'extra du mage, mais leurs")
	out.append("coups ne déclenchent **pas** de trait élémentaire : le trait est la")
	out.append("signature du mage, pas celle de ses bêtes.")
	return "\n".join(out)


func _all_species() -> Array:
	var out: Array = []
	for group in Bestiary.NEWCOMERS:
		for id in group:
			out.append(str(id))
	return out


func _first_stage(id: String) -> int:
	for index in Bestiary.NEWCOMERS.size():
		if id in Bestiary.NEWCOMERS[index]:
			return index + 1
	return 1
