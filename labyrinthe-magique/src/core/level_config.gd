class_name LevelConfig
extends Resource

## Toute la difficulté d'un niveau tient ici. Ajouter un Stage 4 = ajouter une
## fabrique statique en bas de ce fichier, pas une ligne de gameplay.

@export var level_name: String = "Stage"

## Rang du stage (1 à 10) et rang de l'épisode DANS ce stage (1 ou 2).
##
## Un stage n'est plus un niveau mais un CHAPITRE : il faut en boucler les deux
## épisodes avant de passer au suivant. Deux épisodes, et pas trois : le
## labyrinthe est généré à chaque partie, donc le second épisode d'un stage est
## déjà un terrain neuf. Ce qu'il apporte en plus, c'est la montée de tension
## sur un décor devenu familier — au troisième, le décor lasserait avant que la
## tension ne monte.
@export var stage: int = 1
@export var episode: int = 1

## Terrain d'ESSAI : la page démo de la sélection des mages. Tout y est
## débloqué, rien n'y compte — ni progression, ni mort probable. Le joueur y
## apprend ce que fait chaque sort AVANT de s'engager dans la campagne.
@export var is_demo: bool = false

## Faut-il DÉTRUIRE les repaires pour finir ce niveau ?
##
## Réservé au dernier épisode des stages 3 et 9, les deux verrous de la
## campagne. Partout ailleurs les maisons sont indestructibles et la menace est
## sans fin : c'est ce qui donne son prix aux deux niveaux où l'on peut enfin
## couper la source. Ces épisodes-là ne se gagnent pas en courant — il faut
## revenir aux coins, sous le feu, et tenir assez longtemps pour abattre la
## maison.
@export var must_destroy_lairs: bool = false

## Ce stage sert-il à APPRENDRE ?
##
## Le stage 1 sert à découvrir le déplacement, la collecte et les sorts. Un niveau
## d'apprentissage doit être
## survivable — l'équilibrage ne lui applique donc pas la règle « un joueur qui
## ne meurt jamais, c'est un jeu sans enjeu », qui vaut pour les suivants.
##
## Ce n'est pas une exemption de complaisance : le plafond de MORTALITÉ, lui,
## s'applique toujours. Un stage 1 qui tuerait la moitié des joueurs resterait
## un échec.
## L'exemption porte sur le CHAPITRE ENTIER, ses deux épisodes.
##
## Elle avait d'abord été retirée au second épisode — « il est déjà un vrai
## niveau ». La simulation a montré l'erreur : l'épisode 2 du stage 1 gagne
## 92 % du temps sans une seule mort, et déclenchait donc l'alerte « aucune
## tension ». Mais c'est le chapitre où l'on APPREND, et le joueur avait
## justement trouvé le stage 1 trop dur à la main. Le durcir pour satisfaire une
## règle faite pour les stages avancés aurait été suivre l'instrument contre le
## joueur.
@export var is_tutorial: bool = false

## Nombre de "salles" par côté. FORCÉ IMPAIR par le générateur, pour qu'une
## salle tombe exactement au centre — c'est là que se pose la maison.
@export var room_count: int = 11

## Proportion de culs-de-sac supprimés, ce qui crée des boucles dans le labyrinthe.
## 0.0 = labyrinthe parfait -> injouable en poursuite : entrer dans une impasse
## avec un ennemi derrière soi est une mort sans recours.
## 0.35 = beaucoup d'échappatoires, tension sans injustice.
@export_range(0.0, 1.0) var braid_ratio: float = 0.35

@export var portal_count: int = 6
## Écart minimal (en cases) entre deux portails, pour qu'ils ne se collent pas.
@export var portal_min_spacing: int = 6

## Rayon de la zone maison, en cases. 1 -> une maison de 3x3.
@export var house_radius: int = 1

## Gemmes à ramasser pour ouvrir la porte. C'EST l'objectif du jeu : la maison
## reste verrouillée tant qu'il en manque une seule. Zéro rendrait le niveau
## gagnable en ligne droite — le générateur refuse cette valeur.
@export var gem_count: int = 3

## Potions présentes au départ. Chacune charge l'Extra Power (`KillSystem`), seconde
## façon de le remplir après les kills.
@export var potion_count: int = 0

