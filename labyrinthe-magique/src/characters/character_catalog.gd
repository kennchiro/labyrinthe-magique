class_name CharacterCatalog
extends RefCounted

## SEUIL D'ULTIME = CONSTITUTION + 1.
##
## Les huit personnages exigeaient presque tous cinq kills : le compteur ne
## disait donc rien du personnage qu'on jouait. La règle retenue lie le seuil à
## la fragilité — un mage qui encaisse peu atteint son ultime plus tôt, parce
## qu'il ne peut pas se permettre un long combat ; un mage robuste le paie plus
## cher, parce qu'il a les moyens d'attendre.
##
##   Feu, Ténèbres, Foudre (3 PV)  ->  4 kills
##   Eau, Air (4 PV)               ->  5 kills
##   Terre (5 PV)                  ->  6 kills
##
## DEUX EXCEPTIONS, chacune pour sa raison :
##   Sorcier Suprême   8 kills — son ultime est le plus puissant du jeu ;
##   Invocateur        6 kills — il ne se bat pas lui-même, ses kills viennent
##                     de ses invocations et arrivent donc plus régulièrement.

## Les sept mages jouables.
##
## Ils ne diffèrent PAS par la couleur : chacun a ses points de vie, sa vitesse,
## sa portée, ses temps de recharge et surtout ses formes de sorts (projectile,
## explosion, zone persistante, bouclier, mur, saut). Un joueur qui change de
## personnage change de façon de traverser le labyrinthe, pas de palette.
##
## Repère d'équilibrage : le Sorcier des Ténèbres est l'étalon, les quatre autres se
## comparent à lui. Sa portée a été ramenée de 14 à 10 cases après mesure —
## à 14, on abattait des poursuivants qu'on n'avait jamais vus, deux virages
## plus loin, et le labyrinthe se vidait tout seul.

const SHADOW := "shadow"
const FIRE := "fire"
const WATER := "water"
const EARTH := "earth"
const THUNDER := "thunder"
const AIR := "air"
const SUPREME := "supreme"
const INVOCATEUR := "invocateur"
const CHRONO := "chrono"
const PESTE := "peste"
const LUMIERE := "lumiere"
const MORT := "mort"
const ETOILES := "etoiles"
const ACIER := "acier"
const DEMON := "demon"
const DISCORDE := "discorde"
const BRAISE := "braise"
const ECARLATE := "ecarlate"
const GEOLIER := "geolier"
const CIEL := "ciel"
const CHERUBIN := "cherubin"
const DRAGON := "dragon"
const CROUPIER := "croupier"
const AVIDE := "avide"
## Le gabarit d'animation : il est absent de `all()`, donc de l'équilibrage, des fiches et
## des tests qui parcourent les vrais personnages. `--demo --character test` y mène.
const TEST := "test"
## Aël, le héros principal (`docs/HEROS_PRINCIPAL.md`), en Apprenti. Premier onglet de la sélection et
## personnage par défaut, mais hors de `all()`, donc de l'équilibrage et des fiches, tant que ses niveaux ne
## sont pas écrits.
const AEL := "ael"
## Ses quatre formes, une carte chacune dans l'onglet Héros. Elles ne servent qu'au menu : en jeu, c'est
## toujours `AEL`, et sa forme vient de son niveau (`HeroCatalog`, `HeroProgress`).
const AEL_FORMS := ["ael", "ael_eveille", "ael_ascendant", "ael_prisme", "ael_dragon"]
## Le niveau qui ouvre chaque forme. Le Prisme ne se choisit pas : il se prend en combat, au niveau 30.
const AEL_FORM_LEVELS := [1, 10, 20, 30, 80]
## Ceux qui ne partent jamais en vraie partie et n'ont pas d'onglet.
const HIDDEN := [TEST]

const CATEGORY_HEROS := "heros"
const CATEGORY_MAGE := "mage"
const CATEGORY_ANGE := "ange"
const CATEGORY_DEMON := "demon"
const CATEGORY_TEST := "essai"
## Les onglets de l'écran de sélection, dans l'ordre. Une famille de plus ne demande
## qu'une ligne ici et le champ `category` de ses personnages.
const CATEGORIES := {
	CATEGORY_HEROS: {"tab": "Héros", "accent": Color("#8fe3ff")},
	CATEGORY_MAGE: {"tab": "Mage", "accent": Color("#9fc4ff")},
	CATEGORY_ANGE: {"tab": "Ange", "accent": Color("#ffd479")},
	CATEGORY_DEMON: {"tab": "Démon", "accent": Color("#ff6b82")},
}


static func all() -> Array[CharacterStats]:
	return [fire(), water(), earth(), shadow(), thunder(), air(), invocateur(), supreme(), chrono(),
		peste(), lumiere(), mort(), etoiles(), acier(), ciel(), cherubin(), demon(), discorde(), braise(), ecarlate(), geolier(), dragon(), croupier(), avide()]


## Ce que montre l'écran de sélection : Aël d'abord, le héros principal, puis les autres. Le Héros
## d'essai en est caché pour l'instant : pour le remontrer, l'ajouter ici et rendre son onglet à `CATEGORIES`.
static func roster() -> Array[CharacterStats]:
	var out: Array[CharacterStats] = []
	for form in AEL_FORMS.size():
		out.append(ael_form(form))
	out.append_array(all())
	return out


## Une forme d'Aël telle que le menu la montre : au niveau qui l'ouvre, sous son propre identifiant.
static func ael_form(form: int) -> CharacterStats:
	var rank := clampi(form, 0, AEL_FORMS.size() - 1)
	var c := HeroCatalog.at_level(AEL_FORM_LEVELS[rank], rank >= 3, rank == 4)
	c.id = AEL_FORMS[rank]
	c.category = CATEGORY_HEROS
	return c


static func in_category(category: String) -> Array[CharacterStats]:
	var out: Array[CharacterStats] = []
	for character in roster():
		if character.category == category:
			out.append(character)
	return out


static func by_id(id: String) -> CharacterStats:
	if id == TEST:
		return test_hero()
	if id == AEL:
		return ael()
	if id in AEL_FORMS:
		return ael_form(AEL_FORMS.find(id))
	for character in all():
		if character.id == id:
			return character
	return ael()


## Le héros principal : c'est avec lui que s'ouvrent le titre et la sélection.
## L'ÉVEIL (2026-11-07) : la forme transformée d'un mage, ou null s'il n'en a pas encore.
## Elle garde l'identifiant du mage : ses effets de base, ses sons et ses tables restent les siens.
static func awakening_of(id: String) -> CharacterStats:
	match id:
		FIRE:
			return fire_awakened()
		WATER:
			return water_awakened()
	return null


static func default_id() -> String:
	return AEL


# --- Le Phénix : l'Éveil du Mage du Feu. -----------------------------------------

## Une minute de Phénix (`Awakening`). Plus rapide, et chaque sort change. Son trait, Renaissance,
## vit dans `AwakeningRuntime`. Fiche : `docs/prompts/mages/eveil_feu.md`. Chiffres non mesurés.
static func fire_awakened() -> CharacterStats:
	var base := fire()
	var c := CharacterStats.new()
	c.id = FIRE
	c.awakened = true
	c.display_name = "Phénix"
	c.element = Element.Kind.FIRE
	c.category = base.category
	c.description = "Le Mage du Feu éveillé. Il renaît une fois de ses cendres."
	c.power_level = base.power_level
	c.base_health = base.base_health
	c.move_speed = base.move_speed * 1.15
	c.ultimate_required_kills = base.ultimate_required_kills
	c.attack = Ability.make({
		"id": "fire_eveil_plumes", "display_name": "Plumes du phénix",
		"description": "Trois plumes de feu en éventail, chacune sur sa cible.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
		"damage": 16, "range": 8, "cooldown": 0.5, "volley": 3,
		"projectile_scale": 0.9, "projectile_speed": 1.2, "projectile_visual": "plume_phenix",
	})
	c.abilities = [
		Ability.make({
			"id": "fire_eveil_soleil", "display_name": "Soleil captif",
			"description": "Une boule plus grosse qui explose deux fois, et laisse du magma.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": 48, "radius": 3.0, "range": 7, "cooldown": 5.0,
			"echo_delay": 0.6, "echo_damage": 30, "magma_duration": 4.0, "magma_damage": 8,
			"projectile_scale": 2.4, "projectile_speed": 0.55, "projectile_visual": "soleil_captif",
			"shockwave": true,
		}),
		Ability.make({
			"id": "fire_eveil_colonnes", "display_name": "Colonnes de feu",
			"description": "Six piliers de feu jaillissent en cercle autour de lui.",
			"kind": Ability.Kind.PILLARS, "element": Element.Kind.FIRE,
			"damage": 30, "radius": 1.1, "pillar_count": 6, "pillar_ring": 2.5, "cooldown": 3.0,
		}),
		Ability.make({
			"id": "fire_eveil_couronne", "display_name": "Couronne de brasiers",
			"description": "Trois brasiers tournent autour de lui et brûlent ce qu'ils touchent.",
			"kind": Ability.Kind.WHIRL, "element": Element.Kind.FIRE,
			"damage": 6, "radius": 1.6, "duration": 10.0, "whirl_interval": 0.5, "cooldown": 7.0,
		}),
	]
	c.escape = Ability.make({
		"id": "fire_eveil_plongee", "display_name": "Plongée du phénix",
		"description": "Il plonge droit devant, et une explosion part de chaque bout.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.FIRE,
		"range": 8, "cooldown": 7.0, "end_blast_damage": 35, "end_blast_radius": 1.8,
	})
	var nova := base.ultimate
	c.ultimate = Ability.make({
		"id": "fire_eveil_supernova", "display_name": "Supernova",
		"description": "Le phénix monte au ciel et retombe : l'onde traverse les murs, puis deux fois plus de météores.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.FIRE,
		"damage": 160, "radius": 8.0, "cooldown": 1.0, "is_ultimate": true,
		"shockwave": true, "pierces_walls": true, "flames": 1.6,
		"rain_count": nova.rain_count * 2, "rain_damage": nova.rain_damage, "rain_radius": nova.rain_radius,
		"rain_duration": nova.rain_duration * 1.3, "rain_fall": nova.rain_fall,
	})
	return c


# --- L'Esprit des Marées : l'Éveil du Mage de l'Eau. -----------------------------

## Une minute de Seigneur des Marées (`Awakening`). Son trait, Marée haute, est une coque d'eau qui se
## reforme 6 s après avoir cédé. Fiche : `docs/prompts/mages/eveil_eau.md`. Chiffres non mesurés.
## Le joueur a préféré ce kit à celui de l'Esprit des Marées (Source vive) le 2026-11-07 : les images
## de l'Esprit sont gardées, elles vont à ce concept.
static func water_awakened() -> CharacterStats:
	var base := water()
	var c := CharacterStats.new()
	c.id = WATER
	c.awakened = true
	c.display_name = "Seigneur des Marées"
	c.element = Element.Kind.WATER
	c.category = base.category
	c.description = "Le Mage de l'Eau éveillé. Sa coque d'eau se reforme toute seule après chaque coup."
	c.power_level = base.power_level
	c.base_health = base.base_health
	c.move_speed = base.move_speed * 1.15
	c.ultimate_required_kills = base.ultimate_required_kills
	c.attack = Ability.make({
		"id": "water_eveil_trident", "display_name": "Trident",
		"description": "Le jet touche sa cible, puis rebondit sur deux ennemis voisins.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.WATER,
		"damage": 16, "range": 9, "cooldown": 0.5, "bounces": 2, "bounce_range": 3,
		"projectile_scale": 1.0, "projectile_speed": 1.3, "projectile_visual": "trident_maree",
	})
	c.abilities = [
		Ability.make({
			"id": "water_eveil_tsunami", "display_name": "Raz-de-marée",
			"description": "Une vague géante remonte le couloir, emporte les ennemis et les plaque contre le mur.",
			"kind": Ability.Kind.WAVE, "element": Element.Kind.WATER,
			"damage": 40, "radius": 2.0, "range": 9, "cooldown": 4.0, "wave_speed": 10.0,
			"blow_cells": 3, "slam_damage": 25,
		}),
		Ability.make({
			"id": "water_eveil_carapace", "display_name": "Bulle des abysses",
			"description": "Une bulle qui encaisse trois coups, et lui rend 1 PV si elle tient jusqu'au bout.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.WATER,
			"damage": 3, "duration": 12.0, "cooldown": 10.0, "heal_if_held": 1,
		}),
		Ability.make({
			"id": "water_eveil_prison", "display_name": "Glacier",
			"description": "Le cercle se hérisse de pics de glace : ce qui entre est gelé net, puis rampe.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.WATER,
			"damage": 8, "radius": 3.0, "duration": 8.0, "cooldown": 8.0,
			"snare": 2.0, "slow_duration": 2.0, "slow_factor": 0.4, "zone_style": "glacier_peint",
		}),
	]
	c.escape = Ability.make({
		"id": "water_eveil_torrent", "display_name": "Torrent",
		"description": "Il se change en torrent, file en suivant le couloir, et laisse un courant qui ralentit.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.WATER,
		"range": 9, "cooldown": 7.0, "follows_corridor": true, "wake_seconds": 4.0,
	})
	c.ultimate = Ability.make({
		"id": "water_eveil_deluge", "display_name": "Léviathan",
		"description": "Un serpent d'eau géant traverse le labyrinthe et emporte tout sur son passage, puis une pluie le soigne.",
		"kind": Ability.Kind.LEVIATHAN, "element": Element.Kind.WATER,
		"damage": 110, "radius": 3.0, "range": 12, "duration": 2.0, "heal_self": 2,
		"cooldown": 1.0, "is_ultimate": true, "pierces_walls": true,
	})
	return c


# --- Sorcier des Ténèbres : l'étalon. Précis, mobile, portée maximale. -----------

