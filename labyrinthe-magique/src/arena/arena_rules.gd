class_name ArenaRules
extends RefCounted

## Les règles de l'ARÈNE (2026-11-09) : deux équipes de héros qui se battent SEULES.
##
## Le joueur ne pilote personne. Il choisit le mode, le format, ses héros et leur posture,
## puis il regarde. Tout ce qui décide vit ici et dans `ArenaMatch`, en RefCounted, pour que
## `tests/test_arena.gd` joue des matchs entiers sans affichage, avec le vrai `CombatSystem`
## (règle d'architecture n° 1).

## Gemme-Cœur : tenir la gemme du centre, seul, remplit la jauge de son équipe.
## Duel à mort : pas de retour, la dernière équipe debout gagne.
enum Mode { HEART, DEATHMATCH }
## Ce que fait un héros quand personne ne le pilote.
## ASSAULT fonce sur l'adversaire le plus proche, GUARD tient la gemme (ou couvre ses alliés en
## duel), HUNTER vise le plus blessé.
enum Posture { ASSAULT, GUARD, HUNTER }

const TEAM_A := 0
const TEAM_B := 1
const FORMATS := [1, 2, 3]

## UN PV DE HÉROS VAUT CE NOMBRE DE POINTS EN ARÈNE.
##
## En campagne, un héros a 3 à 6 PV parce qu'un ennemi lui en retire UN par coup, alors que ses
## sorts infligent 20 à 200 dégâts à des créatures de 100 à 300 PV. Face à un autre héros, ses
## sorts frapperaient donc une vie de 3 : un seul coup tuerait. L'arène met les héros à l'échelle
## des créatures. Réglé par `test_arena.gd -- --durees` (voir le rapport dans CLAUDE.md).
const HP_PER_PV := 400
## LA VIGUEUR D'ARÈNE : un multiplicateur de vie PROPRE À L'ARÈNE, par personnage. Les fiches de la
## campagne sont réglées contre des meutes de créatures, pas contre un autre héros : un sort de zone
## qui nettoie un couloir ne vaut pas grand-chose en duel, un sort à cible unique vaut double.
## Plutôt que de toucher aux fiches (et à tout l'équilibrage de la campagne), l'arène corrige ici.
## Réglé sur `test_arena.gd -- --matrice` (voir CLAUDE.md). Absent = 1.
const VIGOR := {
	"acier": 0.74, "ael": 3.93, "ael_ascendant": 1.25, "ael_dragon": 1.38, "ael_eveille": 1.70,
	"ael_prisme": 0.40, "air": 0.95, "avide": 1.94, "braise": 0.78, "cherubin": 1.96,
	"chrono": 1.89, "ciel": 2.13, "croupier": 0.90, "demon": 1.51, "discorde": 1.11,
	"dragon": 0.60, "earth": 0.75, "ecarlate": 1.54, "etoiles": 1.12, "fire": 1.82,
	"geolier": 0.98, "invocateur": 0.71, "lumiere": 0.59, "mort": 1.03, "peste": 1.94,
	"shadow": 1.10, "supreme": 0.40, "thunder": 1.15, "water": 0.40,
}

## LES BOUCLIERS DU JEU SONT COMPTÉS EN COUPS, pas en PV : 45 pour la Bulle de l'Eau, 1 pour les Ailes
## de la Lumière ou les Écailles du Dragon — en campagne, une créature ne retire qu'un PV par coup.
## En arène, un coup absorbé vaut `SHIELD_PER_HIT` points, et un bouclier n'en tient jamais plus que
## `SHIELD_CAP`. Mesuré le 2026-11-09 : multipliés par `HP_PER_PV`, la Bulle tenait 18 000 points et
## l'Eau gagnait 96 % de ses duels, même avec 44 % de sa vie.
const SHIELD_PER_HIT := 40
const SHIELD_CAP := 400
## Et jamais plus que cette part de sa vie : à vie réduite par la vigueur, une Bulle fixe de 400 points
## revenant toutes les cinq secondes doublait presque celle de l'Eau (75 % de victoires au plancher).
const SHIELD_SHARE := 0.25
## L'Égide de la Terre rend intouchable trente secondes : un duel entier. En arène, une immunité ne
## dure jamais plus de `IMMUNE_CAP` secondes.
const IMMUNE_CAP := 3.0
## Un ÉTOURDISSEMENT ne dure jamais plus de `STUN_CAP` secondes en arène. Les Chaînes d'âme du Geôlier
## sonnent six secondes : contre une meute c'est un répit, contre un héros seul c'est un duel joué
## d'avance (le Geôlier en gagnait 88 % avec la moitié de sa vie, mesuré le 2026-11-09).
const STUN_CAP := 1.5
## Un PV soigné vaut la moitié d'un PV d'arène : soigné à plein, le Sorcier Suprême et l'Eau
## reprenaient un PV entier à chaque Extra.
const HEAL_PER_PV := 200