@export var enemy_count: int = 1
## Combien de ces ennemis sont des gobelins ; les autres sont des chasseurs.
## Un seul compteur plutôt que deux listes : le générateur place N spawns sans
## se soucier des espèces, et le Level distribue les sprites ensuite.
## Espèces présentes, dans l'ordre où les ennemis les prennent. Composé par
## `Bestiary.roster(stage)` : cumulatif, chaque stage garde ceux d'avant.
@export var species: Array[String] = ["hunter"]
## Ordre dans lequel les espèces sont réellement posées (voir `_build_lineup`).
var lineup: Array[String] = []
## Vitesse de l'ennemi relative au joueur. > 1.0 rend le jeu impossible :
## en poursuite frontale, le joueur ne peut jamais reprendre d'avance.
@export var enemy_speed_ratio: float = 0.85
@export var enemy_detection_radius: int = 8

## Points de vie AJOUTÉS à ceux du personnage choisi.
##
## Le jeu n'en donnait qu'un seul, et c'était juste tant que la partie durait
## quinze secondes en ligne droite. Depuis que gagner veut dire faire la TOURNÉE
## de toutes les gemmes, une partie dure une à trois minutes en terrain hostile :
## la simulation donnait alors 90 % de captures. Un marathon où la première
## touche tue n'est pas difficile, il est injouable.
##
## C'est un BONUS et non un total : le personnage apporte sa constitution (le
## Mage de Terre encaisse plus que celui de Feu), le stage ajoute sa marge.
@export var player_health_bonus: int = 0

## Points de vie des ennemis, par espèce. Le chasseur est la référence ; le
## gobelin est plus coriace, c'est ce qui fait la réputation du stage 2.
##
## Ces valeurs ont d'abord été RELEVÉES après simulation (à 100 PV, le bot
## abattait un poursuivant en trois secondes et gagnait 100 % du temps), puis
## REBAISSÉES après essai à la main.
##
## L'écart vient de l'agent simulé : il tire en continu, sans jamais avoir à
## reculer, à viser ni à lâcher le bouton. Un joueur humain tire par à-coups
## entre deux virages — au même nombre de PV, il lui faut deux à trois fois plus
## longtemps. Le stage 1, qui sert à apprendre, en souffrait le plus.
##
## Règle retenue : la simulation dit si un niveau est SURVIVABLE, elle ne dit pas
## s'il est agréable. Quand les deux se contredisent, la main tranche.
@export var hunter_health: int = 150
@export var goblin_health: int = 230

## Délai avant qu'un ennemi tué ne revienne, ailleurs sur la carte.
##
## Il REVIENT : sans ça, un joueur patient nettoie le labyrinthe et la poursuite
## — le cœur du jeu — disparaît. Le kill, lui, reste acquis définitivement, donc
## la progression vers l'Extra Power n'est jamais perdue.
##
## Douze secondes laissaient trop de répit : le temps de tuer les trois
## poursuivants, le premier n'était pas encore revenu. Le sursis doit récompenser
## un bon tir, pas vider le niveau.
@export var enemy_respawn_delay: float = 7.0

## Points de vie d'un repaire, quand il est destructible.
##
## Calibré pour une DIZAINE DE SECONDES de tir soutenu par maison, à la portée
## des mages (28 à 44 DPS). Ce n'est pas un mur à grignoter : c'est un
## engagement, tenu au coin de la carte, là où les ennemis sortent — donc sous
## le feu. Trop peu, la règle ne se sentirait pas ; trop, on tirerait sur une
## façade pendant une minute et ce serait une corvée.
@export var lair_health: int = 350

## Temps que met une maison à s'ouvrir avant de lâcher sa créature.
##
## C'est un AVERTISSEMENT : le joueur voit la porte s'animer et a le temps de
## s'écarter du coin. Sans lui, un ennemi surgirait dans son dos.
@export var lair_opening_delay: float = 1.1

## Attente quand les deux maisons sont déjà occupées à faire sortir quelqu'un.
@export var lair_queue_delay: float = 1.0

## Écart entre deux sorties au DÉBUT de la partie.
##
## Les ennemis naissent tous sur les cases des repaires, et il n'y en a que
## deux : au-delà de deux ennemis ils se superposeraient. Les surnuméraires
## attendent dans la maison et sortent l'un après l'autre.
@export var initial_release_step: float = 1.6