static func shadow() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = SHADOW
	c.display_name = "Sorcier des Ténèbres"
	c.element = Element.Kind.SHADOW
	c.description = "Maître des ombres et des portails. Frappe loin, se déplace vite, mais encaisse mal."
	c.power_level = 4
	c.base_health = 3
	c.move_speed = 5.1
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "shadow_orb", "display_name": "Orbe d'ombre",
		"description": "Une bille d'ombre qui remonte les couloirs jusqu'à sa cible.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SHADOW,
		"damage": 16, "range": 10, "cooldown": 0.45,
		"projectile_visual": "orbe_ombre",
	})
	c.abilities = [
		Ability.make({
			"id": "shadow_rune", "display_name": "Rune",
			"description": "Un passage laissé au sol. Qui marche dessus rampe et perd 10 PV par seconde tant qu'il n'en est pas sorti.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.SHADOW,
			# TROIS CHARGES rendues d'un coup après 8 s : on ne pose pas un
			# passage, on installe un DISPOSITIF. Trois recharges séparées
			# donneraient un sort qu'on lance sans y penser ; une seule qui rend
			# tout oblige à choisir le moment où l'on ouvre les trois.
			"zone_style": "rune_peinte", "charges": 3,
			# La rune ne punit ni l'attente ni le passage : elle punit d'être
			# DEDANS. L'englu est SOUTENU : il tient tant que la créature est dans la
			# rune et ne s'épuise qu'une demi-seconde après sa sortie. À 18 %
			# de son allure, traverser un portail large de trois cases devient
			# une éternité — et c'est ce qui donne son prix aux 10 PV par
			# seconde : la rune ne prélève pas un péage à l'entrée, elle RONGE
			# celui qu'elle retient. Huit secondes pleines coûtent 80 PV, soit
			# moins qu'un spectre de départ : on use, on n'exécute pas.
			"slow_sustained": true,
			"slow_duration": 0.5, "slow_factor": 0.18,
			"damage": 10, "radius": 1.4, "duration": 8.0, "cooldown": 8.0,
		}),
		Ability.make({
			"id": "shadow_blink", "display_name": "Passage",
			"description": "Il franchit la haie qu'il regarde et reparaît de l'autre côté.",
			"kind": Ability.Kind.BLINK, "element": Element.Kind.SHADOW,
			# ⚠️ ELLE TRAVERSE LES MURS, et c'est ce qui lui donne le droit
			# d'exister. Sans ça elle était un Pas de l'ombre raté : 4 cases
			# toutes les 9 s à côté de 6 cases toutes les 6,5 s — plus courte,
			# plus lente, sur le même geste.
			#
			# Le Pas de l'ombre reste la FUITE : il glisse le long du couloir,
			# vite et souvent, quand on est rattrapé. Le Passage, lui, coupe à
			# travers le labyrinthe — c'est un raccourci, pas une échappatoire,
			# et c'est la seule chose du jeu qui le fasse.
			"range": 4, "cooldown": 9.0, "pierces_walls": true,
		}),
		Ability.make({
			"id": "shadow_burst", "display_name": "Implosion d'ombre",
			"description": "L'ombre inspire : elle arrache les poursuivants à leur couloir, les rassemble, puis claque — et la flaque qu'elle laisse empoisonne quinze secondes durant.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.SHADOW,
			# ELLE ASPIRE, ELLE NE REPOUSSE PAS. La version précédente était une
			# explosion ordinaire — c'est-à-dire l'ultime du même mage en plus
			# petit (110 sur 6 cases contre 34 sur 2,6). Deux sorts de même forme
			# dans un kit de cinq, le troisième créneau ne servait à rien.
			#
			# Le souffle porte à 4,6 cases quand les dégâts n'en couvrent que
			# 2,6 : on ramène de loin ce qu'on va frapper de près. Le sort ne
			# gagne donc pas en portée, il convertit de la distance en dégâts.
			#
			# Et il RASSEMBLE, ce qui le noue au reste du personnage : on aspire
			# la meute dans la Rune posée à ses pieds, elle y rampe et s'y use,
			# et les deux translations restent là pour ressortir. C'est le seul
			# mage du jeu qui ATTIRE, à 3 PV — le risque fait partie du sort.
			#
			# ELLE S'ARRÊTE À DEUX CASES ET NE LIVRE PAS SON LANCEUR. Première
			# version mesurée en jeu : le dragonnet ramené collait le mage et
			# touchait dans la seconde — le sort OFFRAIT le coup qu'il devait
			# éviter. La meute est maintenant rangée sur un anneau, dans
			# l'explosion (rayon 2,6) mais hors de portée des griffes.
			"pull_radius": 4.6, "pull_cells": 3, "pull_min": 2,
			"damage": 34, "radius": 2.6, "cooldown": 9.0, "shockwave": true,
			# ET L'OMBRE RESTE. Quinze secondes de flaque noire là où tout le
			# monde vient d'être rassemblé : l'explosion cesse d'être un instant
			# pour devenir un LIEU, et c'est ce qui donne son prix au fait d'y
			# avoir tiré la meute. Le poison SUIT sa victime dehors — on n'en
			# sort pas en reculant d'une case.
			#
			# 1 PV par seconde, quinze secondes : 15 PV, contre 100 à 460 selon
			# la créature. C'est peu, et c'est voulu — ce sort ne tue pas par sa
			# flaque, il installe un endroit où l'on ne veut pas rester pendant
			# que la Rune, elle, ronge pour de bon.
			"residue_duration": 15.0,
			"poison_duration": 15.0, "poison_damage": 1,
		}),
	]
	c.escape = Ability.make({
		"id": "shadow_step", "display_name": "Pas de l'ombre",
		"description": "Il se fond dans l'ombre et reparaît plus loin.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.SHADOW,
		"range": 6, "cooldown": 6.5,
	})
	c.ultimate = Ability.make({
		"id": "shadow_rift", "display_name": "Faille des ténèbres",
		"description": "Le labyrinthe se déchire près de chaque poursuivant. Deux ombres sortent de chaque faille et les traquent deux minutes durant, à coups de gaz violet.",
		# CE N'ÉTAIT QU'UNE EXPLOSION EN PLUS GROS. 110 dégâts sur 6 cases : le
		# même geste que l'Implosion, la même lecture, et rien qui ressemble à un
		# ULTIME — juste un chiffre trois fois plus haut. Un ultime a le droit de
		# casser une règle du jeu ; celui-ci n'en cassait aucune.
		#
		# Il en casse deux maintenant. Il ouvre des passages LOIN du lanceur, là
		# où sont les proies — tous les autres sorts partent du mage. Et il
		# continue d'agir deux minutes après avoir été lancé, quand tout le reste
		# du jeu se joue en une seconde.
		#
		# TROIS FAILLES, DEUX OMBRES CHACUNE. Une porte par poursuivant serait la
		# fin de la partie sur un stage tardif : à huit poursuivants, seize
		# ombres nettoieraient le labyrinthe pendant que le joueur regarde. Trois
		# portes prennent la meute qui arrive — celle qu'on avait sous les yeux
		# en lançant le sort — et laissent le reste au joueur.
		"kind": Ability.Kind.SUMMON, "element": Element.Kind.SHADOW,
		"summon_id": "ombre", "summon_portals": 3, "summon_count": 2,
		"summon_cap": 6, "duration": 120.0,
		"cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Mage de Feu : le plus fort en dégâts, le plus fragile. -----------------------

static func fire() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = FIRE
	c.display_name = "Mage du Feu"
	c.element = Element.Kind.FIRE
	c.description = "Brûle tout ce qui approche. Dégâts de zone énormes, santé minimale."
	c.power_level = 4
	c.base_health = 3
	c.move_speed = 5.0
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "fire_bolt", "display_name": "Trait de flamme",
		"description": "Une flèche de feu, rapide et courte.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
		"damage": 19, "range": 8, "cooldown": 0.5,
		# Petite et VIVE : c'est le geste de tous les jours, il doit filer.
		"projectile_scale": 0.85, "projectile_speed": 1.15,
		"projectile_visual": "trait_peint",
	})
	c.abilities = [
		# BOULE DE FEU — refondue après essai. Elle ressemblait trait pour trait
		# à l'attaque de base (même forme, même sprite) et portait PLUS LOIN
		# qu'elle : 11 cases contre 8. Le sort le plus puissant du mage se
		# jouait donc en sniper, sans risque — l'inverse de ce qu'une boule de
		# feu raconte.
		#
		# Elle porte désormais à 7 — MOINS que l'attaque — et c'est le cœur du
		# changement : pour la placer, il faut avancer. En échange elle frappe
		# beaucoup plus fort, sur un rayon plus large, et revient plus vite.
		#
		# Visuellement elle est tout ce que la flèche n'est pas : deux fois plus
		# grosse, deux fois plus LENTE (on la voit venir, on peut s'écarter —
		# c'est du jeu, pas du décor), traînée de braises, et une onde de choc
		# à l'impact.
		Ability.make({
			"id": "fire_ball", "display_name": "Boule de feu",
			"description": "Lourde et lente. Il faut s'approcher — mais tout brûle.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": 42, "radius": 2.6, "range": 7, "cooldown": 5.0,
			"projectile_scale": 2.1, "projectile_speed": 0.5,
			"projectile_visual": "boule_peinte",
			"trail_density": 1.0, "shockwave": true,
			# Les mêmes flammes que le brasier, mais en PANACHE triangulaire
			# derrière la boule — et en explosion de feu à l'arrivée.
			"flames": 1.0,
		}),
		Ability.make({
			"id": "fire_ground", "display_name": "Sol embrasé",
			"description": "Une nappe de flammes qui brûle quiconque la traverse.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.FIRE,
			# Recharge de 2 s : la nappe devient un geste de tous les instants,
			# qu'on jette en courant sans y penser. C'est ce qui la sépare
			# définitivement du brasier — pas ses chiffres, sa CADENCE.
			"damage": 9, "radius": 2.2, "duration": 5.0, "cooldown": 2.0,
			# Brève et large : la nappe qu'on jette sous les pieds d'un
			# poursuivant. Elle ne retient RIEN — c'est ce qui la distingue
			# désormais du brasier, au-delà de ses chiffres.
			"flames": 0.6, "zone_style": "nappe_peinte",
		}),
		# AURA ARDENTE — refondue en BRASIER PIÈGE.
		#
		# C'était une seconde nappe de flammes, presque jumelle de « Sol
		# embrasé » : deux ZONE de feu qui se distinguaient par leurs chiffres,
		# pas par leur usage. Elle devient autre chose — un piège qu'on pose et
		# qui tient le terrain une DEMI-MINUTE : ce qui entre est retenu cinq
		# secondes, puis repart en brûlant trois secondes de plus.
		#
		# Trente secondes, c'est très long : ce n'est plus un sort de combat,
		# c'est un sort de TERRAIN. On le pose sur un couloir pour se le fermer,
		# ou devant un repaire pour cueillir ce qui en sort. Sa recharge est donc
		# la plus longue du mage — la fenêtre où l'on n'en a pas est le prix.
		#
		# Ses dégâts par seconde sont VOLONTAIREMENT bas : ce qui fait mal ici
		# n'est pas la nappe, c'est l'immobilisation. Additionner les deux
		# donnerait une exécution garantie à chaque passage.
		Ability.make({
			"id": "fire_aura", "display_name": "Aura ardente",
			"description": "Cinq brasiers. Chacun tient 30 s ; ce qui entre est cloué 5 s, puis brûle.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.FIRE,
			"damage": 6, "radius": 1.7, "duration": 30.0, "cooldown": 7.0,
			"snare": 5.0, "snare_burn": 3.0, "flames": 1.0, "zone_style": "brasier_peint",
			# CINQ brasiers d'affilée, puis la recharge. Un seul par recharge
			# faisait décider une fois par demi-minute ; cinq permettent
			# d'installer un dispositif — fermer un couloir, couvrir une sortie
			# de repaire, et garder la dernière en réserve.
			"charges": 5,
		}),
	]
	c.escape = Ability.make({
		"id": "fire_ember", "display_name": "Braise fuyante",
		"description": "Le mage se disperse en braises et se reforme plus loin.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.FIRE,
		"range": 5, "cooldown": 7.0,
	})
	c.ultimate = Ability.make({
		"id": "fire_nova", "display_name": "Embrasement",
		"description": "Le souffle traverse les murs, puis une pluie de météores s'abat.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.FIRE,
		# L'ULTIME VOLCANIQUE. Deux privilèges qu'aucun autre sort du jeu n'a :
		#
		# 1. l'onde TRAVERSE LES HAIES. Partout ailleurs les dégâts de zone se
		#    mesurent en distance de chemin, pour qu'une explosion ne passe pas
		#    à travers un mur. Ici le souffle balaye le labyrinthe entier — un
		#    ultime doit être la seule chose contre laquelle un mur ne protège
		#    pas, et l'onde de choc géante le montre à l'écran ;
		# 2. une PLUIE de météores tombe au hasard sur toute la carte pendant
		#    deux secondes et demie. Elle ne vise pas : c'est du chaos, et c'est
		#    ce qui la rend volcanique plutôt que chirurgicale.
		#
		# Les météores ne touchent QUE les ennemis. Une pluie qui blesserait
		# aussi le lanceur ferait de l'ultime un pari, alors qu'il se mérite en
		# cinq kills.
		"damage": 130, "radius": 7.0, "cooldown": 1.0, "is_ultimate": true,
		"shockwave": true, "pierces_walls": true, "flames": 1.4,
		"rain_count": 14, "rain_damage": 48, "rain_radius": 1.7,
		"rain_duration": 2.5, "rain_fall": 0.75,
	})
	return c


# --- Mage d'Eau : survie et contrôle. --------------------------------------------