## Les soins et les boucliers du jeu sont écrits en PV (1 ou 2). Sous ce seuil, un soin est
## compris comme des PV et mis à l'échelle ; au-dessus, il est déjà en points (le Sablier rend
## ce qui a été perdu, déjà mesuré en points).
const SMALL_HEAL := 3

## Gemme-Cœur.
const HEART_GOAL := 100.0
## Points par seconde quand une seule équipe est sur la gemme.
const HEART_RATE := 1.5
## Points d'un adversaire abattu.
const KILL_SCORE := 10.0
## Rayon de la gemme, en distance de chemin depuis sa case.
const HEART_RADIUS := 2
const RESPAWN_DELAY := 5.0
## Intouchable en sortant du socle : sans ça, on meurt dans la seconde où l'on revient.
const RESPAWN_SHIELD := 2.0
const HEART_TIME := 180.0
const DEATHMATCH_TIME := 120.0
## L'Extra se charge AUSSI avec le temps : un héros ne tue que deux ou trois fois par match,
## et l'Extra de la campagne en demande quatre à huit. Une demi-charge toutes les X secondes.
const ULTIMATE_TICK := 9.0

## L'ÉVEIL EN ARÈNE : `Awakening.KILLS` crans, comme en campagne, mais ils viennent surtout du temps —
## un cran toutes les `AWAKEN_TICK` secondes, et `AWAKEN_KILL_STEPS` par adversaire abattu. Prêt en
## 24 s sans rien abattre : un duel en dure une trentaine, l'Éveil en est le dénouement.
const AWAKEN_TICK := 4.0
const AWAKEN_KILL_STEPS := 2

# --- Le combat bouge (2026-11-10, demande du joueur : « plus de mobilité, esquiver ») -----------

## L'attaque de base attend ça DE PLUS qu'en campagne : de 0,22 à 0,8 s, elle partait en rafale.
const ATTACK_EXTRA := 0.3
## Un tir ne suit plus sa cible : sortie de sa ligne, elle l'esquive (`ArenaMatch._misses`). L'attaque
## de base pardonne une case d'écart, un sort aucune : c'est sur les sorts que l'esquive paie.
const ATTACK_TOLERANCE := 0
## Le pas de côté : poussé de `DODGE_BOOST` pendant `DODGE_TIME`, puis `DODGE_COOLDOWN` d'attente.
const DODGE_TIME := 0.3
const DODGE_BOOST := 1.7
const DODGE_COOLDOWN := 1.6
## Un tir plus rapide que ça arrive avant qu'on ait pu le voir partir.
const DODGE_REACTION := 0.1
## La chance de le voir venir et de bouger : un sort se lit, une attaque de base beaucoup moins.
const DODGE_SPELL := 0.7
const DODGE_ATTACK := 0.3
## Tenir sa distance : un tireur qui n'est pas au contact change de case toutes les
## `STRAFE_MIN` à `STRAFE_MAX` secondes, dans sa bande de portée, plutôt que de rester planté.
const STRAFE_MIN := 0.7
const STRAFE_MAX := 1.4
## Sous cette portée d'attaque, un héros se bat au contact ; au-dessus, c'est un tireur.
const MELEE_REACH := 2

# --- La tactique (2026-11-10, deuxième demande) ------------------------------------------------

