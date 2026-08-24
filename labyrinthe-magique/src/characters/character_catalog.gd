class_name CharacterCatalog
extends RefCounted

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


static func all() -> Array[CharacterStats]:
	return [fire(), water(), earth(), shadow(), thunder(), air(), invocateur(), supreme()]


static func by_id(id: String) -> CharacterStats:
	for character in all():
		if character.id == id:
			return character
	return shadow()


static func default_id() -> String:
	return SHADOW


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
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "shadow_orb", "display_name": "Orbe d'ombre",
		"description": "Une bille d'ombre qui remonte les couloirs jusqu'à sa cible.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SHADOW,
		"damage": 16, "range": 10, "cooldown": 0.45,
	})
	c.abilities = [
		Ability.make({
			"id": "shadow_rune", "display_name": "Rune",
			"description": "Piège posé au sol : le premier ennemi qui passe dessus explose.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.SHADOW,
			"damage": 18, "radius": 1.2, "duration": 8.0, "cooldown": 8.0,
		}),
		Ability.make({
			"id": "shadow_blink", "display_name": "Translation",
			"description": "Saut instantané de quelques cases dans la direction regardée.",
			"kind": Ability.Kind.BLINK, "element": Element.Kind.SHADOW,
			"range": 4, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "shadow_burst", "display_name": "Explosion d'ombre",
			"description": "Détonation autour du mage, elle repousse et blesse.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.SHADOW,
			"damage": 34, "radius": 2.6, "cooldown": 9.0,
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
		"description": "Le labyrinthe se déchire : tout ce qui est proche est pulvérisé.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.SHADOW,
		"damage": 110, "radius": 6.0, "cooldown": 1.0, "is_ultimate": true,
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
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "fire_bolt", "display_name": "Trait de flamme",
		"description": "Une flèche de feu, rapide et courte.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
		"damage": 19, "range": 8, "cooldown": 0.5,
	})
	c.abilities = [
		Ability.make({
			"id": "fire_ball", "display_name": "Boule de feu",
			"description": "Explose à l'impact et touche tout le couloir.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": 30, "radius": 2.0, "range": 11, "cooldown": 6.0,
		}),
		Ability.make({
			"id": "fire_ground", "display_name": "Sol embrasé",
			"description": "Une nappe de flammes qui brûle quiconque la traverse.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.FIRE,
			"damage": 9, "radius": 2.2, "duration": 5.0, "cooldown": 10.0,
		}),
		Ability.make({
			"id": "fire_aura", "display_name": "Aura ardente",
			"description": "Le mage s'entoure de feu : ce qui le touche se consume.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.FIRE,
			"damage": 12, "radius": 1.6, "duration": 6.0, "cooldown": 12.0,
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
		"description": "Toute la clairière prend feu d'un coup.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.FIRE,
		"damage": 130, "radius": 5.5, "cooldown": 1.0, "is_ultimate": true,
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
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "water_jet", "display_name": "Jet d'eau",
		"description": "Un trait d'eau sous pression, régulier mais à mi-portée.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.WATER,
		# Portée ramenée de 11 à 9 après mesure. À 11, le Mage de l'Eau gagnait
		# 83 % des parties SANS ÊTRE TOUCHÉ UNE SEULE FOIS : il abattait ses
		# poursuivants avant qu'ils n'arrivent, et aucun réglage défensif ne
		# pouvait rien y changer — c'est l'ALLONGE qui le mettait hors d'atteinte.
		# Être le survivant du groupe est son identité ; être intouchable non.
		"damage": 14, "range": 9, "cooldown": 0.4,
	})
	c.abilities = [
		Ability.make({
			"id": "water_wave", "display_name": "Vague",
			"description": "Une lame d'eau qui balaie le couloir devant le mage.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.WATER,
			"damage": 24, "radius": 3.0, "cooldown": 7.0,
		}),
		Ability.make({
			"id": "water_shield", "display_name": "Bouclier d'eau",
			"description": "Une coque liquide qui absorbe les coups avant les points de vie.",
			"kind": Ability.Kind.SHIELD, "element": Element.Kind.WATER,
			"damage": 45, "duration": 8.0, "cooldown": 12.0,
		}),
		Ability.make({
			"id": "water_circle", "display_name": "Cercle glacé",
			"description": "Une flaque gelée : les ennemis qui la traversent s'englueent.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.WATER,
			"damage": 6, "radius": 3.0, "duration": 6.0, "cooldown": 10.0,
		}),
	]
	c.escape = Ability.make({
		"id": "water_current", "display_name": "Courant",
		"description": "Il se liquéfie et file avec le courant.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.WATER,
		"range": 6, "cooldown": 7.0,
	})
	c.ultimate = Ability.make({
		"id": "water_geyser", "display_name": "Geyser",
		"description": "Le sol se fend, l'eau jaillit et le mage se régénère.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.WATER,
		"damage": 95, "radius": 5.0, "cooldown": 1.0, "is_ultimate": true,
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
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "earth_rock", "display_name": "Rocher",
		"description": "Un bloc de pierre lancé à bout de bras. Lent mais lourd.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.EARTH,
		"damage": 23, "range": 6, "cooldown": 0.7,
	})
	c.abilities = [
		Ability.make({
			"id": "earth_spikes", "display_name": "Pics de terre",
			"description": "Des pointes de roche jaillissent du sol autour du mage.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.EARTH,
			"damage": 30, "radius": 2.2, "cooldown": 6.0,
		}),
		Ability.make({
			"id": "earth_wall", "display_name": "Mur de pierre",
			"description": "Ferme le couloir derrière soi. Les poursuivants doivent contourner.",
			"kind": Ability.Kind.WALL, "element": Element.Kind.EARTH,
			"duration": 8.0, "cooldown": 14.0,
		}),
		Ability.make({
			"id": "earth_crystals", "display_name": "Éclats de cristal",
			"description": "Trois éclats partent sur les ennemis les plus proches.",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.EARTH,
			"damage": 14, "range": 10, "cooldown": 8.0,
		}),
	]
	c.escape = Ability.make({
		"id": "earth_burrow", "display_name": "Terrier",
		"description": "Il s'enfonce dans le sol et ressort à couvert.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.EARTH,
		"range": 4, "cooldown": 8.0,
	})
	c.ultimate = Ability.make({
		"id": "earth_quake", "display_name": "Séisme",
		"description": "Le labyrinthe tremble et tout ce qui tient debout tombe.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.EARTH,
		"damage": 120, "radius": 5.0, "cooldown": 1.0, "is_ultimate": true,
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
	c.ultimate_required_kills = 5
	c.attack = Ability.make({
		"id": "thunder_bolt", "display_name": "Éclair",
		"description": "Un trait de foudre, presque instantané. Il porte peu et frappe faible.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.THUNDER,
		# La cadence la plus rapide du jeu : c'est SA signature. Elle se PAIE en
		# dégâts et en portée — mesuré : à 15 dégâts et 10 cases, la Foudre
		# dominait STRICTEMENT les Ténèbres (mêmes PV, même portée, plus rapide
		# ET plus de dégâts) et ne mourait jamais en simulation.
		"damage": 10, "range": 7, "cooldown": 0.32,
	})
	c.abilities = [
		Ability.make({
			"id": "thunder_chain", "display_name": "Chaîne d'éclairs",
			"description": "La foudre saute d'un ennemi à l'autre autour du mage.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.THUNDER,
			"damage": 28, "radius": 3.0, "cooldown": 7.0,
		}),
		Ability.make({
			"id": "thunder_dash", "display_name": "Fulgurance",
			"description": "Le mage devient éclair et reparaît cinq cases plus loin.",
			"kind": Ability.Kind.BLINK, "element": Element.Kind.THUNDER,
			"range": 5, "cooldown": 8.0,
		}),
		Ability.make({
			"id": "thunder_storm", "display_name": "Orage",
			"description": "Un nuage crépitant qui foudroie ce qui passe dessous.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.THUNDER,
			"damage": 11, "radius": 2.5, "duration": 5.0, "cooldown": 11.0,
		}),
	]
	c.escape = Ability.make({
		"id": "thunder_flash", "display_name": "Éclair fuyant",
		"description": "Il devient foudre le temps d'un battement de cils.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.THUNDER,
		"range": 7, "cooldown": 6.0,
	})
	c.ultimate = Ability.make({
		"id": "thunder_judgement", "display_name": "Jugement céleste",
		"description": "Le ciel s'ouvre et la foudre tombe partout à la fois.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.THUNDER,
		"damage": 140, "radius": 5.5, "cooldown": 1.0, "is_ultimate": true,
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
		Ability.make({
			"id": "air_tornado", "display_name": "Tornade",
			"description": "Une colonne d'air qui malmène tout ce qu'elle touche.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.AIR,
			"damage": 13, "radius": 2.4, "duration": 4.5, "cooldown": 8.0,
		}),
		Ability.make({
			"id": "air_gust", "display_name": "Bourrasque",
			"description": "Un souffle qui balaie le couloir autour du mage.",
			"kind": Ability.Kind.BLAST, "element": Element.Kind.AIR,
			"damage": 23, "radius": 3.2, "cooldown": 7.0,
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
		"description": "Le labyrinthe entier est aspiré dans une spirale.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.AIR,
		"damage": 115, "radius": 6.5, "cooldown": 1.0, "is_ultimate": true,
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
	})
	c.abilities = [
		Ability.make({
			"id": "invoc_imps", "display_name": "Diablotins",
			"description": "Deux diablotins surgissent et pourchassent l'ennemi le plus proche.",
			"kind": Ability.Kind.SUMMON, "element": Element.Kind.SHADOW,
			"summon_id": "imp", "summon_count": 2, "duration": 120.0,
			"cooldown": 18.0, "mana_cost": 3,
		}),
		Ability.make({
			"id": "invoc_gargoyle", "display_name": "Gargouille",
			"description": "Une gargouille de pierre, lente mais qui frappe deux fois plus fort.",
			"kind": Ability.Kind.SUMMON, "element": Element.Kind.SHADOW,
			"summon_id": "gargouille", "summon_count": 1, "duration": 120.0,
			"cooldown": 22.0, "mana_cost": 3,
		}),
		Ability.make({
			"id": "invoc_circle", "display_name": "Cercle d'invocation",
			"description": "Un cercle gravé au sol qui ronge quiconque le traverse.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.SHADOW,
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
		# Les dégâts les plus lourds, mais une portée courte et le pas le plus
		# lent des mages agiles : sa puissance se paie en prise de risque.
		"damage": 20, "range": 8, "cooldown": 0.45,
	})
	c.abilities = [
		Ability.make({
			"id": "supreme_steam", "display_name": "Vapeur brûlante",
			"description": "Feu et eau mêlés : une nuée qui aveugle et brûle.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.WATER,
			"damage": 11, "radius": 2.8, "duration": 5.0, "cooldown": 9.0,
		}),
		Ability.make({
			"id": "supreme_magma", "display_name": "Coulée de magma",
			"description": "Feu et terre : la roche fond et coule dans le couloir.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.FIRE,
			"damage": 14, "radius": 2.2, "duration": 6.0, "cooldown": 11.0,
		}),
		Ability.make({
			"id": "supreme_bloom", "display_name": "Renaissance",
			"description": "Eau et terre : la nature repousse et referme les blessures.",
			"kind": Ability.Kind.HEAL, "element": Element.Kind.EARTH,
			"damage": 2, "duration": 0.0, "cooldown": 16.0,
		}),
	]
	c.escape = Ability.make({
		"id": "supreme_shift", "display_name": "Glissement",
		"description": "Les quatre éléments le déplacent d'un souffle.",
		"kind": Ability.Kind.BLINK, "element": Element.Kind.SUPREME,
		"range": 6, "cooldown": 6.5,
	})
	c.ultimate = Ability.make({
		"id": "supreme_prism", "display_name": "Prisme des quatre",
		"description": "Les quatre éléments se rejoignent en un seul trait de lumière.",
		"kind": Ability.Kind.BLAST, "element": Element.Kind.SUPREME,
		"damage": 180, "radius": 7.0, "cooldown": 1.0, "is_ultimate": true,
	})
	return c