static func water() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = WATER
	c.display_name = "Mage de l'Eau"
	c.element = Element.Kind.WATER
	c.description = "Ralentit, encaisse et se soigne. Le personnage qui pardonne les erreurs."
	c.power_level = 3
	c.base_health = 4
	c.move_speed = 4.9
	## DEUX kills, et non cinq : troisième exception à la règle de constitution.
	##
	## Son ultime n'est pas une explosion mais un ÉTAT de trente secondes. Un
	## état ne vaut que s'il revient assez souvent pour qu'on construise sa
	## partie autour ; à cinq kills, le Mage de l'Eau l'aurait vu deux fois par
	## niveau et n'en aurait rien tiré. À deux, l'exaltation devient son rythme
	## — c'est le mage qui joue AVEC son ultime, là où les autres jouent POUR.
	c.ultimate_required_kills = 2
	c.attack = Ability.make({
		"id": "water_jet", "display_name": "Jet d'eau",
		"description": "Un trait d'eau sous pression, régulier mais à mi-portée.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.WATER,
		"projectile_visual": "jet_eau",
		# Portée ramenée de 11 à 9 après mesure. À 11, le Mage de l'Eau gagnait
		# 83 % des parties SANS ÊTRE TOUCHÉ UNE SEULE FOIS : il abattait ses
		# poursuivants avant qu'ils n'arrivent, et aucun réglage défensif ne
		# pouvait rien y changer — c'est l'ALLONGE qui le mettait hors d'atteinte.
		# Être le survivant du groupe est son identité ; être intouchable non.
		"damage": 14, "range": 9, "cooldown": 0.4,
		# Fin et perçant, à l'opposé de la comète du Feu : petit, rapide, une
		# traînée de gouttes plutôt qu'un panache.
		"projectile_scale": 0.8, "projectile_speed": 1.25, "trail_density": 0.4,
	})
	c.abilities = [
		# VAGUE — elle DÉFERLE, elle n'explose pas.
		#
		# Deux corrections successives. D'abord une explosion circulaire, comme
		# la nova du Feu sous un autre nom, alors que sa description promettait
		# « une lame d'eau qui balaie le couloir devant le mage ». Puis un
		# souffle en cône — plus juste, mais toujours instantané.
		#
		# C'est une VAGUE : un front qui part du mage et remonte le couloir en
		# frappant ce qu'il traverse, sur le principe de la boule de feu. La
		# différence avec elle tient en une phrase : la boule cherche une cible,
		# la vague prend le couloir. On ne la place donc pas sur un ennemi, on
		# l'aligne sur un passage — et l'ennemi la VOIT venir, ce qui lui laisse
		# une intersection pour s'écarter.
		Ability.make({
			"id": "water_wave", "display_name": "Vague",
			"description": "Un mur d'eau qui remonte le couloir et emporte tout sur son passage.",
			"kind": Ability.Kind.WAVE, "element": Element.Kind.WATER,
			# Recharge de 2 s : la Vague devient le RYTHME du personnage. Elle
			# est sa seule vraie source de dégâts entre deux recharges — le
			# bouclier et le cercle sont défensifs, et le jet d'eau ne fait que
			# 14. À six secondes, le mage passait l'essentiel de son temps à
			# attendre son propre sort.
			"damage": 34, "radius": 1.5, "range": 7, "cooldown": 2.0,
			"wave_speed": 9.0,
		}),
		Ability.make({
			"id": "water_shield", "display_name": "Bouclier d'eau",
			"description": "Une coque liquide qui absorbe les coups avant les points de vie.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.WATER,
			# TRENTE secondes : le bouclier cesse d'être un réflexe d'urgence
			# pour devenir un état qu'on entretient. C'est cohérent avec le
			# Geyser, dont l'exaltation dure aussi trente secondes — le Mage de
			# l'Eau est le personnage qui joue en ENTRETENANT ses états, là où
			# le Feu joue en plaçant des coups.
			"damage": 45, "duration": 30.0, "cooldown": 5.0,
			# DEUX charges : le bouclier est la raison de jouer ce mage, et n'en
			# avoir qu'un toutes les douze secondes le réduisait à un bouton
			# qu'on appuie au hasard. Deux permettent d'en garder un en réserve.
			"charges": 2,
		}),
		# CERCLE GLACÉ — il ENGLUE pour de bon.
		#
		# Sa description l'annonçait déjà (« les ennemis qui la traversent
		# s'engluent ») et le sort n'en faisait rien : c'était une simple nappe
		# de dégâts. Il ralentit désormais à 35 % de l'allure pendant quatre
		# secondes — bien plus que la trempe de l'élément (62 %), parce que
		# c'est SON métier et non un effet secondaire.
		#
		# Comme le brasier du Feu, une fois par créature et par passage : une
		# zone tique deux fois par seconde, et un givre réarmé à chaque tick ne
		# s'arrêterait jamais.
		Ability.make({
			"id": "water_circle", "display_name": "Cercle glacé",
			"description": "Une flaque gelée : ce qui la traverse s'englue et rampe.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.WATER,
			"damage": 6, "radius": 3.0, "duration": 10.0, "cooldown": 8.0,
			"slow_duration": 4.0, "slow_factor": 0.35, "charges": 3,
			# Recharges resserrées avec celles de ses voisins : le Mage de l'Eau
			# est le personnage qui ENTRETIENT ses états (coque de 30 s,
			# exaltation de 30 s, givre qui tient le terrain). Des recharges
			# longues l'auraient obligé à choisir lequel entretenir, alors que
			# son fantasme est de tout tenir à la fois.
			"zone_style": "glace_peinte",
		}),
	]
	c.escape = Ability.make({
		"id": "water_current", "display_name": "Courant",
		"description": "Il se liquéfie et file avec le courant.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.WATER,
		"range": 6, "cooldown": 7.0,
	})
	# GEYSER — il SOIGNE, comme sa description l'a toujours prétendu.
	#
	# « Le sol se fend, l'eau jaillit et le mage se régénère » : la régénération
	# n'existait pas. Elle existe — et c'est ce qui fait de cet ultime autre
	# chose qu'un Embrasement bleu. Là où le Feu efface la salle, l'Eau la
	# nettoie ET remet le mage debout : le seul ultime du jeu qui rende une
	# partie perdue jouable.
	#
	# Il traverse les murs comme tout ultime, mais ne fait pas pleuvoir : ce
	# sont les privilèges du Feu. Le sien est de guérir.
	# GEYSER — trois temps, et le seul ultime du jeu qui laisse une TRACE.
	#
	# 1. la PRESSION : une colonne d'eau jaillit du sol et le souffle balaie le
	#    labyrinthe en traversant les haies, comme tout ultime ;
	# 2. la PLUIE : trente secondes d'averse sur toute la carte, qui frappe où
	#    elle tombe — l'équivalent aquatique des météores du Feu, mais étalé sur
	#    dix fois plus longtemps et bien moins fort à chaque goutte ;
	# 3. l'EXALTATION : pendant ces trente secondes, chaque coup du mage porte
	#    +10. C'est là que cet ultime se distingue vraiment de celui du Feu —
	#    l'Embrasement se joue à l'instant où on l'appuie, le Geyser se joue
	#    pendant la demi-minute qui suit.
	#
	# Ses dégâts immédiats sont donc VOLONTAIREMENT plus bas que ceux du Feu :
	# il paie son coup d'éclat en durée, pas en puissance.
	c.ultimate = Ability.make({
		"id": "water_geyser", "display_name": "Geyser",
		"description": "L'eau jaillit, la pluie tombe 30 s — et chaque coup du mage porte +10.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.WATER,
		"damage": 70, "radius": 6.0, "cooldown": 1.0, "is_ultimate": true,
		"shockwave": true, "pierces_walls": true, "heal_self": 3,
		"flames": 1.0,
		# NEUF GEYSERS D'UN COUP, éparpillés sur le labyrinthe. La colonne
		# unique montait sous les pieds du mage et l'effaçait une seconde
		# durant ; celles-ci frappent ce qui passe et ne cachent rien
		# d'important. C'est aussi ce qui donne à l'ultime sa PORTÉE : il ne
		# récompense plus seulement d'être au bon endroit, il nettoie la carte.
		"geyser_count": 9, "geyser_damage": 26, "geyser_radius": 1.5,
		"empower_bonus": 10, "empower_duration": 30.0,
		# Une averse : beaucoup de gouttes, faibles, étalées sur la durée de
		# l'exaltation. Elles tombent vite (0,45 s) — de la pluie, pas des
		# rochers qu'on voit venir.
		"rain_count": 30, "rain_damage": 16, "rain_radius": 1.3,
		"rain_duration": 30.0, "rain_fall": 0.45,
	})
	return c


# --- Mage de Terre : lent, solide, il modifie le labyrinthe. ----------------------

static func earth() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = EARTH
	c.display_name = "Mage de la Terre"
	c.element = Element.Kind.EARTH
	c.description = "Le plus résistant. Frappe fort, avance lentement, et peut fermer un couloir."
	c.power_level = 3
	c.base_health = 5
	c.move_speed = 4.5
	c.ultimate_required_kills = 6
	c.attack = Ability.make({
		"id": "earth_rock", "display_name": "Rocher",
		"description": "Un bloc de pierre lancé à bout de bras. Lent mais lourd.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.EARTH,
		"damage": 23, "range": 6, "cooldown": 0.7,
	})
	c.abilities = [
		# PICS DE TERRE — la gerbe COURT DANS LE COULOIR.
		#
		# C'était un souffle circulaire autour du mage : la même mécanique que
		# trois autres sorts du jeu. Elle part maintenant de ses pieds et file
		# droit devant, virages du couloir compris, en frappant tout ce qu'elle
		# croise — c'est le pilier de la Terre, la LIGNE, là où la Foudre a la
		# chaîne et le Feu ses placements.
		#
		# Puis les pointes RESTENT quatre secondes : ce qui passe dessus est
		# mordu et ralenti. C'est ce second temps qui en fait un sort de Terre
		# et non un simple tir — il hérisse un couloir comme son Mur en ferme un
		# autre. Les deux se jouent ensemble.
		Ability.make({
			"id": "earth_spikes", "display_name": "Pics de terre",
			"description": "Une gerbe de pierre court dans le couloir et y reste plantée.",
			"kind": Ability.Kind.LINE, "element": Element.Kind.EARTH,
			"damage": 30, "range": 6, "cooldown": 6.0,
			# La gerbe met une demi-seconde à parcourir ses six cases : assez
			# lent pour se voir partir, trop rapide pour être esquivé.
			"line_speed": 12.0, "radius": 0.6,
			"duration": 4.0, "line_bite": 6,
			"slow_duration": 1.2, "slow_factor": 0.55,
		}),
		# ÉGIDE DE PIERRE — il devient INTOUCHABLE, il ne ferme plus un couloir.
		#
		# C'était le « Mur de pierre » : une case de pierre posée derrière lui
		# pendant huit secondes. Le sort marchait, mais il était INVISIBLE — le
		# mur qu'il dressait était rendu comme n'importe quel mur du labyrinthe,
		# donc le joueur ne pouvait ni le reconnaître, ni savoir quand il
		# tomberait. Et la Terre venait de recevoir son sort de terrain avec les
		# Pics : deux sorts de couloir sur trois, c'était un mage à une idée.
		#
		# Il a maintenant le seul répit du jeu. Le bouclier de l'Eau est une
		# RÉSERVE : quarante-cinq dégâts absorbés, et il tombe. Celui-ci est un
		# RÉPIT : rien ne l'entame pendant trente secondes, quoi qu'il traverse.
		#
		# ⚠️ Trente secondes d'intouchabilité, c'est énorme — assumé, demandé,
		# et payé par la recharge la plus longue du jeu : soixante secondes. La
		# fenêtre de vulnérabilité reste donc plus longue que le répit.
		Ability.make({
			"id": "earth_aegis", "display_name": "Égide de pierre",
			"description": "Une coque de pierre l'enveloppe : plus rien ne peut le toucher.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.EARTH,
			"immune": true, "duration": 30.0, "cooldown": 60.0,
		}),
		# ÉCLATS DE CRISTAL — il PLANTE le cristal, et le cristal se bat seul.
		#
		# Le sort mentait deux fois. Il annonçait « trois éclats » et en tirait
		# UN ; et ce coup-là — 14 dégâts toutes les 8 s — était strictement
		# moins bon que son attaque de base, qui frappe à 23 toutes les 0,7 s.
		# Un bouton qu'aucun joueur n'avait de raison d'appuyer.
		#
		# Le cristal fiché dans le sol est la seule chose du jeu qui attaque
		# SANS le joueur. Les créatures de l'Invocateur chassent ; le cristal ne
		# bouge jamais, et c'est ce qui les sépare au premier coup d'œil.
		#
		# Il complète enfin le kit : le cristal tient le couloir sous le feu,
		# les Pics le hérissent, l'Égide protège le mage. Les trois sorts se
		# jouent ENSEMBLE, là où ils se faisaient concurrence.
		#
		# Jusqu'à sept éclats s'il est bien placé — mais seulement s'il l'est.
		# La récompense va au choix de l'endroit, ce qui est le geste du mage
		# lent : il ne peut pas courir corriger une erreur de placement.
		Ability.make({
			"id": "earth_crystals", "display_name": "Éclats de cristal",
			"description": "Un orbe de pierre l'entoure et fend le sol dès qu'une créature approche.",
			"kind": Ability.Kind.TURRET, "element": Element.Kind.EARTH,
			# CADENCE SERRÉE. À 1,3 s entre deux éclats, le cristal avait l'air
			# de réfléchir entre chaque tir : ce qui doit se lire comme une
			# mitraille de pierre ressemblait à une horloge. À 0,7 s il crache.
			# Les dégâts par éclat baissent d'autant — c'est le même sort, joué
			# deux fois plus vite.
			# L'ORBE tient trente secondes et balaie tout seul toutes les deux
			# secondes, dès qu'une créature entre à portée. Le mage n'a rien à
			# viser : c'est un sort qu'on POSE sur soi et qui travaille pendant
			# qu'on fait autre chose — ce qui convient au plus lent des sept.
			"damage": 24, "range": 7, "cooldown": 34.0,
			"duration": 30.0, "turret_interval": 2.0,
			# L'orbe SUIT le mage : la faille part toujours de ses pieds, où
			# qu'il aille. Posé quelque part, il ouvrirait des couloirs qu'il a
			# déjà quittés.
			"turret_follows": true,
			"turret_sweep": true, "line_speed": 0.0, "radius": 0.6,
			# Les gerbes ne restent que deux secondes : entre deux balayages,
			# le couloir doit se rouvrir. Le terrain, c'est le rôle des Pics,
			# qui tiennent quatre secondes et mordent deux fois plus fort.
			"spike_life": 2.0, "line_bite": 4,
			# Les gerbes sont jouées par la planche ANIMÉE, cristal et pierre en
			# alternance d'une case à l'autre.
			"spike_anim": true,
			"slow_duration": 0.8, "slow_factor": 0.6,
		}),
	]
	c.escape = Ability.make({
		"id": "earth_burrow", "display_name": "Terrier",
		"description": "Il s'enfonce dans le sol et ressort à couvert.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.EARTH,
		"range": 4, "cooldown": 8.0,
	})
	# SÉISME — le labyrinthe TREMBLE, et ses parois cèdent.
	#
	# C'était une détonation circulaire de plus. Il ouvre maintenant cinq
	# secondes de tremblement : la caméra part en secousses serrées qui se
	# calment, et des pans de mur s'effondrent par vagues — d'abord une
	# avalanche, puis un grondement.
	#
	# Les éboulements ne tombent pas n'importe où : ils cèdent AU PIED DES MURS.
	# C'est ce qui les sépare de la pluie de météores du Feu, qui tombe du ciel
	# sur des cases tirées au hasard. Ici, longer une paroi est dangereux et
	# tenir le milieu d'un carrefour ne l'est pas — le labyrinthe lui-même
	# devient l'arme.
	#
	# Et chaque éboulement fait JAILLIR la pierre : le sol s'ouvre là où il a
	# reçu, cristal ou roche selon la case. C'est la même planche animée que la
	# Faille, ce qui donne au mage une signature visuelle d'un bout à l'autre de
	# son kit.
	c.ultimate = Ability.make({
		"id": "earth_quake", "display_name": "Séisme",
		"description": "Cinq secondes de tremblement : les parois cèdent et la pierre jaillit.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.EARTH,
		"damage": 110, "radius": 5.0, "cooldown": 1.0, "is_ultimate": true,
		"shockwave": true, "pierces_walls": true,
		"quake_duration": 5.0, "quake_interval": 0.55, "quake_slides": 3,
		"quake_damage": 16, "quake_radius": 1.3,
		# Le fond continu : sept par seconde pendant cinq secondes, soit
		# trente-cinq dégâts pour qui reste debout du début à la fin. C'est ce
		# qui fait du Séisme un ultime et non un spectacle — les éboulements,
		# tirés au sort, ne touchent une créature donnée qu'une fois sur cinq.
		"quake_tremor": 7,
	})
	return c