## Le choix de la cible (`ArenaBrain._choose_focus`) : part de vie, plus ça par case d'écart, moins
## les bonus. Une cible déjà visée par un allié passe devant : l'équipe se concentre.
const FOCUS_PER_CELL := 0.05
const FOCUS_HELD := 0.25
const FOCUS_STICKY := 0.1
const FOCUS_TEAM := 0.2
## Les combos : le plus gros sort attend un contrôle prêt sous `COMBO_WAIT` s, `COMBO_HOLD_MAX` s au
## plus, s'il frappe au moins `COMBO_BIG` fois l'attaque de base.
const COMBO_WAIT := 2.0
const COMBO_HOLD_MAX := 2.5
const COMBO_BIG := 1.3
## L'Extra (`ArenaBrain._ultimate_moment`) : achever sous `ULTIMATE_FINISH` de vie, en duel sous
## `ULTIMATE_DUEL`, en dernier recours sous `ULTIMATE_LAST_STAND` ; jamais gardé plus de `ULTIMATE_PATIENCE` s.
const ULTIMATE_FINISH := 0.45
const ULTIMATE_DUEL := 0.7
const ULTIMATE_LAST_STAND := 0.35
const ULTIMATE_PATIENCE := 6.0

const HEART_CELL := Vector2i(10, 6)

## LE TERRAIN. Symétrique de gauche à droite ET de haut en bas, pour qu'aucun camp ne soit
## avantagé. Des piliers pour se cacher des tirs, des haies au nord et au sud qui coupent les
## couloirs, et quatre bornes autour de la gemme qui en font une petite place à quatre entrées.
const LAYOUT := [
	"#####################",
	"#.........#.........#",
	"#.........#.........#",
	"#...##.........##...#",
	"#...................#",
	"#.......#...#.......#",
	"#...................#",
	"#.......#...#.......#",
	"#...................#",
	"#...##.........##...#",
	"#.........#.........#",
	"#.........#.........#",
	"#####################",
]

## Les socles de départ, du premier héros au troisième.
const SPAWNS := [
	[Vector2i(2, 6), Vector2i(2, 4), Vector2i(2, 8)],
	[Vector2i(18, 6), Vector2i(18, 4), Vector2i(18, 8)],
]

## LES DÉCORS : le Colisée (0, les planches de `tools/build_arena.py`), puis les dix stages.
const COLISEUM := 0
const COLISEUM_TILES := "res://assets/tiles/arena/"


static func decor_name(index: int) -> String:
	if index == COLISEUM:
		return "Le Colisée"
	return str(LevelConfig.STAGE_NAMES[clampi(index, 1, LevelConfig.STAGE_NAMES.size()) - 1])


static func decor_count() -> int:
	return LevelConfig.STAGE_NAMES.size() + 1


const TEAM_COLORS := [Color("#5fb4ff"), Color("#ff6b6b")]
const TEAM_NAMES := ["Bleus", "Rouges"]
const POSTURE_NAMES := ["Assaillant", "Gardien", "Chasseur"]
const POSTURE_HINTS := [
	"fonce sur l'adversaire le plus proche",
	"tient la gemme, ou reste près de ses alliés",
	"vise l'adversaire le plus blessé",
]
const MODE_NAMES := ["Gemme-Cœur", "Duel à mort"]
const MODE_HINTS := [
	"tenir la gemme du centre remplit la jauge ; les héros tombés reviennent",
	"pas de retour : la dernière équipe debout gagne",
]


static func build_grid() -> MazeGrid:
	var rows := LAYOUT.size()
	var cols := str(LAYOUT[0]).length()
	var grid := MazeGrid.new(cols, rows)
	for r in rows:
		var line := str(LAYOUT[r])
		for c in cols:
			grid.set_cell(c, r, MazeGrid.Cell.WALL if line[c] == "#" else MazeGrid.Cell.FLOOR)
	grid.house_center = HEART_CELL
	grid.player_spawn = SPAWNS[TEAM_A][0]
	return grid


static func vigor(menu_id: String) -> float:
	return float(VIGOR.get(menu_id, 1.0))


static func time_limit(mode: Mode) -> float:
	return HEART_TIME if mode == Mode.HEART else DEATHMATCH_TIME


## L'identifiant de COMBAT d'un personnage du menu. Les cartes d'Aël ont chacune le leur
## (`ael_prisme`…), mais en jeu c'est toujours `ael`, à une forme donnée : `CombatSystem` et
## `Player` reconnaissent Aël à son identifiant.
static func fighter_stats(id: String) -> CharacterStats:
	var stats := CharacterCatalog.by_id(id)
	if id in CharacterCatalog.AEL_FORMS:
		stats.id = CharacterCatalog.AEL
	return stats


## Tous ceux qu'on peut aligner : ceux de l'écran de sélection, formes d'Aël comprises.
static func roster_ids() -> Array[String]:
	var out: Array[String] = []
	for stats in CharacterCatalog.roster():
		out.append(stats.id)
	return out