## Ces trois délais vivent ici — et pas dans le `Level` — parce que la
## simulation d'équilibrage doit les appliquer à l'identique. Une seconde
## d'avertissement par ennemi change le rythme d'un niveau ; un instrument qui
## l'ignore mesure un autre jeu que celui qu'on joue.


## Le stage propose-t-il des potions ?
func has_potions() -> bool:
	return potion_count > 0


## Points de vie d'un ennemi selon son espèce.
##
## `hunter_health` reste la RÉFÉRENCE — c'est sur le spectre que tout
## l'équilibrage a été mesuré — et chaque espèce en est un multiple. Le gobelin
## à 1,37 redonne exactement les 185 PV mesurés au stage 2 : passer d'une
## constante par espèce à un rapport n'a rien changé aux stages déjà réglés.
func enemy_health(id: String) -> int:
	return int(round(float(hunter_health) * float(Bestiary.of(id)["toughness"])))


## Vitesse d'un ennemi : celle du stage, modulée par l'espèce. Un golem traîne,
## un serpent file — sans cet écart, onze créatures se déplaceraient toutes
## comme une seule.
func enemy_speed(id: String) -> float:
	return enemy_speed_ratio * float(Bestiary.of(id)["swiftness"])


## Espèce du n-ième ennemi. On tourne dans l'ORDRE DE PLACEMENT (`lineup`), pas
## dans le roster : voir `_build_lineup`.
func species_at(index: int) -> String:
	var order := lineup if not lineup.is_empty() else species
	if order.is_empty():
		return Bestiary.FALLBACK
	return order[index % order.size()]


## L'espèce de chaque place du niveau, dans l'ordre de ses index.
##
## Les `spawns` premières sont les poursuivants, et les suivantes les petites gelées qui
## attendent, hors jeu. Elles sont réservées D'AVANCE parce que les repaires suivent les
## ennemis dans les tableaux du combat : un ennemi ajouté en pleine partie décalerait leurs
## index sous les projectiles déjà en vol.
##
## `max_per_level` écarte le surnuméraire : la rotation pose deux Rats sur un petit roster.
func slot_species(spawns: int) -> Array[String]:
	var out: Array[String] = []
	var seen := {}
	var cursor := 0
	var order_size := maxi(1, lineup.size() if not lineup.is_empty() else species.size())
	for _slot in spawns:
		var id := species_at(cursor)
		for _try in order_size:
			if int(seen.get(id, 0)) < int(Bestiary.of(id).get("max_per_level", 1 << 20)):
				break
			cursor += 1
			id = species_at(cursor)
		seen[id] = int(seen.get(id, 0)) + 1
		out.append(id)
		cursor += 1
	for slot in spawns:
		var tuning := Bestiary.of(out[slot])
		for _piece in int(tuning.get("splits_count", 0)):
			out.append(str(tuning["splits_into"]))
	return out


## Ordre de placement des espèces, distinct du roster.
##
## Le roster est cumulatif et grandit à chaque chapitre ; l'effectif d'un stage,
## lui, PLAFONNE — huit poursuivants au stage 10 pour onze espèces. Piocher dans
## l'ordre d'apparition faisait donc tomber les DERNIÈRES, c'est-à-dire la
## nouveauté même du chapitre. Mesuré avant correction : le Démon de Cristal
## n'entrait pas au stage 8, le Minotaure pas au 9, et le Chevalier Noir comme le
## Golem de Givre n'entraient JAMAIS — ni à l'épisode 1, ni au 2.
##
## La nouveauté passe donc devant, les anciennes suivent. Et elles sont décalées
## d'un cran à l'épisode 2 : les deux épisodes d'un même chapitre ne montrent
## alors pas tout à fait la même troupe, ce qui fait voir plus d'espèces sans
## ajouter un seul poursuivant.
static func _build_lineup(c: LevelConfig, index: int) -> void:
	var newcomers: Array[String] = []
	for id in Bestiary.NEWCOMERS[clampi(index, 1, Bestiary.NEWCOMERS.size()) - 1]:
		newcomers.append(str(id))
	var older: Array[String] = []
	for id in c.species:
		if not newcomers.has(id):
			older.append(id)
	c.lineup = newcomers.duplicate()
	if older.is_empty():
		return
	var offset := (c.episode - 1) % older.size()
	for i in older.size():
		c.lineup.append(older[(i + offset) % older.size()])