# --- Mage de la Foudre : le plus rapide, tout en salves courtes. ------------------

static func thunder() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = THUNDER
	c.display_name = "Mage de la Foudre"
	c.element = Element.Kind.THUNDER
	c.description = "Le plus rapide du royaume. Frappe vite et souvent, mais tombe au premier faux pas."
	c.power_level = 4
	c.base_health = 3
	c.move_speed = 5.3
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "thunder_bolt", "display_name": "Éclair",
		"description": "Un trait de foudre, presque instantané. Il porte peu et frappe faible.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.THUNDER,
		"projectile_visual": "dard_foudre",
		# La cadence la plus rapide du jeu : c'est SA signature. Elle se PAIE en
		# dégâts et en portée — mesuré : à 15 dégâts et 10 cases, la Foudre
		# dominait STRICTEMENT les Ténèbres (mêmes PV, même portée, plus rapide
		# ET plus de dégâts) et ne mourait jamais en simulation.
		"damage": 10, "range": 7, "cooldown": 0.32,
		# Tracé en trait brisé, et non en orbe : voir `Ability.bolt`. La vitesse
		# est poussée parce que le dessin est instantané — une bille invisible
		# qui met un demi-tour de couloir à arriver ferait un coup en retard sur
		# ce qu'on voit.
		"bolt": true, "projectile_speed": 3.0,
	})
	c.abilities = [
		# CHAÎNE D'ÉCLAIRS — elle chaîne enfin.
		#
		# Elle s'appelait « Chaîne d'éclairs », promettait de « sauter d'un
		# ennemi à l'autre »… et était une explosion circulaire. C'était le
		# mensonge le plus voyant du catalogue : le nom, la description et
		# l'élément annonçaient tous les trois la même chose, et la mécanique
		# faisait autre chose.
		#
		# Elle touche maintenant une cible, puis rebondit sur trois voisines en
		# perdant un quart de sa force à chaque relais. Ça donne au Mage de la
		# Foudre son pilier : le MULTI-CIBLE, là où le Feu place des coups et
		# où l'Eau entretient des états. Sa portée de saut est courte — la
		# chaîne récompense les ennemis groupés, elle ne ratisse pas le
		# labyrinthe.
		Ability.make({
			"id": "thunder_chain", "display_name": "Chaîne d'éclairs",
			"description": "Un arc qui rebondit d'ennemi en ennemi, en s'affaiblissant.",
			"kind": Ability.Kind.CHAIN, "element": Element.Kind.THUNDER,
			# Recharge de 1,8 s : la chaîne devient le rythme du personnage,
			# comme la nappe pour le Feu et la vague pour l'Eau. Chaque mage a
			# désormais UN sort qu'il lance sans y penser.
			"damage": 30, "range": 7, "cooldown": 1.8,
			"chain_jumps": 3, "chain_range": 4, "chain_falloff": 0.75,
			"chain_delay": 0.07,
		}),
		# CHAMP DE FOUDRE — remplace une seconde TÉLÉPORTATION.
		#
		# « Fulgurance » était un BLINK de cinq cases… et « Éclair fuyant », sa
		# fuite, un BLINK de sept. Deux téléportations dans le même kit, dont
		# l'une strictement inférieure à l'autre : le sort n'avait aucune raison
		# d'exister.
		#
		# À la place, sa zone — et elle ne ressemble ni au brasier du Feu ni au
		# cercle glacé de l'Eau. Le brasier TIENT LE TERRAIN trente secondes en
		# grignotant ; le champ est court et BRUTAL : ce qui entre est paralysé
		# cinq secondes et électrocuté pendant ce temps. C'est une fenêtre pour
		# frapper, pas un piège qu'on installe.
		Ability.make({
			"id": "thunder_field", "display_name": "Champ de foudre",
			"description": "Un sol sous tension : ce qui entre est paralysé 5 s et électrocuté.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.THUNDER,
			"damage": 16, "radius": 2.4, "duration": 8.0, "cooldown": 11.0,
			"snare": 5.0, "zone_style": "champ", "charges": 2,
		}),
		# ORAGE — le nuage SUIT le mage.
		#
		# C'était une seconde zone posée au sol, qui aurait fait doublon avec le
		# Champ de foudre. Un orage n'est pas un lieu : c'est un événement qui se
		# DÉPLACE. Celui-ci se lève au-dessus du mage, l'accompagne, et foudroie
		# tout seul l'ennemi le plus proche toutes les 0,9 s.
		#
		# C'est la première chose du jeu qui accompagne le joueur au lieu de
		# l'attendre quelque part — et elle est faite pour ce personnage : le
		# plus rapide et le plus fragile, celui qui doit rester en mouvement. Le
		# sort le récompense de courir plutôt que de camper.
		#
		# Chaque décharge est un coup d'origine, donc elle déclenche l'arc de
		# l'élément : l'orage est redoutable au milieu d'un groupe et anodin sur
		# un isolé. Ses dégâts par décharge sont bas pour cette raison.
		Ability.make({
			"id": "thunder_storm", "display_name": "Orage",
			"description": "Un nuage qui suit le mage et foudroie seul ce qui l'approche.",
			"kind": Ability.Kind.STORM, "element": Element.Kind.THUNDER,
			# TRENTE secondes, mais à cadence RALENTIE. Le nuage accompagne
			# désormais le mage une demi-minute — la même durée que le brasier
			# du Feu et la coque de l'Eau, ce qui donne au jeu un rythme commun.
			#
			# La cadence passe de 0,9 à 2 s pour que la puissance TOTALE ne
			# bouge quasiment pas : 15 décharges au lieu de 13, soit 210 dégâts
			# contre 182. À cadence inchangée, trente secondes auraient fait 462
			# dégâts hors rebonds — la plus grosse source du jeu, sur un bouton
			# qu'on lance et qu'on oublie.
			#
			# Ce n'est pas qu'un réglage : à deux secondes d'intervalle, chaque
			# éclair se voit tomber et se compte. À 0,9 s ils se fondaient en un
			# grésillement continu.
			"damage": 14, "duration": 30.0, "cooldown": 34.0,
			"storm_interval": 2.0, "storm_range": 5,
		}),
	]
	c.escape = Ability.make({
		"id": "thunder_flash", "display_name": "Éclair fuyant",
		"description": "Il devient foudre le temps d'un battement de cils.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.THUNDER,
		"range": 7, "cooldown": 6.0,
	})
	# JUGEMENT CÉLESTE — il lève un CIEL, il ne fait pas une explosion.
	#
	# C'était une détonation circulaire de plus, comme celle des cinq autres
	# mages. Il ouvre désormais le ciel : la décharge initiale traverse les murs
	# comme tout ultime, puis DOUZE NUAGES se forment un peu partout dans le
	# labyrinthe et y restent quinze secondes, foudroyant chacun ce qui passe
	# sous lui.
	#
	# La différence avec l'Embrasement du Feu tient en une phrase : une météore
	# tombe UNE fois et disparaît, un nuage s'installe et frappe tant qu'il est
	# là. L'un est une averse, l'autre un ciel d'orage.
	#
	# Chaque frappe est un coup d'origine, donc elle rebondit sur les voisins :
	# le Jugement est ravageur sur une carte où les ennemis se pressent.
	c.ultimate = Ability.make({
		"id": "thunder_judgement", "display_name": "Jugement céleste",
		"description": "Le ciel s'ouvre : douze nuages se forment et foudroient 15 s durant.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.THUNDER,
		"damage": 140, "radius": 6.0, "cooldown": 1.0, "is_ultimate": true,
		"shockwave": true, "pierces_walls": true,
		"sky_clouds": 12, "sky_duration": 15.0, "sky_interval": 1.2, "sky_reach": 4,
	})
	return c


# --- Chronomancien : il gagne en gérant le terrain et ses erreurs de chemin. --------
static func chrono() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = CHRONO
	c.display_name = "Chronomancien"
	c.element = Element.Kind.TIME
	c.description = "Il ne fuit pas : il revient en arrière. Frappe peu, ralentit tout et répare ses erreurs de chemin."
	c.power_level = 3
	c.base_health = 4
	c.move_speed = 5.0
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "chrono_needle", "display_name": "Aiguille",
		"description": "Une aiguille d'horloge qui ralentit un court instant ce qu'elle touche.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.TIME,
		"projectile_visual": "aiguille_temps",
		"damage": 16, "range": 8, "cooldown": 0.45, "projectile_speed": 1.3,
	})
	c.abilities = [
		Ability.make({
			"id": "chrono_bubble", "display_name": "Bulle de lenteur",
			"description": "Dans la bulle, ennemis et projectiles vont au ralenti. Lui, non.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.TIME,
			"damage": 12, "radius": 2.6, "duration": 8.0, "cooldown": 12.0,
			"slow_duration": 0.3, "slow_factor": 0.35, "slow_sustained": true,
			"time_factor": 0.35, "zone_style": "bulle_peinte",
		}),
		# Le double repasse par où le mage est venu : c'est-à-dire sur ses poursuivants.
		Ability.make({
			"id": "chrono_echo", "display_name": "Écho",
			"description": "Un double rejoue ses 5 dernières secondes de marche et blesse ce qu'il croise.",
			"kind": Ability.Kind.ECHO, "element": Element.Kind.TIME,
			"damage": 60, "echo_seconds": 5.0, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "chrono_hourglass", "display_name": "Sablier",
			"description": "Pendant 8 s, les coups reçus sont notés. À la fin, il récupère la moitié des points perdus, arrondie au-dessus.",
			"kind": Ability.Kind.HOURGLASS, "element": Element.Kind.TIME,
			"duration": 8.0, "cooldown": 28.0, "hourglass_ratio": 0.5,
		}),
	]
	# Sans récupérer de vie : c'est le Sablier qui répare, le Retour ne répare que le chemin.
	c.escape = Ability.make({
		"id": "chrono_rewind", "display_name": "Retour",
		"description": "Il revient là où il était il y a 4 s, sans récupérer de vie.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.TIME,
		"rewind_seconds": 4.0, "cooldown": 7.0,
	})
	c.ultimate = Ability.make({
		"id": "chrono_stop", "display_name": "Arrêt du temps",
		"description": "Pendant 4 s, tout se fige sauf lui.",
		"kind": Ability.Kind.TIME_STOP, "element": Element.Kind.TIME,
		"duration": 4.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Mage de la Peste : plus on le poursuit, plus on s'empoisonne. --------------------
static func peste() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = PESTE
	c.display_name = "Mage de la Peste"
	c.element = Element.Kind.POISON
	c.description = "Plus on le poursuit, plus on s'empoisonne. Fragile et rapide : ses doses travaillent pendant qu'il fuit."
	c.power_level = 3
	c.base_health = 3
	c.move_speed = 5.2
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "peste_dart", "display_name": "Dard venimeux",
		"description": "Un trait faible, mais chaque coup ajoute une dose de poison, jusqu'à 3.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.POISON,
		"projectile_visual": "goutte_venin",
		"damage": 8, "range": 8, "cooldown": 0.45, "projectile_speed": 1.2,
	})
	c.abilities = [
		Ability.make({
			"id": "peste_trail", "display_name": "Traînée toxique",
			"description": "Pendant 6 s, il laisse du poison sur les cases où il passe.",
			"kind": Ability.Kind.TRAIL, "element": Element.Kind.POISON,
			"duration": 6.0, "trail_life": 5.0, "cooldown": 14.0,
		}),
		Ability.make({
			"id": "peste_contagion", "display_name": "Contagion",
			"description": "Le poison d'une cible passe aux ennemis proches.",
			"kind": Ability.Kind.CONTAGION, "element": Element.Kind.POISON,
			"range": 8, "chain_range": 5, "cooldown": 8.0,
		}),
		Ability.make({
			"id": "peste_transfusion", "display_name": "Transfusion",
			"description": "Il reprend de la vie selon le nombre d'ennemis empoisonnés.",
			"kind": Ability.Kind.TRANSFUSION, "element": Element.Kind.POISON,
			"transfuse_per": 2, "cooldown": 22.0,
		}),
	]
	c.escape = Ability.make({
		"id": "peste_mist", "display_name": "Brume",
		"description": "Il se dissout et reparaît plus loin, en laissant un nuage toxique derrière lui.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.POISON,
		"range": 6, "cooldown": 7.0, "cloud_duration": 4.0, "cloud_radius": 1.4,
		"zone_style": "gaz_peint",
	})
	c.ultimate = Ability.make({
		"id": "peste_pandemic", "display_name": "Pandémie",
		"description": "Tous les ennemis de la carte sont empoisonnés 8 s, et ceux qui en meurent éclatent en nuage toxique.",
		"kind": Ability.Kind.PANDEMIC, "element": Element.Kind.POISON,
		"duration": 8.0, "cooldown": 1.0, "is_ultimate": true,
		"cloud_duration": 4.0, "cloud_radius": 1.5,
	})
	return c


# --- Porte-Lumière : sa lumière aveugle, et les ennemis perdent sa trace. --------------
static func lumiere() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = LUMIERE
	c.display_name = "Porte-Lumière"
	c.category = CATEGORY_ANGE
	c.element = Element.Kind.LIGHT
	c.description = "Sa lumière aveugle : les ennemis perdent sa trace. Bons dégâts en ligne droite, s'il se place bien."
	c.power_level = 4
	c.base_health = 4
	c.move_speed = 5.0
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "lumiere_dawn", "display_name": "Trait d'aube",
		"description": "Un trait net. De temps en temps, il aveugle sa cible un instant.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.LIGHT,
		"projectile_visual": "trait_aube",
		"damage": 15, "range": 9, "cooldown": 0.45, "projectile_speed": 1.5,
	})
	c.abilities = [
		Ability.make({
			"id": "lumiere_lance", "display_name": "Lance solaire",
			"description": "Un rayon qui suit les couloirs, vire vers les ennemis et touche tout ce qu'il traverse.",
			"kind": Ability.Kind.BEAM, "element": Element.Kind.LIGHT,
			"damage": 55, "range": 14, "cooldown": 6.0,
		}),
		Ability.make({
			"id": "lumiere_sanctuary", "display_name": "Sanctuaire",
			"description": "Un cercle de lumière au sol : ce qui y entre est aveuglé et brûlé.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.LIGHT,
			"damage": 14, "radius": 2.4, "duration": 8.0, "cooldown": 16.0,
			"blind_seconds": 2.5, "zone_style": "sanctuaire_peint",
		}),
		Ability.make({
			"id": "lumiere_wings", "display_name": "Ailes gardiennes",
			"description": "Ses ailes absorbent un coup, puis aveuglent ce qui se tient au contact.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.LIGHT,
			"damage": 1, "duration": 8.0, "cooldown": 18.0,
			"blind_seconds": 3.0, "blind_radius": 2,
		}),
	]
	c.escape = Ability.make({
		"id": "lumiere_flight", "display_name": "Envol",
		"description": "Il survole les haies, et son atterrissage aveugle les ennemis proches.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.LIGHT,
		"range": 5, "cooldown": 8.0, "pierces_walls": true,
		"blind_seconds": 2.0, "blind_radius": 2,
	})
	c.ultimate = Ability.make({
		"id": "lumiere_aube", "display_name": "L'Aube",
		"description": "L'écran s'embrase, et une colonne de lumière tombe sur chaque ennemi de la carte, aveuglé 5 s.",
		"kind": Ability.Kind.DAWN, "element": Element.Kind.LIGHT,
		"damage": 130, "cooldown": 1.0, "is_ultimate": true, "blind_seconds": 5.0,
	})
	return c