## Les dix chapitres, nommés d'après les planches d'`assets/stages/` — c'est la
## source de vérité visuelle, les noms du jeu doivent être ceux dessinées dessus.
const STAGE_NAMES := [
	"La Forêt",
	"Le Canyon de la Foudre",
	"Les Dunes de Feu",
	"Les Rivages Océaniques",
	"Les Cavernes de Cristal",
	"Les Montagnes Glacées",
	"Le Bois d'Épine",
	"Les Ruines Anciennes",
	"Le Sanctuaire Déchu",
	"Le Château du Ciel",
]

const STAGE_COUNT := 10
const EPISODES_PER_STAGE := 2

## Les stages où le repaire doit tomber. Deux seulement, aux deux tiers et à la
## veille de la fin : un verrou trop fréquent transformerait la règle en corvée.
const LAIR_BOSS_STAGES := [3, 9]


## Titre affiché : « Stage 2 · Épisode 1 — Le Canyon de la Foudre ».
func title() -> String:
	return "Stage %d · Épisode %d — %s" % [stage, episode, level_name]


## Est-ce le dernier épisode de son chapitre ?
func is_stage_finale() -> bool:
	return episode >= EPISODES_PER_STAGE


## Un boss garde la porte du dernier épisode de chaque chapitre. Le terrain d'essai a
## aussi le sien, mais il ne garde rien : on l'appelle pour le voir (`Level.call_boss`).
func has_boss() -> bool:
	return is_stage_finale() or is_demo


# --- Fabriques -----------------------------------------------------------------
# PRIVÉES, et c'est important : elles rendent un chapitre NU — sans nom, sans
# roster d'espèces, sans numéro d'épisode. `for_stage()` est la seule porte
# d'entrée, parce que c'est elle qui pose tout ça. Un appelant qui prendrait
# `_stage_2()` directement obtiendrait un stage 2 peuplé de spectres seuls.
# Les trois premiers stages sont RÉGLÉS À LA MAIN : ce sont ceux qui ont été
# joués, mesurés et corrigés. Les suivants sont interpolés sur la même pente —
# une courbe ne remplace pas l'essai, mais elle évite qu'un stage 7 inventé de
# toutes pièces soit absurde avant qu'on ait pu y jouer.

static func _stage_1() -> LevelConfig:
	var c := LevelConfig.new()
	c.room_count = 11          # -> grille 23x23
	c.braid_ratio = 0.38       # plus d'échappatoires : ils sont trois
	c.portal_count = 6
	c.portal_min_spacing = 6
	c.gem_count = 3
	c.enemy_count = 3
	c.enemy_speed_ratio = 0.74      # trois poursuivants : chacun doit être semable
	c.enemy_detection_radius = 6
	c.player_health_bonus = 0
	c.is_tutorial = true
	c.potion_count = 1         # dès le premier stage : l'Extra se charge de deux façons
	c.hunter_health = 100      # le stage de l'apprentissage : 6 ou 7 coups suffisent
	c.enemy_respawn_delay = 8.0
	return c


static func _stage_2() -> LevelConfig:
	var c := LevelConfig.new()
	c.room_count = 15          # -> grille 31x31
	c.braid_ratio = 0.32
	c.portal_count = 9
	c.portal_min_spacing = 6
	c.gem_count = 5
	c.potion_count = 1
	c.enemy_count = 4
	c.enemy_speed_ratio = 0.76
	c.enemy_detection_radius = 7
	c.player_health_bonus = 1  # quatre poursuivants, cinq gemmes : la tournée est longue
	c.hunter_health = 135
	c.goblin_health = 185
	c.enemy_respawn_delay = 7.0
	return c


static func _stage_3() -> LevelConfig:
	var c := LevelConfig.new()
	c.room_count = 17          # -> grille 35x35
	c.braid_ratio = 0.30
	c.portal_count = 13        # plus de portails : plus de raccourcis, plus de paris
	c.portal_min_spacing = 6
	c.gem_count = 6
	c.potion_count = 2
	c.enemy_count = 6
	c.enemy_speed_ratio = 0.80
	c.enemy_detection_radius = 8
	c.player_health_bonus = 1  # six gemmes à ramasser sous six poursuivants
	c.hunter_health = 165
	c.goblin_health = 225
	c.enemy_respawn_delay = 6.0
	return c