# --- Ange de la Mort : ce qu'il a blessé, il vient le prendre. --------------------

static func mort() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = MORT
	c.display_name = "Ange de la Mort"
	c.category = CATEGORY_ANGE
	c.element = Element.Kind.DEATH
	c.description = "Ce qu'il a blessé, il vient le prendre : il achève les ennemis presque morts et récolte leurs âmes. Fragile."
	c.power_level = 4
	c.base_health = 3
	c.move_speed = 5.2
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "mort_crescent", "display_name": "Croissant noir",
		"description": "La faux lance un croissant de lame qui ne rate jamais.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.DEATH,
		"projectile_visual": "croissant_noir",
		"damage": 16, "range": 7, "cooldown": 0.5, "projectile_speed": 1.4,
	})
	c.abilities = [
		Ability.make({
			"id": "mort_moisson", "display_name": "Moisson",
			"description": "Un grand coup de faux en arc devant lui, qui achève ce qui est déjà blessé.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.DEATH,
			"damage": 45, "radius": 3.0, "arc": 150.0, "cooldown": 5.0, "execute_below": 0.35,
		}),
		Ability.make({
			"id": "mort_glas", "display_name": "Glas",
			"description": "Une cloche sonne : les ennemis du cercle sont marqués et prennent plus de dégâts.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.DEATH,
			"damage": 6, "radius": 2.6, "duration": 7.0, "cooldown": 15.0,
			"mark_seconds": 3.0, "zone_style": "glas_peint",
		}),
		Ability.make({
			"id": "mort_ames", "display_name": "Âmes captives",
			"description": "Il lâche une âme et toutes celles de ses victimes : elles chassent dans les couloirs.",
			"kind": Ability.Kind.SOULS, "element": Element.Kind.DEATH,
			"damage": 30, "range": 14, "cooldown": 9.0,
		}),
	]
	c.escape = Ability.make({
		"id": "mort_passage", "display_name": "Passage",
		"description": "Il se défait en plumes noires et traverse les haies.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.DEATH,
		"range": 5, "cooldown": 8.0, "pierces_walls": true,
	})
	c.ultimate = Ability.make({
		"id": "mort_heure", "display_name": "L'Heure dernière",
		"description": "Éclipse : une faux géante traverse l'écran, et chaque ennemi perd la moitié de ses PV.",
		"kind": Ability.Kind.LAST_HOUR, "element": Element.Kind.DEATH,
		"damage": 1, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Ange des Étoiles : elle dessine ses pièges dans le labyrinthe. -----------------

static func etoiles() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = ETOILES
	c.display_name = "Ange des Étoiles"
	c.category = CATEGORY_ANGE
	c.element = Element.Kind.STARS
	c.description = "Elle pose des étoiles dans le labyrinthe : les rayons qui les relient brûlent ce qui passe. C'est le placement qui fait ses dégâts."
	c.power_level = 4
	c.base_health = 4
	c.move_speed = 5.1
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "etoiles_eclat", "display_name": "Éclat stellaire",
		"description": "Un petit trait d'étoile. Au troisième coup, les étoiles de la cible explosent.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.STARS,
		"projectile_visual": "eclat_stellaire",
		"damage": 12, "range": 8, "cooldown": 0.45, "projectile_speed": 1.5,
	})
	c.abilities = [
		Ability.make({
			"id": "etoiles_constellation", "display_name": "Constellation",
			"description": "Pose une étoile à ses pieds. Des rayons les relient par-dessus les haies et brûlent ce qui passe.",
			"kind": Ability.Kind.CONSTELLATION, "element": Element.Kind.STARS,
			"damage": 28, "duration": 16.0, "cooldown": 3.0,
		}),
		Ability.make({
			"id": "etoiles_pluie", "display_name": "Pluie d'étoiles",
			"description": "Des étoiles tombent une à une autour d'elle, sur les ennemis d'abord.",
			"kind": Ability.Kind.STARFALL, "element": Element.Kind.STARS,
			"damage": 22, "radius": 3.5, "star_falls": 9, "cooldown": 11.0,
		}),
		Ability.make({
			"id": "etoiles_voile", "display_name": "Voile de lune",
			"description": "Pendant un court instant, les coups la traversent.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.STARS,
			"immune": true, "duration": 3.0, "cooldown": 15.0,
		}),
	]
	c.escape = Ability.make({
		"id": "etoiles_filante", "display_name": "Étoile filante",
		"description": "Un saut rapide en ligne droite, qui laisse une traînée brûlante.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.STARS,
		"range": 5, "cooldown": 8.0, "trail_damage": 25,
	})
	c.ultimate = Ability.make({
		"id": "etoiles_nuit", "display_name": "Nuit éternelle",
		"description": "La nuit tombe sur l'écran, et une comète frappe chaque ennemi de la carte.",
		"kind": Ability.Kind.DAWN, "element": Element.Kind.STARS,
		"damage": 120, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Archange d'Acier : il va au contact, et ses plaques encaissent pour lui. ---------

static func acier() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = ACIER
	c.display_name = "Archange d'Acier"
	c.category = CATEGORY_ANGE
	c.element = Element.Kind.STEEL
	c.description = "Lent et massif, il frappe le sol de loin : ses plaques d'armure encaissent les coups, et ses kills les reforgent."
	c.power_level = 4
	c.base_health = 6
	c.move_speed = 4.3
	c.ultimate_required_kills = 7
	c.attack = Ability.make({
		"id": "acier_marteau", "display_name": "Coup de marteau",
		"description": "Le marteau frappe le sol : une onde de choc court jusqu'à sa cible et touche ce qui l'entoure.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.STEEL,
		"projectile_visual": "onde_marteau",
		"damage": 22, "radius": 1.5, "range": 6, "cooldown": 0.65, "projectile_speed": 1.1,
	})
	c.abilities = [
		Ability.make({
			"id": "acier_ailes", "display_name": "Ailes-lames",
			"description": "Une volée de lames part en éventail par-dessus les haies, puis revient vers lui et retouche au retour.",
			"kind": Ability.Kind.BLADES, "element": Element.Kind.STEEL,
			"damage": 30, "range": 5, "blade_count": 5, "cooldown": 7.0,
		}),
		Ability.make({
			"id": "acier_enclume", "display_name": "Onde d'enclume",
			"description": "Il frappe le sol : l'onde court dans les couloirs et étourdit ce qu'elle touche.",
			"kind": Ability.Kind.ANVIL, "element": Element.Kind.STEEL,
			"damage": 34, "range": 7, "stun_seconds": 1.5, "cooldown": 10.0,
		}),
		Ability.make({
			"id": "acier_rempart", "display_name": "Rempart",
			"description": "Il se referme dans ses ailes : immobile et intouchable, il renvoie les coups reçus.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.STEEL,
			"immune": true, "duration": 4.0, "cooldown": 18.0, "reflect_damage": 40,
		}),
	]
	c.escape = Ability.make({
		"id": "acier_charge", "display_name": "Charge",
		"description": "Il fonce en ligne droite et renverse ce qu'il croise.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.STEEL,
		"range": 4, "cooldown": 8.0, "trail_damage": 30, "blow_cells": 2,
	})
	c.ultimate = Ability.make({
		"id": "acier_fusion", "display_name": "Acier en fusion",
		"description": "Son armure chauffe au rouge : plaques pleines, il grandit, et ses coups plus forts projettent les ennemis.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.STEEL,
		"damage": 70, "radius": 3.5, "molten_seconds": 10.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Archange du Ciel : il voit le labyrinthe d'en haut. -------------------------------

## Tous les autres se battent dans les couloirs. Lui frappe par-dessus les haies (`from_sky`) et
## s'envole au-dessus des murs ; en échange, il est fragile et frappe court. Les chiffres sont
## ceux de sa fiche (`docs/prompts/mages/mage_ciel.md`), réglés sur la passe rapide seulement.
static func ciel() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = CIEL
	c.display_name = "Archange du Ciel"
	c.category = CATEGORY_ANGE
	c.element = Element.Kind.SKY
	c.description = "Il voit le labyrinthe d'en haut : ses coups tombent du ciel par-dessus les haies, et il s'envole au-dessus des murs. Fragile, il frappe court."
	c.power_level = 4
	c.base_health = 3
	c.move_speed = 5.2
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "ciel_lance", "display_name": "Lance céleste",
		"description": "Une lance de lumière tombe du ciel sur l'ennemi le plus proche, même derrière une haie.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SKY,
		"projectile_visual": "lance_celeste", "from_sky": true, "sky_fall": 0.35,
		# 18 et non 17 : à 17, la Mort et la Foudre le dominaient sur le papier (`_test_no_dominance`),
		# qui ne voit pas que sa portée passe les haies.
		"damage": 18, "range": 6, "cooldown": 0.55,
	})
	c.abilities = [
		Ability.make({
			"id": "ciel_plumes", "display_name": "Plumes-lames",
			"description": "Ses ailes lâchent un éventail de cinq plumes tranchantes, qui filent par-dessus les haies.",
			"kind": Ability.Kind.BLADES, "element": Element.Kind.SKY,
			"damage": 22, "range": 5, "blade_count": 5, "cooldown": 5.0, "blades_return": false,
		}),
		Ability.make({
			"id": "ciel_colonne", "display_name": "Colonne du ciel",
			"description": "Un pilier de lumière s'abat sur l'ennemi visé, même derrière une haie, et cloue ceux qui l'entourent. Les boss ne sont pas cloués.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SKY,
			"projectile_visual": "colonne_ciel", "from_sky": true, "sky_fall": 0.55,
			"damage": 40, "radius": 1.5, "stun_seconds": 2.0, "range": 7, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "ciel_cloche", "display_name": "Cloche céleste",
			"description": "Sa cloche sonne : une onde part de lui, passe les haies et étourdit tout ce qui l'entoure. Les boss ne sont pas étourdis.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.SKY,
			"damage": 10, "radius": 4.0, "stun_seconds": 1.5, "cooldown": 12.0, "pierces_walls": true,
		}),
	]
	c.escape = Ability.make({
		"id": "ciel_envol", "display_name": "Envol",
		"description": "Il s'élève trois secondes et vole par-dessus les haies sans pouvoir être touché, puis retombe avec une onde. Il ne ramasse rien en vol.",
		"kind": Ability.Kind.FLIGHT, "element": Element.Kind.SKY,
		"duration": 3.0, "flight_speed": 1.4, "damage": 20, "radius": 1.5, "cooldown": 12.0,
	})
	c.ultimate = Ability.make({
		"id": "ciel_jugement", "display_name": "Jugement des Six Ailes",
		"description": "Six ailes de lumière s'ouvrent dans son dos, et douze épées tombent une à une sur les ennemis de la carte, par-dessus les murs.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.SKY,
		"damage": 0, "radius": 0.0, "cooldown": 1.0, "is_ultimate": true, "pierces_walls": true,
		"rain_count": 12, "rain_hunts": true, "rain_damage": 45, "rain_radius": 0.6,
		"rain_duration": 3.0, "rain_fall": 0.45, "rain_delay": 0.5,
	})
	return c


# --- Chérubin : le gardien d'Éden. Nul n'approche de son épée. -------------------------

## Il garde un LIEU : son trait brûle ce qui arrive à son contact, et son extra plante un cercle où
## aucun ennemi n'entre. Plus solide et plus lent que la fiche ne le prévoyait (4 PV, 4,9) : à ces
## chiffres, le Mage de l'Eau le dominait dans `_test_no_dominance`. Réglé sur passe rapide seulement.
static func cherubin() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = CHERUBIN
	c.display_name = "Chérubin"
	c.category = CATEGORY_ANGE
	c.element = Element.Kind.SACRED
	c.description = "Le gardien d'Éden, à quatre ailes. Ce qu'il a touché brûle en l'approchant, et son épée plantée ferme un cercle où nul n'entre."
	c.power_level = 4
	c.base_health = 5
	c.move_speed = 4.7
	c.ultimate_required_kills = 6
	c.attack = Ability.make({
		"id": "cherubin_glaive", "display_name": "Flamme du glaive",
		"description": "Un jet de flamme saphir file dans le couloir jusqu'à sa cible, et brûle tout ce qu'il traverse.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SACRED,
		"projectile_visual": "flamme_glaive", "pierce_line": true,
		"damage": 15, "range": 5, "cooldown": 0.5, "projectile_speed": 1.4,
	})
	c.abilities = [
		Ability.make({
			"id": "cherubin_tournoyant", "display_name": "Glaive tournoyant",
			"description": "Son épée de flamme tourne autour de lui et frappe tout ce qui passe à sa portée.",
			"kind": Ability.Kind.WHIRL, "element": Element.Kind.SACRED,
			"damage": 14, "radius": 1.5, "duration": 4.0, "whirl_interval": 0.5, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "cherubin_roues", "display_name": "Roues d'Ézéchiel",
			"description": "Deux roues de feu couvertes d'yeux roulent dans les couloirs, dans deux sens, et brûlent ce qu'elles croisent.",
			"kind": Ability.Kind.WHEELS, "element": Element.Kind.SACRED,
			"damage": 30, "range": 7, "wave_speed": 9.0, "cooldown": 8.0,
		}),
		Ability.make({
			"id": "cherubin_voile", "display_name": "Ailes voilées",
			"description": "Il se couvre de sa seconde paire d'ailes : intouchable un instant, il repousse ce qui le touche.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.SACRED,
			"immune": true, "duration": 2.0, "repel_cells": 2, "cooldown": 14.0,
		}),
	]
	c.escape = Ability.make({
		"id": "cherubin_eclair", "display_name": "Comme l'éclair",
		"description": "Il file droit devant comme l'éclair, sans tourner, et laisse une traînée de flamme.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.SACRED,
		"range": 5, "cooldown": 9.0, "trail_damage": 20,
	})
	c.ultimate = Ability.make({
		"id": "cherubin_jardin", "display_name": "Le Jardin gardé",
		"description": "Il plante son épée : 8 s durant, aucun ennemi n'entre dans le cercle, ceux qui s'y trouvent sont rejetés et brûlent, et il regagne 1 PV. Les boss entrent, et brûlent.",
		"kind": Ability.Kind.GARDEN, "element": Element.Kind.SACRED,
		"damage": 15, "radius": 3.0, "duration": 8.0, "heal_self": 1, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Démon du Pacte : moins il lui reste de vie, plus il frappe fort. ------------------

static func demon() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = DEMON
	c.display_name = "Démon du Pacte"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.BLOOD
	c.description = "Il a signé avec sa propre vie : moins il lui en reste, plus il frappe fort. Se soigner, ou rester au bord du gouffre ?"
	c.power_level = 4
	c.base_health = 4
	c.move_speed = 5.1
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "demon_griffe", "display_name": "Griffe de sang",
		"description": "D'un geste de la main, trois griffures de sang filent vers leur cible et ne la ratent jamais.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.BLOOD,
		"projectile_visual": "griffe_sang",
		"damage": 18, "range": 7, "cooldown": 0.5, "projectile_speed": 1.4,
	})
	c.abilities = [
		Ability.make({
			"id": "demon_pacte", "display_name": "Pacte de sang",
			"description": "Il sacrifie un point de vie pour renforcer tous ses coups. Le pacte ne prend jamais le dernier.",
			"kind": Ability.Kind.PACT, "element": Element.Kind.BLOOD,
			"self_cost": 1, "empower_bonus": 8, "empower_duration": 6.0, "cooldown": 12.0,
		}),
		Ability.make({
			"id": "demon_sillon", "display_name": "Sillon de soufre",
			"description": "Des flammes de sang courent dans le couloir et y restent.",
			"kind": Ability.Kind.LINE, "element": Element.Kind.BLOOD,
			"damage": 42, "range": 7, "cooldown": 7.0,
			"line_speed": 14.0, "radius": 0.6, "duration": 3.0, "line_bite": 6,
			"plant_style": "sillon_peint",
		}),
		Ability.make({
			"id": "demon_festin", "display_name": "Festin",
			"description": "Une gueule de sang se referme autour de lui : s'il a touché quelqu'un, il reprend un point de vie.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.BLOOD,
			"damage": 26, "radius": 2.0, "cooldown": 14.0, "heal_self": 1, "heal_needs_hit": true,
		}),
	]
	c.escape = Ability.make({
		"id": "demon_bond", "display_name": "Bond de soufre",
		"description": "Il disparaît dans une gerbe de sang et reparaît plus loin dans le couloir.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.BLOOD,
		"range": 4, "cooldown": 8.0,
	})
	c.ultimate = Ability.make({
		"id": "demon_dernier", "display_name": "Dernier Pacte",
		"description": "Le sceau éclate : il tombe à 1 PV et devient intouchable, puis récupère les trois quarts de ce qu'il a donné.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.BLOOD,
		"damage": 60, "radius": 4.0, "cooldown": 1.0, "is_ultimate": true,
		"last_pact_seconds": 6.0, "last_pact_return": 0.75,
	})
	return c


# --- La Démone de la Discorde : elle retourne les ennemis les uns contre les autres. --

static func discorde() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = DISCORDE
	c.display_name = "Démone de la Discorde"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.CHARM
	c.description = "Elle tire les fils et laisse les autres se battre. Redoutable dans la foule, bien seule face à un seul ennemi."
	c.power_level = 3
	c.base_health = 3
	# Rapide : elle ne frappe pas fort, et doit pouvoir se replacer autour de la foule.
	c.move_speed = 5.5
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "discorde_murmure", "display_name": "Murmure",
		"description": "Un fil d'argent file de ses doigts. Au troisième, la cible est troublée.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.CHARM,
		"projectile_visual": "fil_murmure",
		"damage": 14, "range": 7, "cooldown": 0.5, "projectile_speed": 1.3,
	})
	c.abilities = [
		Ability.make({
			"id": "discorde_oeil", "display_name": "Mauvais Œil",
			"description": "Un ennemi se retourne contre ses voisins et ne la chasse plus.",
			"kind": Ability.Kind.POSSESS, "element": Element.Kind.CHARM,
			"range": 8, "cooldown": 10.0, "possess_seconds": 5.0, "possess_strike": 20,
		}),
		Ability.make({
			"id": "discorde_cercle", "display_name": "Cercle de Discorde",
			"description": "Un cercle se pose sur l'ennemi le plus proche : plus ils y sont nombreux, plus chacun y souffre.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.CHARM,
			"damage": 16, "radius": 2.5, "range": 7, "duration": 6.0, "cooldown": 12.0,
			"discord_bonus": 0.5, "zone_on_prey": true, "zone_style": "toile_peinte",
		}),
		Ability.make({
			"id": "discorde_lien", "display_name": "Lien de Souffrance",
			"description": "Une chaîne relie trois ennemis proches : la moitié des coups portés à l'un passe aux deux autres.",
			"kind": Ability.Kind.BOND, "element": Element.Kind.CHARM,
			"range": 8, "radius": 4.0, "duration": 8.0, "cooldown": 14.0,
			"bond_count": 3, "bond_share": 0.5,
		}),
	]
	c.escape = Ability.make({
		"id": "discorde_echange", "display_name": "Échange",
		"description": "Elle prend la place de l'ennemi le plus proche, et lui laisse la sienne.",
		"kind": Ability.Kind.SWAP, "element": Element.Kind.CHARM,
		"range": 6, "cooldown": 9.0,
	})
	c.ultimate = Ability.make({
		"id": "discorde_grande", "display_name": "Grande Discorde",
		"description": "Tous les ennemis à l'écran se battent entre eux, et leurs morts comptent pour elle. Seuls les boss résistent.",
		"kind": Ability.Kind.POSSESS, "element": Element.Kind.CHARM,
		"cooldown": 1.0, "is_ultimate": true, "possess_seconds": 6.0, "possess_strike": 22,
	})
	return c