## Stages 4 à 10 : prolongement de la pente des trois premiers.
##
## ⚠️ PREMIÈRE VERSION MESURÉE ET CORRIGÉE. La pente inventée montait beaucoup
## trop vite : dès le stage 5, la simulation donnait 100 % de morts et 0 % de
## victoires, et l'expert lui-même tombait un tiers du temps à partir du 8.
## Trois causes cumulées :
##
##   - la vitesse du stage MULTIPLIE celle de l'espèce. À 0,92 de stage, un
##     minotaure à 1,10 courait à 1,01 — plus vite que le mage. Un poursuivant
##     plus rapide que soi ne se sème pas, il s'endure jusqu'à la mort.
##   - onze poursuivants pour dix gemmes font une tournée où l'on n'est jamais
##     seul, quelle que soit l'adresse.
##   - la marge de points de vie ne suivait pas : +2 au stage 4 comme au
##     stage 3, alors que la menace avait doublé.
##
## DEUXIÈME PASSE. La première correction a supprimé toutes les alertes sur
## l'expert — il gagne 92 à 100 % partout — mais l'explorateur mourait encore
## 66 à 100 % du temps sur la fin de campagne. La queue de courbe est donc
## resserrée une seconde fois : un poursuivant de moins au stage 10, deux crans
## de vitesse en moins, un point de vie de plus. Le SOMMET de la campagne doit
## rester difficile ; il ne doit pas être un mur.
##
## `t` va de 0 (stage 4) à 1 (stage 10). La taille du labyrinthe PLAFONNE à 21
## salles : au-delà, une tournée complète dépasse cinq minutes et le stage
## devient long avant d'être dur. C'est le nombre de poursuivants et leur
## vitesse qui portent la difficulté, pas les mètres carrés.
static func _stage_curve(index: int) -> LevelConfig:
	var t := float(index - 4) / float(STAGE_COUNT - 4)
	var c := LevelConfig.new()
	c.room_count = 17 + 2 * int(round(t * 2.0))       # 17 -> 21
	c.braid_ratio = lerpf(0.30, 0.26, t)              # de moins en moins d'échappatoires
	c.portal_count = int(round(lerpf(14.0, 20.0, t)))
	c.portal_min_spacing = 6
	c.gem_count = int(round(lerpf(7.0, 9.0, t)))
	c.potion_count = 2
	c.enemy_count = int(round(lerpf(6.0, 8.0, t)))
	# Plafonnée sous la vitesse du mage MÊME multipliée par l'espèce la plus
	# rapide : 0,84 x 1,16 = 0,97. Au-delà, la fuite cesse d'être une option.
	c.enemy_speed_ratio = lerpf(0.78, 0.82, t)
	c.enemy_detection_radius = int(round(lerpf(8.0, 9.0, t)))
	# LA MARGE SUIT LA MENACE, mais de loin. Elle allait de +3 à +7 : mesuré le 2026-11-10,
	# le mage encaissait 3 à 4 coups au Sanctuaire pour 9 PV, et ne finissait jamais une partie
	# sous 2 PV. Le bonus date d'avant les trois sorts dès le départ, l'extra et l'Éveil.
	c.player_health_bonus = 1 + int(round(t * 2.0))
	c.hunter_health = int(round(lerpf(175.0, 230.0, t)))
	c.enemy_respawn_delay = lerpf(6.5, 5.5, t)
	return c


## Le niveau tel qu'il est joué : le chapitre, puis son épisode.
## Le terrain d'essai. Petit et OUVERT (moitié des culs-de-sac supprimés) :
## on vient y regarder ses sorts, pas chercher son chemin. Trois cibles — un
## spectre, un gobelin, un golem — LENTES et myopes : elles n'attaquent que si
## on les cherche, mais encaissent assez pour qu'une brûlure ou un arc se voie.
## Elles reviennent vite : un terrain d'essai vide est un terrain mort.
## Le terrain d'essai, HABILLÉ du décor d'un stage.
##
## Un seul terrain suffisait tant que la démo servait à essayer les sorts. Elle
## sert aussi à REGARDER les stages — leurs tuiles, leurs props, leur monument —
## et un décor de forêt sur les dix stages ne montrait rien. Le terrain garde
## donc ses réglages cléments (on ne meurt pas, les sorts n'ont pas de recharge)
## et ne change que de peau : c'est `stage` que lisent le rendu du labyrinthe,
## le semis de décor et la maison.
static func demo(stage: int = 1) -> LevelConfig:
	stage = clampi(stage, 1, STAGE_COUNT)
	var c := LevelConfig.new()
	c.stage = stage
	c.level_name = STAGE_NAMES[stage - 1]
	c.species = Bestiary.roster(stage)
	# LA NOUVEAUTÉ DU CHAPITRE PASSE DEVANT, en démo aussi.
	#
	# Le remède existait (`_build_lineup`) mais la démo ne l'appelait pas : elle
	# piochait dans le roster, qui est cumulatif et rangé par ordre d'apparition.
	# Avec trois poursuivants seulement, on tombait donc toujours sur les TROIS
	# PLUS ANCIENS — au stage 4, spectre, gobelin et serpent, jamais l'Ombre.
	#
	# C'est exactement le défaut déjà corrigé pour les vrais chapitres, et il
	# fait ici plus de mal : on ne visite un stage en démo que pour voir sa
	# nouveauté, et c'était la seule qu'on ne voyait pas.
	_build_lineup(c, stage)
	c.is_demo = true
	c.is_tutorial = true
	c.room_count = 9
	c.braid_ratio = 0.5
	c.portal_count = 2
	c.portal_min_spacing = 4
	c.gem_count = 1
	c.enemy_count = 3
	c.enemy_speed_ratio = 0.55
	c.enemy_detection_radius = 3
	c.player_health_bonus = 97
	c.hunter_health = 300
	c.enemy_respawn_delay = 2.5
	return c


static func for_stage(index: int, episode_index: int = 1) -> LevelConfig:
	index = clampi(index, 1, STAGE_COUNT)
	episode_index = clampi(episode_index, 1, EPISODES_PER_STAGE)
	var c: LevelConfig
	match index:
		1: c = _stage_1()
		2: c = _stage_2()
		3: c = _stage_3()
		_: c = _stage_curve(index)
	c.stage = index
	c.episode = episode_index
	c.species = Bestiary.roster(index)
	c.level_name = STAGE_NAMES[index - 1]
	_apply_episode(c)
	# APRÈS l'épisode : c'est lui qui décale les anciennes espèces.
	_build_lineup(c, index)
	return c


## Ce que le second épisode change.
##
## Il ne rejoue pas le premier en plus grand : le labyrinthe est déjà neuf à
## chaque partie. Il resserre — un poursuivant de plus, un retour plus rapide,
## une gemme de plus à ramasser sous ce feu-là. La taille, elle, ne bouge pas :
## c'est la tension qui monte, pas le kilométrage.
static func _apply_episode(c: LevelConfig) -> void:
	if c.episode > 1:
		c.enemy_count += 1
		c.gem_count += 1
		c.enemy_respawn_delay = maxf(3.5, c.enemy_respawn_delay - 0.8)
		c.enemy_speed_ratio = minf(0.95, c.enemy_speed_ratio + 0.03)
	c.must_destroy_lairs = c.is_stage_finale() and c.stage in LAIR_BOSS_STAGES
	c.lair_health = 260 + 30 * c.stage


## Tous les niveaux de la campagne, à plat : stage 1 épisode 1, stage 1 épisode
## 2, stage 2 épisode 1... C'est cet index plat que manipule le GameManager, ce
## qui lui évite d'avoir à compter en deux dimensions.
static func all_levels() -> Array[LevelConfig]:
	var levels: Array[LevelConfig] = []
	for index in range(1, STAGE_COUNT + 1):
		for ep in range(1, EPISODES_PER_STAGE + 1):
			levels.append(for_stage(index, ep))
	return levels


## Index plat <-> (stage, épisode).
static func flat_index(index: int, episode_index: int) -> int:
	return (index - 1) * EPISODES_PER_STAGE + (episode_index - 1)