static func braise() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = BRAISE
	c.display_name = "Roi de Braise"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.EMBER
	c.description = "Son armure vole et se bat seule : il la lance dans les couloirs, puis la rappelle à travers le labyrinthe."
	c.power_level = 3
	c.base_health = 4
	# Son allure de base, armure complète : chaque pièce lancée y ajoute `PIECE_SPEED_BONUS`.
	c.move_speed = 4.4
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "braise_poing", "display_name": "Poing de braise",
		"description": "Un poing d'or noirci file, frappe et rentre dans un jet d'escarbilles.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.EMBER,
		"projectile_visual": "poing_braise",
		# Le coup le plus lourd des démons : c'est ce qu'il a en échange de son allure et de sa portée.
		"damage": 34, "range": 6, "cooldown": 0.75, "projectile_speed": 1.2,
	})
	c.abilities = [
		Ability.make({
			"id": "braise_chasseurs", "display_name": "Gantelets chasseurs",
			"description": "Ses deux gantelets quittent leur orbite et s'abattent seuls sur les ennemis.",
			"kind": Ability.Kind.HUNTERS, "element": Element.Kind.EMBER,
			"damage": 18, "range": 8, "duration": 6.0, "cooldown": 12.0,
		}),
		Ability.make({
			"id": "braise_plastron", "display_name": "Fournaise",
			"description": "Posé au sol, il s'ouvre comme un four sur le premier ennemi qui passe, et le retient.",
			"kind": Ability.Kind.CHEST, "element": Element.Kind.EMBER,
			"damage": 20, "hold_seconds": 3.0, "cooldown": 12.0,
		}),
		Ability.make({
			"id": "braise_rappel", "display_name": "Rappel",
			"description": "Toutes ses pièces reviennent d'un coup, à travers les haies, et blessent ce qu'elles croisent.",
			"kind": Ability.Kind.RECALL, "element": Element.Kind.EMBER,
			"damage": 30, "cooldown": 8.0,
		}),
	]
	c.escape = Ability.make({
		"id": "braise_coquille", "display_name": "Coquille de cendre",
		"description": "Il saute et laisse une armure de cendre, qui attire les ennemis puis explose.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.EMBER,
		"range": 5, "cooldown": 10.0, "damage": 40, "decoy_seconds": 3.0, "decoy_radius": 2.5,
	})
	c.ultimate = Ability.make({
		"id": "braise_cages", "display_name": "Les Mille Cages",
		"description": "Une cage d'or en fusion s'abat sur chaque ennemi, le bloque, puis se resserre. Les boss subissent seulement le coup.",
		"kind": Ability.Kind.CAGES, "element": Element.Kind.EMBER,
		"damage": 60, "duration": 4.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


static func ecarlate() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = ECARLATE
	c.display_name = "Chevalier Écarlate"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.BLADE
	c.description = "Ses coups laissent des entailles qui ne font rien, jusqu'à ce qu'il rengaine. Alors, tout s'ouvre en même temps."
	c.power_level = 3
	c.base_health = 4
	c.move_speed = 5.2
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "ecarlate_entaille", "display_name": "Entaille",
		"description": "Un croissant de lumière blanche part de sa lame, et laisse une entaille.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.BLADE,
		"projectile_visual": "coupe_ecarlate",
		"damage": 15, "range": 5, "cooldown": 0.5, "projectile_speed": 1.5, "cuts": 1,
	})
	c.abilities = [
		Ability.make({
			"id": "ecarlate_pas", "display_name": "Pas de Lame",
			"description": "Il file droit dans le couloir et coupe tout ce qu'il traverse.",
			"kind": Ability.Kind.DASH, "element": Element.Kind.BLADE,
			"damage": 20, "range": 5, "cooldown": 8.0, "cuts": 1,
		}),
		Ability.make({
			"id": "ecarlate_garde", "display_name": "Garde",
			"description": "Le premier coup reçu est annulé, et sa riposte entaille tout ce qui l'entoure.",
			"kind": Ability.Kind.GUARD, "element": Element.Kind.BLADE,
			"damage": 30, "radius": 2.0, "duration": 1.5, "cooldown": 10.0, "cuts": 2,
		}),
		Ability.make({
			"id": "ecarlate_rengaine", "display_name": "Rengaine",
			"description": "Sa lame rentre au fourreau : un silence, puis toutes les entailles à portée éclatent.",
			"kind": Ability.Kind.SHEATHE, "element": Element.Kind.BLADE,
			"damage": 18, "cut_damage": 18, "range": 8, "cooldown": 9.0,
		}),
	]
	c.escape = Ability.make({
		"id": "ecarlate_volte", "display_name": "Volte-face",
		"description": "Il saute en arrière dans une pluie de pétales.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.BLADE,
		"range": 5, "cooldown": 9.0, "backward": true,
	})
	c.ultimate = Ability.make({
		"id": "ecarlate_derniere", "display_name": "Dernière Rengaine",
		"description": "Le monde perd ses couleurs. Chaque ennemi reçoit cinq entailles, il rengaine, et tout s'ouvre.",
		"kind": Ability.Kind.SHEATHE, "element": Element.Kind.BLADE,
		"cuts": 5, "cut_damage": 18, "duration": 1.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


static func geolier() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = GEOLIER
	c.display_name = "Geôlier"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.COLDFIRE
	c.description = "Une armure vide qu'habite une flamme froide. Il flotte, enchaîne ce qu'il touche, et passe à travers les haies."
	c.power_level = 3
	# Une armure massive : il encaisse plus que les autres démons, et frappe moins vite.
	c.base_health = 5
	c.move_speed = 4.8
	c.ultimate_required_kills = 6
	c.attack = Ability.make({
		"id": "geolier_poing", "display_name": "Poing spectral",
		"description": "Un gantelet de flamme froide file et frappe. Au troisième coup, l'ennemi est entravé.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.COLDFIRE,
		"projectile_visual": "poing_spectral",
		"damage": 16, "range": 6, "cooldown": 0.6, "projectile_speed": 1.2,
	})
	c.abilities = [
		Ability.make({
			"id": "geolier_crochet", "display_name": "Crochet",
			"description": "Une chaîne attrape l'ennemi le plus éloigné à portée et le traîne devant lui, sonné.",
			"kind": Ability.Kind.HOOK, "element": Element.Kind.COLDFIRE,
			"damage": 20, "range": 8, "stun_seconds": 1.0, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "geolier_chaines", "display_name": "Chaînes d'âmes",
			"description": "Des chaînes le relient à trois ennemis : ralentis, ils brûlent de froid tant qu'elles tiennent.",
			"kind": Ability.Kind.SOUL_CHAINS, "element": Element.Kind.COLDFIRE,
			"damage": 12, "range": 6, "duration": 6.0, "cooldown": 13.0,
			"bond_count": 3, "slow_factor": 0.5,
		}),
		Ability.make({
			"id": "geolier_souffle", "display_name": "Souffle glacé",
			"description": "Une nova de flamme froide déferle autour de lui et fige ce qu'elle touche.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.COLDFIRE,
			"damage": 30, "radius": 2.5, "stun_seconds": 2.0, "cooldown": 11.0,
		}),
	]
	c.escape = Ability.make({
		"id": "geolier_traversee", "display_name": "Traversée spectrale",
		"description": "Il devient flamme et passe à travers une haie, droit devant.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.COLDFIRE,
		"range": 3, "cooldown": 12.0, "pierces_walls": true,
	})
	c.ultimate = Ability.make({
		"id": "geolier_geole", "display_name": "La Geôle",
		"description": "Un cercle de flamme froide s'abat autour de lui : des chaînes clouent au sol chaque ennemi à l'intérieur. Les boss brûlent sans être cloués.",
		"kind": Ability.Kind.GAOL, "element": Element.Kind.COLDFIRE,
		"damage": 15, "radius": 6.0, "duration": 5.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


static func dragon() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = DRAGON
	c.display_name = "Dragon des Abysses"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.INFERNO
	c.description = "Un dragon-démon qui met le feu au sol. Dans les flammes il va plus vite, et il dévore ce qui brûle."
	c.power_level = 3
	# Grand et lourd : il encaisse comme le Geôlier, et marche plus lentement.
	c.base_health = 5
	c.move_speed = 4.4
	c.ultimate_required_kills = 6
	c.attack = Ability.make({
		"id": "dragon_crachat", "display_name": "Crachat de magma",
		"description": "Une boule de lave qui éclate à l'impact et laisse la case en feu.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.INFERNO,
		"projectile_visual": "crachat_magma",
		"damage": 26, "range": 5, "cooldown": 0.75, "projectile_speed": 1.0,
	})
	c.abilities = [
		Ability.make({
			"id": "dragon_souffle", "display_name": "Souffle infernal",
			"description": "Un torrent de flammes court dans le couloir devant lui, et chaque case touchée reste en feu.",
			"kind": Ability.Kind.BREATH, "element": Element.Kind.INFERNO,
			"damage": 40, "range": 5, "ground_fire": 5.0, "cooldown": 10.0,
		}),
		Ability.make({
			"id": "dragon_morsure", "display_name": "Morsure",
			"description": "Il bondit sur l'ennemi le plus proche et le mord. Si la proie brûlait, il la dévore et se soigne.",
			"kind": Ability.Kind.BITE, "element": Element.Kind.INFERNO,
			"damage": 55, "range": 3, "bite_heal": 1, "cooldown": 12.0,
		}),
		Ability.make({
			"id": "dragon_ecailles", "display_name": "Écailles de magma",
			"description": "Ses écailles durcissent : elles encaissent un coup et brûlent qui le touche, puis éclatent en éclats de lave.",
			"kind": Ability.Kind.MAGMA_SCALES, "element": Element.Kind.INFERNO,
			"damage": 1, "duration": 4.0, "radius": 3.0, "shard_count": 8, "shard_damage": 20,
			"burn_dps": 10, "cooldown": 14.0,
		}),
	]
	c.escape = Ability.make({
		"id": "dragon_ailes", "display_name": "Battement d'ailes",
		"description": "Il déploie ses ailes : ce qui l'entoure est repoussé et prend feu, et lui recule d'un bond.",
		"kind": Ability.Kind.WINGBEAT, "element": Element.Kind.INFERNO,
		"damage": 15, "radius": 2.0, "blow_cells": 2, "range": 2, "burn_dps": 10, "duration": 3.0,
		"cooldown": 11.0,
	})
	c.ultimate = Ability.make({
		"id": "dragon_ombre", "display_name": "L'Ombre du Dragon",
		"description": "L'ombre géante d'un dragon traverse l'écran : chaque ennemi prend feu, puis explose en colonne de flammes.",
		"kind": Ability.Kind.DRAGON_SHADOW, "element": Element.Kind.INFERNO,
		"damage": 45, "radius": 10.0, "burn_dps": 12, "duration": 4.0, "ground_fire": 4.0,
		"cooldown": 1.0, "is_ultimate": true,
	})
	return c


static func croupier() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = CROUPIER
	c.display_name = "Croupier des Enfers"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.LUCK
	c.description = "Un démon joueur en costume. Cartes, dés, pièce et roulette : chaque sort est un pari, et il gagne toujours quelque chose."
	c.power_level = 3
	c.base_health = 4
	c.move_speed = 5.0
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "croupier_carte", "display_name": "Carte tranchante",
		"description": "Une carte file en tournoyant et tranche.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.LUCK,
		"projectile_visual": "carte_tranchante",
		"damage": 22, "range": 7, "cooldown": 0.6, "projectile_speed": 1.3,
	})
	c.abilities = [
		Ability.make({
			"id": "croupier_des", "display_name": "Dés pipés",
			"description": "Deux dés roulent dans le couloir : leur total fixe les dégâts, et un double sonne ce qu'ils touchent.",
			"kind": Ability.Kind.DICE, "element": Element.Kind.LUCK,
			"damage": 6, "range": 6, "stun_seconds": 1.5, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "croupier_piege", "display_name": "Carte piège",
			"description": "Une carte face cachée posée sous lui. Le premier ennemi qui passe la retourne : As de feu, Dame de glace ou Roi de foudre.",
			"kind": Ability.Kind.TRAP_CARD, "element": Element.Kind.LUCK,
			"damage": 40, "duration": 12.0, "trap_count": 2, "burn_dps": 10, "stun_seconds": 2.0,
			"cooldown": 8.0,
		}),
		Ability.make({
			"id": "croupier_piece", "display_name": "Pile ou face",
			"description": "Une pièce d'or tourne. Face : intouchable et soigné. Pile : ses trois prochaines cartes frappent double.",
			"kind": Ability.Kind.COIN, "element": Element.Kind.LUCK,
			"duration": 2.0, "coin_heal": 1, "doubled_hits": 3, "cooldown": 14.0,
		}),
	]
	c.escape = Ability.make({
		"id": "croupier_passe", "display_name": "Tour de passe-passe",
		"description": "Il disparaît dans une gerbe de cartes et reparaît plus loin ; une carte reste et attire les ennemis.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.LUCK,
		"range": 4, "decoy_seconds": 2.0, "cooldown": 11.0,
	})
	c.ultimate = Ability.make({
		"id": "croupier_roulette", "display_name": "La Roulette infernale",
		"description": "Une roulette géante tourne, la bille tombe. Rouge : tout brûle. Noir : tout se fige. Zéro : le jackpot foudroie tout.",
		"kind": Ability.Kind.ROULETTE, "element": Element.Kind.LUCK,
		"damage": 120, "radius": 10.0, "burn_dps": 15, "duration": 4.0, "stun_seconds": 3.0,
		"black_damage": 30, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


static func avide() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = AVIDE
	c.display_name = "L'Avide"
	c.category = CATEGORY_DEMON
	c.element = Element.Kind.HUNGER
	c.description = "Un démon pur sang à la gueule fendant le ventre. Chaque proie le fait grandir ; il peut tout recracher d'un coup."
	c.power_level = 3
	c.base_health = 5
	c.move_speed = 4.5
	c.ultimate_required_kills = 6
	c.attack = Ability.make({
		"id": "avide_langue", "display_name": "Langue-fouet",
		"description": "Une langue noire claque en ligne droite et transperce tout ce qu'elle traverse.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.HUNGER,
		"projectile_visual": "langue_fouet", "pierce_line": true,
		"damage": 24, "range": 5, "cooldown": 0.7, "projectile_speed": 1.6,
	})
	c.abilities = [
		Ability.make({
			"id": "avide_gouffre", "display_name": "Gouffre béant",
			"description": "Une gueule s'ouvre dans le sol sous l'ennemi le plus proche, aspire ce qui l'entoure, puis se referme.",
			"kind": Ability.Kind.GULF, "element": Element.Kind.HUNGER,
			"damage": 45, "range": 5, "radius": 3.0, "duration": 2.0, "cooldown": 11.0,
		}),
		Ability.make({
			"id": "avide_devorer", "display_name": "Dévorer",
			"description": "Il saisit l'ennemi le plus proche et l'avale : un ennemi blessé meurt d'un coup, et le nourrit.",
			"kind": Ability.Kind.DEVOUR, "element": Element.Kind.HUNGER,
			"damage": 60, "range": 2, "execute_below": 0.35, "bite_heal": 1, "cooldown": 12.0,
		}),
		Ability.make({
			"id": "avide_regurgitation", "display_name": "Régurgitation",
			"description": "Il recrache toutes ses bouchées en boules de bile qui explosent, et rapetisse.",
			"kind": Ability.Kind.REGURGITATE, "element": Element.Kind.HUNGER,
			"damage": 30, "radius": 1.5, "range": 6, "cooldown": 8.0,
		}),
	]
	c.escape = Ability.make({
		"id": "avide_bond", "display_name": "Bond bestial",
		"description": "Un grand saut en avant ; l'atterrissage fait trembler le sol et sonne ce qui l'entoure.",
		"kind": Ability.Kind.LEAP, "element": Element.Kind.HUNGER,
		"range": 3, "radius": 1.5, "stun_seconds": 1.0, "cooldown": 11.0,
	})
	c.ultimate = Ability.make({
		"id": "avide_festin", "display_name": "Le Festin",
		"description": "Il devient gigantesque, et la gueule de son ventre avale les ennemis proches, un à un.",
		"kind": Ability.Kind.FEAST, "element": Element.Kind.HUNGER,
		"damage": 80, "radius": 6.0, "duration": 6.0, "bite_heal": 1, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Mage de l'Air : contrôle, souffle et esquive. --------------------------------

static func air() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = AIR
	c.display_name = "Mage de l'Air"
	c.element = Element.Kind.AIR
	c.description = "Repousse, ralentit et se protège. Il gagne les combats qu'il refuse de livrer."
	c.power_level = 3
	c.base_health = 4
	c.move_speed = 4.9
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "air_blade", "display_name": "Lame de vent",
		"description": "Une lame d'air comprimé, la plus longue portée du royaume.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.AIR,
		# La plus longue portée, les dégâts les plus faibles : à 15 dégâts et
		# 5,2 de vitesse, l'Air dominait strictement l'Eau sur trois axes.
		"damage": 12, "range": 12, "cooldown": 0.42,
	})
	c.abilities = [
		# TORNADE — elle AVANCE, et elle EMPORTE.
		#
		# C'était la QUATRIÈME zone immobile du jeu, après le brasier du Feu, le
		# cercle glacé de l'Eau et le champ de la Foudre. Une tornade qui ne
		# bouge pas n'est pas une tornade ; et sa description — « malmène tout
		# ce qu'elle touche » — ne disait rien de ce qu'elle faisait.
		#
		# Elle remonte maintenant le couloir toute seule sur sept cases, et ce
		# qu'elle attrape VOYAGE avec elle : happé, blessé chaque seconde, puis
		# lâché là où elle meurt — loin, et en tas avec les autres.
		#
		# C'est le pilier de l'Air : le DÉPLACEMENT. Rien d'autre dans le jeu ne
		# fait parcourir des cases à une créature — le trait de l'élément la
		# pousse de deux cases, une fois. Et ça donne enfin corps à la fiche du
		# personnage : « il gagne les combats qu'il refuse de livrer ».
		#
		# Ses dégâts sont faibles POUR CETTE RAISON : c'est un sort de position.
		Ability.make({
			"id": "air_tornado", "display_name": "Tornade",
			"description": "Elle remonte le couloir et emporte ce qu'elle attrape.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.AIR,
			"damage": 10, "radius": 1.4, "duration": 4.0, "cooldown": 10.0,
			"range": 7, "zone_travel": 3.0, "zone_carries": true,
			"zone_style": "tornade",
		}),
		# GRAND SOUFFLE — il projette, et le MUR fait le reste.
		#
		# Il s'appelait « Bourrasque », comme le TRAIT élémentaire de l'Air : le
		# joueur lisait le même mot à deux endroits pour deux choses
		# différentes. Et il annonçait « balaie le couloir » en ne balayant
		# rien — un cercle de dégâts de plus.
		#
		# Tout ce qui entoure le mage part maintenant de quatre cases. Et ce qui
		# PERCUTE UNE PAROI avant d'avoir fini sa course encaisse le choc : le
		# labyrinthe devient l'arme. Souffler dans un couloir ouvert déplace,
		# souffler contre un cul-de-sac tue — le même bouton donne deux
		# résultats selon l'endroit où l'on se tient.
		#
		# Il complète la Tornade au lieu de la doubler : elle EMMÈNE (linéaire,
		# longue, elle range les poursuivants ailleurs), il ÉCARTE (radial,
		# instantané, il dégage un corps-à-corps). L'un se prépare, l'autre se
		# dégaine.
		Ability.make({
			"id": "air_gust", "display_name": "Grand souffle",
			"description": "Il projette tout autour de lui. Ce qui heurte un mur le paie.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.AIR,
			"damage": 18, "radius": 3.0, "cooldown": 7.0,
			"blow_cells": 4, "slam_damage": 14,
		}),
		Ability.make({
			"id": "air_veil", "display_name": "Voile d'air",
			"description": "Une bulle de vent qui dévie les coups.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.AIR,
			"damage": 38, "duration": 7.0, "cooldown": 11.0,
		}),
	]
	c.escape = Ability.make({
		"id": "air_gale", "display_name": "Rafale",
		"description": "Une bourrasque l'emporte hors de portée.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.AIR,
		"range": 7, "cooldown": 6.5,
	})
	c.ultimate = Ability.make({
		"id": "air_cyclone", "display_name": "Cyclone",
		"description": "Trois colonnes de vent et de foudre se lèvent et partent chasser. Elles vont droit sur les poursuivants, haies comprises, deux minutes durant.",
		# CE N'ÉTAIT QU'UNE EXPLOSION DE PLUS. 115 dégâts sur 6,5 cases : le même
		# geste que son Grand souffle en plus gros — rien qui casse une règle,
		# donc rien qui ressemble à un ultime.
		#
		# ⚠️ Et il n'ACCOMPAGNE PAS le mage, essayé et jeté : un phénomène qui le
		# suit, si lentement soit-il, reste le nuage d'orage du mage de la Foudre
		# sous un autre dessin. Ces colonnes-là sont AUTONOMES. Elles vont droit
		# sur les poursuivants pendant que le mage court aux gemmes — c'est le
		# même contrat que l'Invocateur, mais sans créature à nourrir.
		#
		# TROIS, et c'est le nombre qui fait le sort : une seule colonne se
		# contourne, trois quadrillent. Elles volent, donc elles coupent à
		# travers les haies pendant que leurs proies font le tour — la seule
		# chose du kit de l'Air qui traverse un mur, et elle se voit de loin.
		#
		# 18 dégâts toutes les 1,5 s chacune, deux minutes : énorme en cumul,
		# faible à l'instant. Elles n'exécutent personne, elles usent tout ce
		# qui traîne dans le labyrinthe.
		"kind": Ability.Kind.SUMMON, "element": Element.Kind.AIR,
		"summon_id": "cyclone", "summon_count": 3,
		"duration": 120.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Invocateur : il ne se bat pas, il DÉLÈGUE. ----------------------------------
#
# Son fantasme : poser ses créatures et courir aux gemmes pendant qu'elles
# chassent. Ses chiffres personnels sont donc médiocres — attaque faible,
# vitesse moyenne — et toute sa puissance est dans ses bêtes : 2 minutes de
# chasse chacune, plafonnées à quatre en vie (CombatSystem.MAX_SUMMONS).
# L'ultime n'est pas une explosion : c'est le dragon, qui VOLE par-dessus les
# haies droit sur sa proie.

static func invocateur() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = INVOCATEUR
	c.display_name = "Invocateur"
	c.element = Element.Kind.SHADOW
	c.description = "Ne combat pas : il invoque. Ses créatures chassent 2 minutes pendant qu'il court aux gemmes."
	c.power_level = 3
	c.base_health = 3
	c.move_speed = 4.9
	c.ultimate_required_kills = 6
	c.attack = Ability.make({
		"id": "invoc_bolt", "display_name": "Trait occulte",
		"description": "Une aiguille d'énergie violette, faible mais rapide.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SHADOW,
		"damage": 12, "range": 9, "cooldown": 0.5,
		"projectile_visual": "aiguille_occulte",
	})
	c.abilities = [
		Ability.make({
			"id": "invoc_imps", "display_name": "Diablotins",
			"description": "Deux diablotins surgissent et pourchassent l'ennemi le plus proche.",
			"kind": Ability.Kind.SUMMON, "element": Element.Kind.SHADOW,
			"summon_id": "imp", "summon_count": 2, "duration": 30.0,
			"cooldown": 18.0, "mana_cost": 3,
		}),
		Ability.make({
			"id": "invoc_gargoyle", "display_name": "Gargouille",
			"description": "Une gargouille de pierre, lente mais qui frappe deux fois plus fort.",
			"kind": Ability.Kind.SUMMON, "element": Element.Kind.SHADOW,
			"summon_id": "gargouille", "summon_count": 1, "duration": 40.0,
			"cooldown": 22.0, "mana_cost": 3,
		}),
		Ability.make({
			"id": "invoc_circle", "display_name": "Cercle d'invocation",
			"description": "Un cercle gravé au sol qui ronge quiconque le traverse.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.SHADOW,
			"zone_style": "cercle_peint",
			"damage": 10, "radius": 1.8, "duration": 6.0, "cooldown": 10.0, "mana_cost": 3,
		}),
	]
	c.escape = Ability.make({
		"id": "invoc_step", "display_name": "Pas du néant",
		"description": "Le mage s'efface et reparaît quelques cases plus loin.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.SHADOW,
		"range": 4, "cooldown": 8.0,
	})
	c.ultimate = Ability.make({
		"id": "invoc_dragon", "display_name": "Dragon ancien",
		"description": "Le dragon répond à l'appel : il vole par-dessus les haies, droit sur ses proies.",
		"kind": Ability.Kind.SUMMON, "element": Element.Kind.SHADOW,
		"summon_id": "dragon", "summon_count": 1, "duration": 120.0,
		"cooldown": 1.0, "is_ultimate": true,
	})
	return c


# --- Sorcier Suprême : les quatre éléments, et un ultime hors norme. --------------

static func supreme() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = SUPREME
	c.display_name = "Sorcier Suprême"
	c.element = Element.Kind.SUPREME
	c.description = "Maître des quatre éléments. Ses sorts les combinent — mais son ultime se mérite."
	c.power_level = 5
	c.base_health = 4
	c.move_speed = 4.9
	## Huit kills et non cinq : son ultime efface un stage entier, il doit se payer.
	c.ultimate_required_kills = 8
	c.attack = Ability.make({
		"id": "supreme_bolt", "display_name": "Trait élémentaire",
		"description": "Un trait qui change d'élément à chaque tir.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SUPREME,
		"projectile_visual": "trait_prisme",
		# Les dégâts les plus lourds, mais une portée courte et le pas le plus
		# lent des mages agiles : sa puissance se paie en prise de risque.
		"damage": 20, "range": 8, "cooldown": 0.45,
	})
	c.abilities = [
		Ability.make({
			"id": "supreme_convergence", "display_name": "Convergence élémentaire",
			"description": "Feu, eau, terre et air se fondent en un noyau qui explose à l'impact.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SUPREME,
			# Le grand sort du mage : lourd, lisible et puissant, mais il ne prend
			# pas la place du Prisme des quatre, son ultime à 180 dégâts.
			"damage": 56, "radius": 2.8, "range": 8, "cooldown": 11.0,
			# LENT, et deux fois plutôt qu'une. Le sort se CHARGE devant le mage
			# (7 images à 8 img/s) avant de partir, et la durée totale doit tenir
			# les deux temps : à 0,4 il ne restait qu'un tiers de seconde de vol,
			# la comète traversait le couloir d'un trait. À 0,22, la charge tient
			# ses huit dixièmes et le projectile met encore une seconde pleine à
			# franchir huit cases — c'est le coup le plus lourd du Suprême, il a
			# le droit de se voir venir.
			"projectile_scale": 2.6, "projectile_speed": 0.22,
			"projectile_visual": "convergence_peinte", "shockwave": true,
		}),
		Ability.make({
			# LES QUATRE SCEAUX remplacent la Coulée de magma (2026-08-26).
			#
			# Le magma était déclaré `Element.Kind.FIRE` et faisait 14 dégâts/s
			# sur 2,2 cases : c'était le « Sol embrasé » du Mage du Feu à un nom
			# près. Il ne combinait rien, et rien n'y disait les quatre éléments —
			# alors que c'est toute l'identité du Suprême.
			#
			# Ici il pose QUATRE zones d'un coup, une par point cardinal, chacune
			# portant le trait de son élément. Aucun autre mage n'a plus d'UNE
			# zone : c'est le seul sort de contrôle de terrain qui lui appartienne
			# en propre. Les dégâts par sceau sont donc modestes — sa force est
			# de tenir quatre couloirs, pas d'en brûler un.
			"id": "supreme_seals", "display_name": "Les Quatre Sceaux",
			"description": "Quatre sceaux se gravent autour de lui : le feu brûle, l'eau ralentit, la terre arrête, l'air balaie.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.SUPREME,
			# SOIXANTE SECONDES de tenue. C'est le sort le plus long du jeu après
			# les invocations, et ce n'est pas un sort de combat : c'est un sort
			# de TERRAIN. On pose ses sceaux sur un carrefour et on va chercher
			# ses gemmes en sachant que le retour est gardé.
			#
			# ⚠️ La recharge est de 12 s : à ce rythme CINQ jeux de sceaux se
			# chevauchent, soit vingt zones. C'est voulu tant que les dégâts
			# restent bas — 9/s, la moitié d'une zone ordinaire — mais si le
			# labyrinthe finit tapissé, c'est la RECHARGE qu'il faut monter, pas
			# la durée : c'est elle qui décide combien de jeux coexistent.
			# RAYON 1,15 et non 1,5 : à 1,5 les sceaux voisins de la couronne se
			# touchaient (2,83 case d'écart pour 3 cases de diamètre) et les
			# quatre se lisaient comme une seule flaque. À 1,15 il reste six
			# dixièmes de case entre eux.
			"damage": 9, "radius": 1.15, "duration": 60.0, "cooldown": 12.0,
			# Deux cases : assez pour tenir les entrées d'un carrefour, pas assez
			# pour couvrir un couloir entier depuis l'abri.
			"seal_ring": 2,
			# Le sceau est dessiné en GRIS : c'est `ZoneEffect` qui le teint à
			# l'élément de chaque sceau. Un seul dessin pour quatre zones — sans
			# quoi les quatre auraient eu quatre diamètres différents.
			"zone_style": "sceau",
		}),
		Ability.make({
			# RENAISSANCE DEVIENT UNE EXALTATION (2026-08-28).
			#
			# Elle ne faisait que rendre 2 points de vie toutes les 16 s. C'est
			# le sort le plus terne du jeu : on l'appuie sans regarder, rien ne
			# change à l'écran, et le mot « renaissance » ne raconte rien d'un
			# pansement. Elle SOULÈVE maintenant le mage — il renaît plus fort,
			# et ça se voit sur son corps pendant trente secondes.
			#
			# Le soin reste, et monte à 3 : c'est ce qui la relie encore à son
			# nom, et ce qui justifie de la garder quand on est au complet.
			#
			# ⚠️ RECHARGE 38 s ET NON 16, et c'est la contrepartie de la durée.
			# À 16 s de recharge pour 30 s d'effet, l'exaltation ne s'arrête
			# JAMAIS : ce n'est plus un sort, c'est une statistique de base
			# qu'on aurait pu écrire dans `c.attack`. À 38 s, il reste huit
			# secondes nues — assez pour que la relancer soit une décision.
			"id": "supreme_bloom", "display_name": "Renaissance",
			"description": "Il renaît des quatre éléments : +8 à chaque coup et 2 coups absorbés pendant 30 s, et ses blessures se referment.",
			"kind": Ability.Kind.HEAL, "element": Element.Kind.SUPREME,
			"damage": 3, "duration": 0.0, "cooldown": 38.0,
			# +8 et non +10 : l'ultime de l'Eau donne +10, mais il se MÉRITE en
			# huit kills. Celle-ci est un sort ordinaire, disponible d'entrée.
			# Sur le trait élémentaire à 20, +8 se sent tout de suite (+40 %)
			# sans transformer la Convergence à 56 en autre chose.
			"empower_bonus": 8, "empower_duration": 30.0,
			# DEUX POINTS ABSORBÉS, soit deux contacts gratuits. Le Suprême a
			# 4 points de vie : c'est la moitié de sa chair en plus, ce qui est
			# beaucoup — et c'est pour ça que le chiffre reste à 2. La coque de
			# l'Eau en absorbe 45, mais c'est LE sort de ce mage, à deux charges
			# et 5 s de recharge ; ici la défense n'est qu'une moitié du sort.
			"empower_shield": 2,
		}),
	]
	c.escape = Ability.make({
		"id": "supreme_shift", "display_name": "Glissement",
		"description": "Les quatre éléments le déplacent d'un souffle.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.SUPREME,
		"range": 6, "cooldown": 6.5,
	})
	c.ultimate = Ability.make({
		# LE JUGEMENT DES QUATRE remplace le Prisme (2026-08-28).
		#
		# Le Prisme était un BLAST de 180 sur 7 cases : un gros chiffre, et rien
		# à regarder. Ici le ciel s'ouvre — des météores faites des quatre
		# éléments tombent SUR les ennemis, et le sol tremble sous elles.
		"id": "supreme_judgement", "display_name": "Jugement des quatre",
		"description": "Le ciel s'ouvre : des météores des quatre éléments tombent sur chaque poursuivant, et la terre tremble.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.SUPREME,
		# LE PLUS PUISSANT DES HUIT ULTIMES, et il doit se voir dans les chiffres.
		#
		# 150 de souffle plus douze météores à 75 font 1050 au total, contre 802
		# pour l'éruption du Mage du Feu (130 + 14 x 48) — le deuxième plus
		# lourd. Trente pour cent au-dessus, et c'est le rapport qu'il faut : le
		# Suprême paie son ultime HUIT kills quand les autres en paient cinq, et
		# il n'a ni la survie de l'Eau ni la vitesse de la Foudre pour les
		# obtenir. Un ultime qui coûte 60 % plus cher et frappe pareil ne serait
		# pas un ultime de maître des quatre éléments.
		"damage": 150, "radius": 6.0, "cooldown": 1.0, "is_ultimate": true,
		"shockwave": true, "pierces_walls": true, "flames": 1.2,
		# LA PLUIE VISE. Le total est fixe : douze météores réparties à tour de
		# rôle sur les poursuivants vivants. Six ennemis en prennent deux chacun ;
		# les deux derniers en prennent six chacun. C'est ce qui en fait un
		# jugement et non un feu d'artifice — plus il en reste peu, plus ça tombe.
		"rain_hunts": true,
		"rain_count": 12, "rain_damage": 75, "rain_radius": 1.6,
		# 4,5 s pour douze météores, soit une toutes les 0,37 s : le temps de voir
		# chacune partir, tomber et frapper. À 2,2 elles se suivaient de si près
		# que le « une par une » ne se lisait plus.
		# 1,1 s de chute et non 0,85 : elle part maintenant de vingt-deux cases,
		# hors de l'écran. Au temps d'avant, elle traversait le champ visible en
		# un cinquième de seconde — une rayure, pas une météore.
		# 1,45 s d'attente : les seize images de `jugement_incantation` à 11
		# img/s. Le ciel ne répond qu'une fois le geste achevé.
		"rain_delay": 1.45,
		"rain_duration": 4.5, "rain_fall": 1.1,
		# LE SÉISME qui suit. Il ne fait presque pas de dégâts : son rôle est de
		# faire trembler l'écran et le sol pendant que les météores tombent, pour
		# qu'on sente le poids de ce qui arrive.
		# UNE SECONDE, remise à neuf à chaque impact. Le séisme n'est plus une
		# nappe posée au lancement : il repart à chaque météore qui touche, donc
		# il n'a pas besoin de couvrir toute la pluie — il la suit.
		"quake_duration": 1.0, "quake_tremor": 6, "quake_interval": 0.5,
		"quake_radius": 7.0,
	})
	return c


# --- Héros d'essai : il ne sert qu'à régler le mouvement et le coup. --------------------

static func test_hero() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = TEST
	c.display_name = "Héros d'essai"
	c.category = CATEGORY_TEST
	c.element = Element.Kind.STEEL
	c.description = "Pour essayer la course et le coup d'épée. Il ne part qu'en DÉMO."
	c.base_health = 5
	c.move_speed = 5.1
	c.ultimate_required_kills = 99
	c.attack = Ability.make({
		"id": "test_slash", "display_name": "Coup d'épée",
		"description": "Un coup d'épée devant lui.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.STEEL,
		"damage": 30, "radius": 2.0, "arc": 150.0, "cooldown": 0.4,
	})
	return c


# --- Aël, le héros principal ---------------------------------------------------------
#
# Sa première forme, l'Apprenti. Les chiffres sont ceux de départ du plan : ils seront réglés
# avec ses niveaux. Il reprend l'animation du Héros d'essai (`motion` dans son frames.json).
# ⚠️ Le Prisme n'a pas encore de trait : ce qui le distingue, ce sont ses évolutions.

static func ael() -> CharacterStats:
	var c := CharacterStats.new()
	c.id = AEL
	c.display_name = "Aël"
	c.category = CATEGORY_HEROS
	c.element = Element.Kind.PRISM
	c.description = "L'Enfant sans élément. Il absorbe la lumière des gemmes pour évoluer."
	c.power_level = 3
	c.base_health = 3
	c.move_speed = 5.0
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "ael_slash", "display_name": "Coup d'épée",
		"description": "Un coup d'épée en arc devant lui.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.PRISM,
		"damage": 26, "radius": 2.2, "range": 2, "arc": 150.0, "cooldown": 0.45,
	})
	# UN ÉPÉISTE, PAS ENCORE UN MAGE. Chaque sort est un geste d'épée, lisible d'un coup d'œil, et
	# aucun n'emprunte le visuel d'un autre : la Ruée était une vague, elle se lisait comme celle
	# de l'Eau. Seul l'Extra laisse voir la gemme s'éveiller, ce qu'il deviendra.
	c.abilities = [
		Ability.make({
			"id": "ael_wind_cut", "display_name": "Tranche-vent",
			"description": "Un coup d'épée si vif qu'il lance une lame d'air, qui file dans le couloir.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.PRISM,
			"damage": 24, "range": 7, "cooldown": 3.0, "projectile_visual": "tranche_vent",
		}),
		Ability.make({
			"id": "ael_rush", "display_name": "Ruée",
			"description": "Il fonce l'épée en avant et bouscule tout ce qu'il traverse.",
			"kind": Ability.Kind.BLINK, "element": Element.Kind.PRISM,
			"range": 4, "cooldown": 6.0, "trail_damage": 28, "blow_cells": 1,
		}),
		Ability.make({
			"id": "ael_parry", "display_name": "Parade",
			"description": "Il plante ses pieds et lève l'épée : intouchable un instant, il rend chaque coup paré.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.PRISM,
			"immune": true, "duration": 1.5, "cooldown": 9.0, "reflect_damage": 30,
		}),
	]
	c.escape = Ability.make({
		"id": "ael_roll", "display_name": "Roulade",
		"description": "Une roulade de trois cases, pour sortir d'un mauvais pas.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.PRISM,
		"range": 3, "cooldown": 5.0,
	})
	c.ultimate = Ability.make({
		"id": "ael_great_slash", "display_name": "Éveil de l'éclat",
		"description": "La gemme s'éveille un instant : il tourne sur lui-même, et sa lame trace un cercle immense.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.PRISM,
		"damage": 70, "radius": 3.5,
	})
	return c
