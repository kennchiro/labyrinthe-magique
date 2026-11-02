class_name CombatSystem
extends RefCounted

## Exécute les compétences : visée, temps de vol, dégâts, zones, murs, soins.
##
## Il remplace SpellSystem, dont il garde ce qui avait été mesuré et prouvé —
## la visée sur l'ennemi le plus proche EN DISTANCE DE CHEMIN, le trajet de
## l'orbe le long des couloirs, et l'impact différé par le temps de vol.
## Ce qui change : un coup au but ne « bannit » plus l'ennemi dix secondes, il
## lui retire des points de vie. Le bannissement n'avait plus de sens dès lors
## qu'on compte les ennemis éliminés.
##
## Aucune dépendance au moteur de scène : le Level écoute ses signaux pour
## fabriquer les orbes et les explosions, la simulation d'équilibrage les ignore.

signal projectile_launched(ability: Ability, target: int, path: Array, duration: float)
signal projectile_hit(ability: Ability, target: int, cell: Vector2i)
signal blast_fired(ability: Ability, cell: Vector2i)
## Un front DÉFERLE : le chemin qu'il va parcourir et le temps qu'il y mettra.
## Émis au lancement pour que le jeu puisse l'animer d'un bout à l'autre.
signal wave_launched(ability: Ability, path: Array, duration: float)
## La gerbe de pierre PART : le chemin entier et le temps qu'elle met à le
## parcourir. Le Level anime la course ; les dégâts, eux, sont appliqués case
## par case ici.
signal line_erupted(ability: Ability, path: Array, duration: float)
## Un cristal est PLANTÉ, il tire, puis il s'éteint.
signal turret_planted(id: int, ability: Ability, cell: Vector2i)
signal turret_fired(id: int, ability: Ability, cell: Vector2i, index: int)
signal turret_faded(id: int)
## LE SÉISME. Le sol tremble pendant `duration`, puis des pans de mur cèdent :
## chaque éboulement est un coup à part entière, à l'endroit où il tombe.
signal quake_started(duration: float, ability: Ability)
signal quake_slide(cell: Vector2i, ability: Ability)
## Une colonne d'eau jaillit sur cette case. Toutes partent au même instant :
## c'est une SALVE, pas une pluie — la pluie, c'est l'autre moitié du sort.
signal geyser_erupted(cell: Vector2i, ability: Ability)
## La zone qui AVANCE a changé de case. Le rendu la suit ; les dégâts, eux,
## sont appliqués ici comme pour n'importe quelle zone.
signal zone_moved(id: int, cell: Vector2i)
signal zone_created(zone_id: int, ability: Ability, cell: Vector2i)
## L'INCANTATION des Quatre Sceaux, émise UNE fois par lancement.
##
## `zone_created` part quatre fois — une par sceau — et la charge ne doit se
## jouer qu'une. C'est donc un signal à part plutôt qu'un compteur côté
## affichage : le Level n'a pas à deviner que quatre zones nées dans la même
## frame sont un seul sort.
signal seals_cast(cell: Vector2i)
signal zone_expired(zone_id: int)
signal wall_raised(cell: Vector2i)
signal wall_fell(cell: Vector2i)
signal blink_performed(from: Vector2i, to: Vector2i)
signal summon_spawned(id: int, kind_id: String, position: Vector2)
signal summon_moved(id: int, position: Vector2, facing: Vector2i)
signal summon_struck(id: int, target_index: int)
signal summon_projectile_launched(id: int, target_index: int, from: Vector2,
	to: Vector2, duration: float, ability: Ability)
signal summon_projectile_hit(id: int, target_index: int, cell: Vector2i, ability: Ability)
signal summon_expired(id: int)
signal enemy_damaged(index: int, dealt: int, ability: Ability)
signal enemy_killed(index: int)
signal player_healed(amount: int)
## Le bouclier est posé, avec sa durée. Il en avait une dans sa fiche (8 s) et
## le code l'IGNORAIT : une fois posé, il tenait jusqu'à ce qu'on le consomme,
## éventuellement une partie entière.
signal player_shielded(amount: int, duration: float)
## Il est tombé — épuisé par les coups, ou arrivé à échéance.
signal player_shield_faded
## Le mage devient INTOUCHABLE pour la durée annoncée.
signal player_made_immune(duration: float)
signal player_immunity_faded
## Émis quand le geste est refusé, avec la raison : l'interface le dit au joueur
## au lieu de laisser croire à un bug.
signal use_refused(reason: String)
## Traits élémentaires — voir le bloc TRAITS plus bas. Les quatre premiers
## informent le Level (visuels) ET la simulation (physique) ; les deux derniers
## ne servent qu'aux visuels, la physique étant déjà appliquée ici même.
## Le facteur accompagne la durée : la trempe de l'élément Eau et le givre du
## Cercle glacé ralentissent tous deux, mais pas d'autant. Un signal qui ne
## porterait que la durée obligerait chaque récepteur à deviner de quel
## ralentissement il s'agit.
signal enemy_soaked(index: int, duration: float, factor: float)
signal enemy_staggered(index: int, duration: float)
signal enemy_pushed(index: int, cell: Vector2i)
## PROJETÉE CONTRE UNE PAROI : sa course a été bloquée avant la fin. L'interface
## s'en sert pour le flash sec du choc — c'est lui qui apprend au joueur, en une
## partie, que la pierre fait mal.
signal enemy_slammed(index: int, cell: Vector2i)
## RAMENÉE vers le mage, et non écartée. Signal distinct de `enemy_pushed` alors
## que les deux ne font que déplacer une créature : ce ne sont pas les mêmes
## événements pour le joueur, donc pas le même effet à l'écran — un souffle
## éclate à l'arrivée, une aspiration laisse une traînée derrière elle.
signal enemy_hauled(index: int, cell: Vector2i)
signal enemy_burning(index: int, duration: float)
## EMPOISONNÉE. Le signal porte la durée, comme la brûlure : c'est au Level de
## décider combien de temps la créature doit être vue verdir.
signal enemy_poisoned(index: int, duration: float)
## UNE FAILLE S'OUVRE sur cette case. Le signal ne porte pas les créatures qui
## en sortent : elles arrivent par `summon_spawned` comme toutes les autres, et
## le Level n'a pas à savoir laquelle vient de quelle porte.
signal rift_opened(cell: Vector2i)
## Un arc SAUTE d'une créature à l'autre. `from_index` vaut -1 pour le premier
## trait, qui part du mage lui-même.
signal chain_arced(from_index: int, to_index: int)
## L'orage se lève au-dessus du mage, et il le suit.
signal storm_gathered(ability: Ability, duration: float)
signal storm_dispersed
## Une décharge tombe du nuage sur une créature.
signal storm_struck(index: int, ability: Ability)
## Un nuage du JUGEMENT se forme quelque part sur la carte, puis se dissipe.
signal sky_cloud_formed(cell: Vector2i, duration: float, ability: Ability)
signal sky_cloud_faded(cell: Vector2i)
## Il foudroie une créature sous lui.
signal sky_bolt(cell: Vector2i, index: int, ability: Ability)
## Une météore est en route : la case visée et le temps qu'elle met à tomber.
## Émis À L'AVANCE pour que le jeu puisse montrer la chute et marquer le sol —
## un rocher qui apparaît au sol sans prévenir n'est pas un événement, c'est un
## dégât inexpliqué.
signal meteor_incoming(cell: Vector2i, delay: float, ability: Ability)
## L'INCANTATION d'une pluie, émise UNE fois par lancement — même raison que
## `seals_cast` : `meteor_incoming` part douze fois, le geste ne se fait qu'une.
signal incantation_cast(cell: Vector2i, ability: Ability)
signal meteor_landed(cell: Vector2i, ability: Ability)
## Le mage est EXALTÉ : ses coups portent plus fort pendant `duration`.
## L'interface doit le montrer — un bonus invisible n'est pas un pouvoir, c'est
## une bizarrerie de chiffres.
signal player_empowered(bonus: int, duration: float)
signal player_calmed
## Le double de l'Écho part : les cases de son trajet et l'instant de chacune.
signal echo_walked(ability: Ability, cells: Array, times: Array)
signal hourglass_turned(duration: float)
signal hourglass_ended(healed: int)
signal time_stopped(duration: float)
## Le venin d'une créature a changé. Zéro dose : elle est guérie.
signal enemy_venomed(index: int, doses: int, duration: float)
signal trail_started(duration: float)
signal puddle_laid(cell: Vector2i, life: float)
signal puddle_stepped(cell: Vector2i)
signal contagion_spread(from: Vector2i, to: Vector2i)
signal transfused(cells: Array, healed: int)
signal pandemic_cast(cell: Vector2i)
signal venom_killed(cell: Vector2i)
signal enemy_blinded(index: int, duration: float)
signal beam_fired(from: Vector2i, cells: Array)
signal enemy_star_marks(index: int, count: int)
signal astre_burst(cell: Vector2i)
signal stars_changed(cells: Array)
signal star_falling(cell: Vector2i, lead: float)
signal star_trail(from: Vector2i, to: Vector2i)
signal enemy_sentenced(index: int)
signal enemy_marked(index: int, duration: float)
signal souls_changed(count: int)
signal soul_sent(path: Array, duration: float)
signal soul_struck(cell: Vector2i)
signal last_hour_cast(cell: Vector2i)
signal last_hour_struck(cell: Vector2i)
signal wings_burst(cell: Vector2i)
signal dawn_cast(cell: Vector2i)
signal dawn_struck(cell: Vector2i)

## Vitesse des projectiles, en cases par seconde. Trois fois le joueur : le tir
## se voit partir et arriver, sans jamais laisser le temps de fuir.
const PROJECTILE_SPEED := 16.0
## Recul appliqué aux structures dans le choix de cible. Plus grand que la plus
## longue portée du jeu : aucun ennemi à portée ne peut donc passer derrière une
## maison, quelle que soit la distance.
const STRUCTURE_PENALTY := 100
## Fréquence des dégâts d'une zone persistante.
const ZONE_TICK := 0.5
## Délai minimal entre deux charges d'un même sort.
##
## Court, mais pas nul : sur téléphone, une pression un peu longue est lue comme
## deux appuis, et sans ce garde-fou le joueur viderait deux charges sur la même
## case sans l'avoir voulu. Il ne se sent pas en jeu — on ne peut pas taper plus
## vite que ça utilement — mais il protège les charges des fausses manœuvres.
const CHARGE_GAP := 0.35

## --- INVOCATIONS ------------------------------------------------------------
##
## Les créatures de l'Invocateur. Elles vivent ICI et non dans le Level, pour la
## même raison que les projectiles et les zones : la simulation d'équilibrage
## doit les faire chasser en headless avec exactement les règles du jeu.
##
## Les marcheurs (imp, gargouille) descendent un champ de distances calculé
## depuis TOUS les ennemis vivants — le plus proche en chemin, pas à vol
## d'oiseau. Le dragon VOLE : il ignore les murs et va droit sur sa proie —
## c'est ce qui fait de lui l'ultime, aucun couloir ne le retarde.
##
##   speed   en cases/s ; reach  distance de frappe (cases, continue)
##   period  secondes entre deux coups ; damage  dégâts par coup
const SUMMON_KINDS := {
	"imp": {"speed": 2.8, "damage": 10, "period": 0.9, "reach": 1.1, "flies": false},
	"gargouille": {"speed": 4.0, "damage": 18, "period": 1.1, "reach": 1.1, "flies": false},
	"dragon": {"speed": 3.6, "damage": 34, "period": 1.3, "reach": 10.0,
		"min_reach": 3.0, "projectile_speed": 0.65, "flies": true},
	# L'OMBRE MALÉFIQUE de la Faille des ténèbres. Elle ne mord pas : elle
	# SOUFFLE un gaz violet, d'où une portée d'une case et demie là où les
	# marcheurs frappent au contact. Ses dégâts sont modestes et son poison fait
	# le reste — c'est une créature qui use, pas qui exécute, et elles sont six.
	"ombre": {"speed": 4.2, "damage": 12, "period": 1.1, "reach": 1.5,
		"flies": false, "poison": 3},
	# LE CYCLONE de l'ultime de l'Air. Il VOLE — c'est-à-dire qu'il va droit sur
	# sa proie, haies comprises. Rien d'autre chez ce mage ne traverse un mur,
	# et c'est ce qui en fait un ultime ; la colonne monte plus haut que les
	# haies, donc ça se voit.
	#
	# Lent (3 cases/s contre 4,5 à 5 aux poursuivants) : il ne rattrape personne
	# à la course. Ce qu'il rattrape, c'est ce qui s'attarde — et il coupe au
	# plus court pendant que sa proie fait le tour.
	"cyclone": {"speed": 3.0, "damage": 18, "period": 1.5, "reach": 1.4,
		"flies": true},
}
## Créatures simultanées au maximum. Au-delà, la PLUS ANCIENNE disparaît : une
## armée sans plafond viderait le labyrinthe à la place du joueur.
const MAX_SUMMONS := 4
## Cadence de recalcul du champ des proies. 0,35 s comme l'IA ennemie : les
## invocations n'ont pas besoin d'être plus réactives que ce qu'elles chassent.
const SUMMON_FIELD_REFRESH := 0.35

## --- TRAITS ÉLÉMENTAIRES ---------------------------------------------------
##
## Chaque élément MARQUE ses coups d'un effet propre. C'est ce qui fait sept
## mages réellement différents : avant, tous tiraient le même projectile sous
## sept couleurs, et le choix du personnage était un choix de teinte.
##
##   FEU      brûlure — 30 % des dégâts en plus, étalés sur 1,5 s
##   EAU      trempe — la cible ralentit de 38 % pendant 2,2 s
##   TERRE    ébranlement — la cible s'arrête net 0,7 s
##   TÉNÈBRES ponction — le mage récupère 22 % des dégâts en vie
##   FOUDRE   arc — le coup saute au voisin (moitié des dégâts)
##   AIR      bourrasque — la cible est repoussée de 2 cases
##   SUPRÊME  écho — 40 % des dégâts se répètent 0,6 s plus tard
##
## Deux garde-fous, tous deux nés du papier avant la première partie :
##   - les ZONES ne déclenchent PAS de trait : une zone tique toutes les 0,5 s,
##     et un ébranlement par tick serait une paralysie permanente ;
##   - les STRUCTURES n'en reçoivent aucun : repousser une maison n'a pas de
##     sens, et la brûlure en aurait trop — un DoT gratuit sur un objectif fixe.
const BURN_RATIO := 0.30
const BURN_TICKS := 3
const BURN_TICK := 0.5
## Le poison prélève UNE FOIS PAR SECONDE. Pas au demi-tick des zones : sur des
## dégâts entiers et petits, un demi-tick arrondi à 1 doublerait silencieusement
## le chiffre annoncé au joueur — « 1 PV » deviendrait 2 PV par seconde.
const POISON_TICK := 1.0
const SOAK_FACTOR := 0.62
const SOAK_DURATION := 2.2
const STAGGER_DURATION := 0.7
## Un même ennemi ne peut être ébranlé qu'une fois toutes les 3 s : sans ce
## verrou, le mage de Terre enchaînerait les arrêts et l'ennemi ne jouerait plus.
const STAGGER_LOCK := 3.0
## LA PONCTION REND UN POINT DE VIE, PAS UNE PART DES DÉGÂTS.
##
## ⚠️ Elle rendait `22 % des dégâts infligés`, et c'était un défaut d'UNITÉS :
## `dealt` se compte en points de vie d'ENNEMI — 16 pour une orbe, 110 pour un
## ultime — quand le mage en a TROIS. Une orbe à 16 dégâts rendait donc 4 PV sur
## un maximum de 3 : le Sorcier des Ténèbres se remettait à fond à chaque coup
## porté, et sa fiche annonçait « encaisse mal ».
##
## Le trait garde son sens — il aspire la vie de ce qu'il frappe — mais il le
## fait à l'échelle du mage : un point, et pas plus souvent que toutes les dix
## secondes. C'est de quoi se relever d'une erreur, pas de quoi ne plus jamais
## en payer une.
const LEECH_HEAL := 1
const LEECH_LOCK := 10.0
const CHAIN_RANGE := 4
const CHAIN_RATIO := 0.5
const PUSH_CELLS := 2
const ECHO_RATIO := 0.40
const ECHO_DELAY := 0.6
## Le trait du Temps : aussi fort que la Trempe mais plus court, c'est un accroc. Mesuré :
## à 72 % pendant 1 s, le bot expert mourait 75 % du temps au Bois d'Épine.
const RETARD_DURATION := 1.4
const RETARD_FACTOR := 0.6
## La trace gardée, en secondes : assez pour le plus long sort qui la relit.
const TRAIL_KEEP := 8.0
## Le venin : des doses qui s'additionnent et prélèvent ensemble, une fois par seconde.
## Mesuré aux bots, comme le reste : voir la note du catalogue.
const VENOM_MAX := 3
const VENOM_DAMAGE := 7
const VENOM_DURATION := 5.0
const VENOM_TICK := 1.0
## Au troisième coup, les étoiles de la cible explosent pour ces dégâts.
const ASTRE_MARKS := 3
const ASTRE_DAMAGE := 26
## Une quatrième étoile remplace la plus ancienne. Un rayon touche à cette distance, en cases.
const STAR_MAX := 3
const STAR_REACH := 0.75
const STAR_TICK := 0.25
## L'écart entre deux étoiles qui tombent, et l'avance que prend leur dessin sur leur impact.
const STAR_FALL_GAP := 0.22
const STAR_FALL_LEAD := 0.34

## Sous cette part de ses PV, un ennemi touché par l'Ange de la Mort est achevé.
const SENTENCE_BELOW := 0.15
## Ce que le marqué du Glas prend de dégâts en plus.
const MARK_BONUS := 0.4
const SOUL_MAX := 3
## Cases parcourues par seconde, et l'écart entre deux âmes lâchées.
const SOUL_SPEED := 13.0
const SOUL_GAP := 0.08
## L'Heure dernière : l'attente avant la faux, sa traversée, et la part de PV qu'elle prend.
const HOUR_DELAY := 0.95
const HOUR_SWEEP := 0.7
const HOUR_SHARE := 0.5

## L'éblouissement du trait : court, et jamais deux fois de suite sur la même créature.
## Le verrou empêche qu'un ennemi reste aveuglé en permanence : il doit pouvoir revenir.
const GLARE_SECONDS := 1.2
const BLIND_LOCK := 5.0
## L'Aube laisse le temps de l'éclair, puis frappe ennemi après ennemi.
const DAWN_DELAY := 0.65
const DAWN_GAP := 0.09

var grid: MazeGrid
var stats: CharacterStats
var health: Health
## SORTS ILLIMITÉS — le mode démo. Aucune recharge : on vient y regarder les
## sorts sous toutes les coutures, pas les rationner. La campagne, elle, garde
## ses recharges ; ce drapeau n'est posé que par un LevelConfig en `is_demo`.
var free_use := false

var _cooldowns := {}        # id de compétence -> secondes restantes
var _charges := {}          # id -> charges restantes (sorts à charges)
var _refills := {}          # id -> charges à rendre quand la recharge finit
var _recover := {}          # id -> délai avant la charge suivante
var _in_flight: Array[Dictionary] = []
var _summon_projectiles: Array[Dictionary] = []
var _zones: Array[Dictionary] = []
var _walls: Array[Dictionary] = []
var _next_zone_id := 1
var _summons: Array[Dictionary] = []
var _next_summon_id := 1
## Champ de distances vers les proies, partagé par tous les marcheurs.
var _summon_field := PackedInt32Array()
var _summon_field_timer := 0.0
var _burning := {}                     # index -> {ticks, timer, damage}
var _poisoned := {}                    # index -> {time_left, timer, damage}
var _echoes: Array[Dictionary] = []
var _stagger_locks := {}               # index -> secondes avant le prochain ébranlement
## index -> secondes avant qu'un piège de zone puisse le reprendre. Sans ce
## verrou, une créature immobilisée dans les flammes serait re-piégée à chaque
## tick et ne repartirait JAMAIS.
var _snare_locks := {}
## Temps restant avant que la Ponction puisse rendre un point de vie. Sans ce
## verrou, un trait qui rend 1 PV à chaque coup reste une immortalité — juste
## un peu plus lente.
var _leech_left := 0.0
var _meteors: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _empower_bonus := 0
var _empower_left := 0.0
var _shield_left := 0.0
## Temps d'intouchabilité restant, pour le bouclier de la Terre.
var _immune_left := 0.0
var _waves: Array[Dictionary] = []
## Les gerbes de pierre en cours de course.
var _lines: Array[Dictionary] = []
## Les séismes en cours. Un seul à la fois en pratique, mais la file coûte le
## même prix qu'un champ et se relit comme les autres effets.
var _quakes: Array[Dictionary] = []
## Les cristaux plantés qui tirent tout seuls.
var _turrets: Array[Dictionary] = []
var _next_turret_id := 1
var _chains: Array[Dictionary] = []
var _storm := {}
var _sky: Array[Dictionary] = []
var _clock := 0.0
var _trail: Array[Dictionary] = []     # {cell, time}, du plus ancien au plus récent
var _walkers: Array[Dictionary] = []
var _hourglass_left := 0.0
var _hourglass_health := 0
var _hourglass_ratio := 0.5
var _time_stop_left := 0.0
var _venom := {}                       # index -> {doses, time_left, timer, plague}
var _venom_locks := {}                 # index -> secondes avant la dose de sol suivante
var _plague: Ability = null            # l'ultime : ce qui éclate laisse son nuage
var _seep_left := 0.0
var _seep_life := 0.0
var _puddles := {}                     # case -> secondes restantes
var _blind_locks := {}                 # index -> secondes avant le prochain aveuglement
var _dawn: Array[Dictionary] = []      # {index, time_left, ability}
var _star_marks := {}                  # index -> étoiles posées par le trait
var _stars: Array[Dictionary] = []     # {cell, time_left, ability}
var _star_tick := 0.0
var _falling: Array[Dictionary] = []   # {cell, time_left, warned, ability}
var _souls := 0                        # âmes récoltées par l'Ange de la Mort
var _marked := {}                      # index -> secondes de marque du Glas
var _flying: Array[Dictionary] = []    # {index, time_left, ability}
var _hour: Array[Dictionary] = []      # {index, time_left, ability}
var _wings: Ability = null             # la coque en place, quand elle aveugle en cédant
var _wings_cell := Vector2i.ZERO


## `p_seed` : la pluie de météores tire au sort ses cases. Le tirage doit être
## REPRODUCTIBLE — sinon la simulation d'équilibrage mesure un ultime différent
## à chaque partie, et deux captures du même sort ne se comparent plus.
func _init(p_grid: MazeGrid, p_stats: CharacterStats, p_health: Health,
		p_seed: int = 0) -> void:
	grid = p_grid
	stats = p_stats
	health = p_health
	_rng.seed = p_seed if p_seed != 0 else 60611


# --- Ressources ------------------------------------------------------------------

## Charges restantes, ou -1 si le sort n'en a pas. L'interface s'en sert pour
## afficher « 3/5 » : sans ce compte à l'écran, le joueur ne peut pas savoir
## combien de brasiers il lui reste, et il découvre la recharge par surprise.
func charges_left(ability: Ability) -> int:
	if ability == null or ability.charges <= 1:
		return -1
	if free_use:
		return ability.charges
	return int(_charges.get(ability.id, ability.charges))


func cooldown_left(ability: Ability) -> float:
	if ability == null or free_use:
		return 0.0
	# Tant qu'il reste une charge, le sort est PRÊT : la recharge d'un sort à
	# charges ne court qu'une fois la dernière dépensée.
	if ability.charges > 1 and charges_left(ability) > 0:
		return float(_recover.get(ability.id, 0.0))
	return float(_cooldowns.get(ability.id, 0.0))


func cooldown_ratio(ability: Ability) -> float:
	if ability == null or ability.cooldown <= 0.0:
		return 1.0
	return clampf(1.0 - cooldown_left(ability) / ability.cooldown, 0.0, 1.0)


## Le geste est-il possible MAINTENANT ?
##
## Seule la RECHARGE compte. Le mana a disparu avec la règle « un sort débloqué
## l'est pour toujours » : une compétence n'est plus un consommable, c'est un
## pouvoir. Ce qui reste hors de portée de cette classe : le déblocage (Progress)
## et la charge de l'ultime (KillSystem), que le GameManager consulte à part.
func can_use(ability: Ability) -> bool:
	if ability == null:
		return false
	return cooldown_left(ability) <= 0.0


# --- Boucle ----------------------------------------------------------------------

func update(delta: float, context: CombatContext) -> void:
	_record_trail(delta, context)
	_time_stop_left = maxf(0.0, _time_stop_left - delta)
	_update_walkers(delta, context)
	_update_hourglass(delta)
	_update_venom(delta, context)
	_update_puddles(delta, context)
	_update_light(delta, context)
	_update_death(delta, context)
	_update_stars(delta, context)
	_leech_left = maxf(0.0, _leech_left - delta)
	for id in _cooldowns.keys():
		var left: float = _cooldowns[id] - delta
		if left <= 0.0:
			_cooldowns.erase(id)
			# La recharge d'un sort à charges les rend TOUTES.
			if _refills.has(id):
				_charges[id] = int(_refills[id])
		else:
			_cooldowns[id] = left
	for id in _recover.keys():
		var gap: float = _recover[id] - delta
		if gap <= 0.0:
			_recover.erase(id)
		else:
			_recover[id] = gap

	_update_projectiles(delta, context)
	_update_summon_projectiles(delta, context)
	_update_summons(delta, context)
	_update_zones(delta, context)
	_update_walls(delta)
	_update_burns(delta, context)
	_update_poisons(delta, context)
	_update_echoes(delta, context)
	_update_meteors(delta, context)
	_update_waves(delta, context)
	_update_lines(delta, context)
	_update_turrets(delta, context)
	_update_quakes(delta, context)
	_update_chains(delta, context)
	_update_storm(delta, context)
	_update_sky(delta, context)
	if _empower_left > 0.0:
		_empower_left = maxf(0.0, _empower_left - delta)
		if _empower_left <= 0.0:
			_empower_bonus = 0
			player_calmed.emit()
	if _immune_left > 0.0:
		_immune_left = maxf(0.0, _immune_left - delta)
		if _immune_left <= 0.0:
			health.immune = false
			player_immunity_faded.emit()
	if _shield_left > 0.0:
		_shield_left = maxf(0.0, _shield_left - delta)
		# Il tombe de DEUX façons : l'échéance, ou les coups qui l'ont vidé.
		# Les deux comptent — un bouclier à zéro qui resterait affiché mentirait
		# autant qu'un bouclier éternel.
		if _wings != null and health.shield <= 0 and _shield_left > 0.0:
			_burst_wings(context)
		if _shield_left <= 0.0 or health.shield <= 0:
			_wings = null
			_shield_left = 0.0
			health.shield = 0
			player_shield_faded.emit()
	for index in _stagger_locks.keys():
		var lock: float = _stagger_locks[index] - delta
		if lock <= 0.0:
			_stagger_locks.erase(index)
		else:
			_stagger_locks[index] = lock
	for index in _snare_locks.keys():
		var snare_lock: float = _snare_locks[index] - delta
		if snare_lock <= 0.0:
			_snare_locks.erase(index)
		else:
			_snare_locks[index] = snare_lock


func _update_projectiles(delta: float, context: CombatContext) -> void:
	for i in range(_in_flight.size() - 1, -1, -1):
		_in_flight[i]["time_left"] = float(_in_flight[i]["time_left"]) - delta
		if float(_in_flight[i]["time_left"]) > 0.0:
			continue
		var shot: Dictionary = _in_flight[i]
		_in_flight.remove_at(i)
		var index := int(shot["target"])
		var ability: Ability = shot["ability"]
		if not context.enemy_alive(index):
			continue
		var cell: Vector2i = context.enemy_cells[index]
		projectile_hit.emit(ability, index, cell)
		# Un projectile à rayon (boule de feu) explose : il touche aussi les
		# voisins. À rayon nul, il ne concerne que sa cible.
		if ability.radius > 0.0:
			_apply_area(ability, cell, context)
		else:
			_apply_damage(index, ability, context)


func _update_zones(delta: float, context: CombatContext) -> void:
	for i in range(_zones.size() - 1, -1, -1):
		var zone: Dictionary = _zones[i]
		zone["time_left"] = float(zone["time_left"]) - delta
		zone["tick"] = float(zone["tick"]) - delta
		if zone.has("path"):
			_walk_zone(zone, delta, context)
		# L'englu SOUTENU se réarme à CHAQUE frame, pas au tick de la zone : sa
		# traînée est plus courte que l'intervalle des ticks, sans quoi l'ennemi
		# retrouverait son allure deux fois par seconde entre deux passages. Les
		# dégâts, eux, restent sur le tick — c'est une usure, pas une rafale.
		var held: Ability = zone["ability"]
		if held.slow_sustained and held.slow_duration > 0.0:
			_apply_chill(held, zone["cell"], context)
		if float(zone["tick"]) <= 0.0:
			zone["tick"] = ZONE_TICK
			# Les dégâts d'une zone sont exprimés PAR SECONDE : on n'en applique
			# que la fraction écoulée, sinon la cadence des ticks changerait la
			# puissance du sort.
			var ability: Ability = zone["ability"]
			var slice := Ability.make({
				"id": ability.id, "kind": ability.kind, "element": ability.element,
				"damage": int(round(ability.damage * ZONE_TICK)), "radius": ability.radius,
			})
			# NI TRAIT NI EXALTATION, exactement comme un tic de brûlure : une
			# nappe qui ronge n'est pas un coup porté par le mage. C'est une
			# usure, posée une fois et qui travaille toute seule.
			#
			# ⚠️ CE N'EST PAS UN DÉTAIL DE COHÉRENCE, c'est ce qui rend une
			# exaltation dosable. Une zone tique deux fois par seconde : le
			# bonus s'y ajoutait à CHAQUE tic, si bien que +10 valait +20 par
			# seconde et par zone. Les Quatre Sceaux en posent quatre à la
			# fois — l'exaltation y aurait valu +80/s, contre +10 sur un trait
			# élémentaire. Le même bonus ne peut pas valoir huit fois plus
			# selon le sort qui le reçoit.
			if ability.damage > 0:
				_apply_area(slice, zone["cell"], context, ability, true, false)
			if ability.venom_doses > 0:
				_apply_zone_venom(ability, zone["cell"], context)
			if ability.blind_seconds > 0.0:
				_apply_zone_blind(ability, zone["cell"], context)
			if ability.mark_seconds > 0.0:
				_apply_zone_mark(ability, zone["cell"], context)
			if ability.snare > 0.0:
				_apply_snare(ability, zone["cell"], context)
			if ability.slow_duration > 0.0 and not ability.slow_sustained:
				_apply_chill(ability, zone["cell"], context)
			if ability.poison_duration > 0.0:
				_apply_poison(ability, zone["cell"], context)
		if float(zone["time_left"]) <= 0.0:
			_zones.remove_at(i)
			zone_expired.emit(int(zone["id"]))


## La zone qui marche : elle avance d'une case, et EMPORTE ce qu'elle tient.
##
## Les créatures happées sont replacées sur la case de la tornade elle-même.
## C'est brutal, et c'est voulu : une tornade ne traîne pas ses victimes
## derrière elle, elle les tient dedans. Elles ressortent là où elle meurt —
## loin, et en tas.
func _walk_zone(zone: Dictionary, delta: float, context: CombatContext) -> void:
	var path: Array = zone["path"]
	zone["walk"] = float(zone["walk"]) - delta
	if float(zone["walk"]) > 0.0:
		return
	zone["walk"] = float(zone["step"])
	var index := int(zone["index"])
	if index >= path.size():
		# Au bout de sa course, elle s'éteint sans attendre sa durée : une
		# tornade qui tournerait sur place au fond d'un cul-de-sac ne serait
		# plus qu'une zone immobile de plus.
		zone["time_left"] = minf(float(zone["time_left"]), 0.2)
		return
	zone["index"] = index + 1
	var cell: Vector2i = path[index]
	var ability: Ability = zone["ability"]
	if ability.zone_carries:
		var field := Pathfinder.distance_field(grid, [zone["cell"]] as Array[Vector2i])
		for prey in context.enemy_cells.size():
			if not context.enemy_alive(prey) or context.is_structure(prey):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[prey])
			if distance < 0 or float(distance) > ability.radius:
				continue
			context.enemy_cells[prey] = cell
			enemy_pushed.emit(prey, cell)
	zone["cell"] = cell
	zone_moved.emit(int(zone["id"]), cell)


## Le piège du brasier : ce qui entre est RETENU, puis repart en brûlant.
##
## Le verrou couvre l'immobilisation ET la brûlure qui suit, plus une seconde de
## grâce : sans elle, une créature libérée au bord des flammes serait reprise
## dans la foulée et le piège deviendrait une prison à vie.
func _apply_snare(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _snare_locks.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_snare_locks[i] = ability.snare + ability.snare_burn + 1.0
		enemy_staggered.emit(i, ability.snare)
		if ability.snare_burn > 0.0:
			# La brûlure part APRÈS la libération : on la programme, elle ne
			# commence pas pendant que la créature est encore prise.
			_echoes.append({"index": i, "time_left": ability.snare,
				"damage": 0, "ability": ability, "burn": ability.snare_burn})


## Champ de distances depuis une case, mis en cache le temps d'une frame : une
## zone à englu soutenu le redemande à chaque frame, et le recalculer coûterait
## un BFS complet par zone et par frame.
var _field_cache := {}
var _field_frame := -1


func _field_from(centre: Vector2i) -> PackedInt32Array:
	var frame := Engine.get_process_frames()
	if frame != _field_frame:
		_field_frame = frame
		_field_cache.clear()
	if not _field_cache.has(centre):
		_field_cache[centre] = Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	return _field_cache[centre]


func _apply_chill(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	# Le champ passe par le CACHE : un englu soutenu appelle cette fonction à
	# chaque frame, et un BFS complet par zone et par frame se paierait.
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or (context.is_structure(i)
				or (_snare_locks.has(i) and not ability.slow_sustained)):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		if not ability.slow_sustained:
			_snare_locks[i] = ability.slow_duration + 0.5
		enemy_soaked.emit(i, ability.slow_duration, ability.slow_factor)


func _update_walls(delta: float) -> void:
	for i in range(_walls.size() - 1, -1, -1):
		_walls[i]["time_left"] = float(_walls[i]["time_left"]) - delta
		if float(_walls[i]["time_left"]) > 0.0:
			continue
		var cell: Vector2i = _walls[i]["cell"]
		_walls.remove_at(i)
		grid.set_cell(cell.x, cell.y, MazeGrid.Cell.FLOOR)
		wall_fell.emit(cell)


# --- Utilisation d'une compétence ------------------------------------------------

## Bonus de dégâts en cours, 0 quand le mage n'est pas exalté. L'interface s'en
## sert pour afficher les chiffres RÉELS de la barre d'action.
func empower_bonus() -> int:
	return _empower_bonus


func empower_left() -> float:
	return _empower_left


## Absorption restante, pour l'interface. Le joueur doit voir FONDRE sa coque :
## un bouclier qu'on ne voit pas s'user ne se gère pas.
func shield_left() -> int:
	return health.shield if health != null else 0


## Retourne true si la compétence est réellement partie. Sinon AUCUNE ressource
## n'est consommée — rater faute de cible n'est pas une faute du joueur.
func use(ability: Ability, context: CombatContext) -> bool:
	if ability == null:
		return false
	if cooldown_left(ability) > 0.0:
		use_refused.emit("recharge")
		return false
	var fired := false
	match ability.kind:
		Ability.Kind.PROJECTILE:
			fired = _cast_projectile(ability, context)
		Ability.Kind.BLAST:
			fired = _cast_blast(ability, context)
		Ability.Kind.ZONE:
			fired = _cast_zone(ability, context)
		Ability.Kind.SHIELD:
			# DEUX boucliers dans le jeu, et ils ne se jouent pas pareil. Celui
			# de l'Eau ABSORBE une quantité de dégâts : il tombe quand il est
			# vidé, même avant l'échéance. Celui de la Terre rend INTOUCHABLE :
			# il ne tombe qu'à l'heure dite, quoi qu'il encaisse. C'est la
			# différence entre une réserve et un répit.
			if ability.immune:
				health.immune = true
				_immune_left = ability.duration
				player_made_immune.emit(ability.duration)
			else:
				health.add_shield(ability.damage)
				_shield_left = ability.duration
				_wings = ability if ability.blind_seconds > 0.0 else null
				player_shielded.emit(ability.damage, ability.duration)
			fired = true
		Ability.Kind.HEAL:
			player_healed.emit(health.heal(ability.damage))
			fired = true
		Ability.Kind.WALL:
			fired = _cast_wall(ability, context)
		Ability.Kind.BLINK:
			fired = _cast_blink(ability, context)
		Ability.Kind.WAVE:
			fired = _cast_wave(ability, context)
		Ability.Kind.LINE:
			fired = _cast_line(ability, context)
		Ability.Kind.TURRET:
			fired = _cast_turret(ability, context)
		Ability.Kind.CHAIN:
			fired = _cast_chain(ability, context)
		Ability.Kind.STORM:
			fired = _cast_storm(ability, context)
		Ability.Kind.SUMMON:
			fired = _cast_summon(ability, context)
		Ability.Kind.ECHO:
			fired = _cast_echo(ability)
		Ability.Kind.HOURGLASS:
			_hourglass_left = ability.duration
			_hourglass_health = health.current
			_hourglass_ratio = ability.hourglass_ratio
			hourglass_turned.emit(ability.duration)
			fired = true
		Ability.Kind.TIME_STOP:
			_stop_time(ability, context)
			fired = true
		Ability.Kind.TRAIL:
			_seep_left = ability.duration
			_seep_life = ability.trail_life
			trail_started.emit(ability.duration)
			fired = true
		Ability.Kind.CONTAGION:
			fired = _cast_contagion(ability, context)
		Ability.Kind.TRANSFUSION:
			fired = _cast_transfusion(ability, context)
		Ability.Kind.PANDEMIC:
			_cast_pandemic(ability, context)
			fired = true
		Ability.Kind.CONSTELLATION:
			fired = _cast_constellation(ability, context)
		Ability.Kind.STARFALL:
			fired = _cast_starfall(ability, context)
		Ability.Kind.SOULS:
			fired = _cast_souls(ability, context)
		Ability.Kind.LAST_HOUR:
			_cast_last_hour(ability, context)
			fired = true
		Ability.Kind.BEAM:
			fired = _cast_beam(ability, context)
		Ability.Kind.DAWN:
			_cast_dawn(ability, context)
			fired = true

	# L'EXALTATION EST RENDUE PAR LE SORT, PAS PAR SON GENRE.
	#
	# Ce bloc vivait DANS `_cast_blast`, ce qui marchait tant que le seul sort
	# exaltant du jeu était l'ultime de l'Eau — un souffle. Renaissance est un
	# SOIN : elle portait `empower_bonus: 8` et ne l'a jamais accordé, parce
	# qu'un soin ne passe pas par le souffle. Le sort partait, le soin tombait,
	# et il ne se passait rien d'autre — pas de bonus, donc pas d'aura.
	#
	# `empower_bonus` est une propriété de la COMPÉTENCE. N'importe laquelle
	# peut donc en porter une, et c'est ici, au tronc commun, qu'on la lit.
	if fired and ability.empower_bonus > 0 and ability.empower_duration > 0.0:
		# Relancer l'exaltation la REMET à neuf plutôt que de l'additionner :
		# deux lancers coup sur coup ne doivent pas donner +16.
		_empower_bonus = ability.empower_bonus
		_empower_left = ability.empower_duration
		player_empowered.emit(_empower_bonus, _empower_left)
		# LA DÉFENSE VIENT AVEC, quand le sort en porte une. Elle emprunte la
		# coque existante plutôt que d'inventer une seconde mécanique : c'est
		# déjà la façon dont ce jeu dit « il encaisse mieux », l'interface sait
		# l'afficher, et `add_shield` la REMET à neuf au lieu de l'empiler.
		#
		# Elle dure exactement le temps du bonus de dégâts : une exaltation est
		# UN état, pas deux qui s'éteindraient l'un après l'autre.
		if ability.empower_shield > 0:
			health.add_shield(ability.empower_shield)
			_shield_left = ability.empower_duration
			player_shielded.emit(ability.empower_shield, ability.empower_duration)
	if not fired:
		return false
	if not free_use:
		_spend(ability)
	return true


## Ce que coûte un lancer. Un sort ordinaire part en recharge ; un sort à
## charges en consomme une, et n'entre en recharge qu'à la DERNIÈRE.
func _spend(ability: Ability) -> void:
	if ability.charges <= 1:
		_cooldowns[ability.id] = ability.cooldown
		return
	var left := charges_left(ability) - 1
	_charges[ability.id] = left
	_refills[ability.id] = ability.charges
	if left > 0:
		_recover[ability.id] = CHARGE_GAP
	else:
		_cooldowns[ability.id] = ability.cooldown


## Index de l'ennemi qui serait visé, -1 s'il n'y en a aucun à portée.
## Sert aussi à l'interface : elle grise le bouton plutôt que de laisser le
## joueur gaspiller un tir dans le vide.
func find_target(ability: Ability, context: CombatContext) -> int:
	var best := -1
	var best_distance := ability.range + 1 + STRUCTURE_PENALTY
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or _already_targeted(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance < 0 or distance > ability.range:
			continue
		# Une maison ne poursuit personne. Entre un ennemi sur les talons et un
		# repaire à abattre, c'est TOUJOURS l'ennemi qui prime : on l'obtient en
		# reculant les structures derrière toutes les créatures à portée, sans
		# les rendre inaccessibles pour autant.
		var score := distance + (STRUCTURE_PENALTY if context.is_structure(i) else 0)
		if score < best_distance:
			best_distance = score
			best = i
	return best


## Une cible déjà visée par un projectile en vol n'est pas re-visée : sans cette
## règle, deux orbes partiraient sur un ennemi qui n'en demandait qu'un, pendant
## que son voisin avance tranquillement.
##
## Elle SAUTE en démo. La règle protège d'un tir gaspillé pendant la recharge ;
## sans recharge il n'y a rien à gaspiller, et la refuser rendait le bouton mort
## dès qu'une orbe était en l'air — le joueur appuyait, rien ne partait.
func _already_targeted(index: int) -> bool:
	if free_use:
		return false
	for shot in _in_flight:
		if int(shot["target"]) == index:
			return true
	return false


func _cast_projectile(ability: Ability, context: CombatContext) -> bool:
	var target := find_target(ability, context)
	if target < 0:
		use_refused.emit("cible")
		return false
	var path := trajectory(context.player_cell, context.enemy_cells[target])
	if path.size() < 2:
		return false
	# La vitesse vient de la COMPÉTENCE : une boule de feu lourde met deux fois
	# plus de temps à arriver qu'une flèche, et ce délai est jouable — l'ennemi
	# a le temps de tourner le coin. La simulation le voit comme le joueur.
	var speed := PROJECTILE_SPEED * maxf(0.15, ability.projectile_speed)
	var duration := float(path.size() - 1) / speed
	_in_flight.append({"ability": ability, "target": target, "time_left": duration})
	projectile_launched.emit(ability, target, path, duration)
	return true


func _cast_blast(ability: Ability, context: CombatContext) -> bool:
	blast_fired.emit(ability, context.player_cell)
	# L'ASPIRATION PASSE AVANT LES DÉGÂTS, sinon elle ne sert à rien : ce qu'elle
	# ramène doit encore trouver l'explosion en arrivant.
	if ability.pull_radius > 0.0:
		_haul_in(ability, context)
	# Un sort qui PROJETTE ne déclenche pas la poussée de son élément : les deux
	# s'additionneraient, et la course réelle ne serait plus celle qu'annonce le
	# sort. Voir l'en-tête de `_apply_area`.
	_apply_area(ability, context.player_cell, context, null,
		ability.blow_cells <= 0)
	# LE SOUFFLE PROJETTE, APRÈS les dégâts.
	#
	# Avant, il enverrait ses victimes hors du rayon de l'explosion et le sort
	# ne blesserait plus personne. C'est l'ordre inverse de l'aspiration de
	# l'Ombre, et pour la même raison.
	if ability.blow_cells > 0:
		_blow_away(ability, context)
	# L'OMBRE RESTE APRÈS LE COUP. Posée ici et non dans `_cast_zone` : c'est une
	# conséquence de l'explosion, pas un sort de zone déguisé — et elle doit
	# naître APRÈS `_apply_area`, sinon la créature qui vient d'être ramenée
	# serait empoisonnée avant d'avoir encaissé.
	if ability.residue_duration > 0.0:
		var residue := _residue_of(ability)
		var id := _next_zone_id
		_next_zone_id += 1
		_zones.append({"id": id, "ability": residue, "cell": context.player_cell,
			"time_left": residue.duration, "tick": 0.0})
		zone_created.emit(id, residue, context.player_cell)
	if ability.rain_count > 0:
		_summon_rain(ability, context)
	# LES GEYSERS, tous en même temps et au hasard du labyrinthe.
	if ability.geyser_count > 0:
		var floor_cells := grid.all_floor_cells()
		var seen := {}
		for i in ability.geyser_count:
			if floor_cells.is_empty():
				break
			var cell: Vector2i = floor_cells[_rng.randi_range(0, floor_cells.size() - 1)]
			# Deux geysers sur la même case seraient un seul geyser qui frappe
			# deux fois : on tire jusqu'à trouver une case libre, sans insister.
			if seen.has(cell):
				continue
			seen[cell] = true
			geyser_erupted.emit(cell, ability)
			_apply_area(Ability.make({
				"id": ability.id, "kind": Ability.Kind.BLAST,
				"element": ability.element, "damage": ability.geyser_damage,
				"radius": ability.geyser_radius,
			}), cell, context, ability)
	# LE SÉISME ATTEND LA PREMIÈRE MÉTÉORE. Déclenché au lancement, il tremblait
	# pendant que le ciel était encore vide : le joueur sentait la secousse avant
	# d'en voir la cause, et les deux ne se reliaient plus. C'est l'IMPACT qui
	# ébranle le sol, donc c'est lui qui l'ouvre.
	#
	# Seules les pluies qui VISENT attendent : une éruption volcanique tremble
	# dès le départ, et c'est très bien — elle n'a pas de première météore, elle
	# en a quatorze qui tombent n'importe où.
	if ability.quake_duration > 0.0 and not (ability.rain_hunts and ability.rain_count > 0):
		_start_quake(ability)
	if ability.sky_clouds > 0:
		_gather_sky(ability)
	if ability.heal_self > 0:
		var gained := health.heal(ability.heal_self)
		if gained > 0:
			player_healed.emit(gained)
	return true


## La pluie de météores. Les cases sont tirées au sort parmi les praticables, et
## les délais étalés sur toute la durée : tombées ensemble, douze météores
## feraient un seul gros dégât et pas une pluie.
func _summon_rain(ability: Ability, context: CombatContext) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	# LA PLUIE QUI VISE. Les cibles sont les ennemis VIVANTS, prises à tour de
	# rôle : le nombre de météores étant fixe, moins il en reste, plus chacun en
	# reçoit. Deux poursuivants sous six météores chacun, c'est un jugement ;
	# douze météores éparpillées sur un labyrinthe vide, c'est un feu d'artifice.
	#
	# Repli sur le tirage au sort quand il n'y a personne : l'ultime doit partir
	# même lancé dans le vide, sinon le joueur perd ses huit kills sans rien voir.
	var hunted: Array[Vector2i] = []
	if ability.rain_hunts:
		# Les STRUCTURES vivent dans les mêmes tableaux que les ennemis (voir
		# CombatContext) : une maison de repaire ne se poursuit pas du ciel, on
		# s'arrête donc là où les ennemis s'arrêtent.
		var last := context.structures_from if context.structures_from >= 0 \
			else context.enemy_cells.size()
		for i in mini(last, context.enemy_cells.size()):
			if context.enemy_health[i].is_alive():
				hunted.append(context.enemy_cells[i])
	# LE GESTE D'ABORD, LE CIEL ENSUITE. Tous les instants de chute sont décalés
	# de la durée de l'incantation : la première pierre part quand le mage a fini
	# de lever les éléments, pas pendant. Le séisme suit tout seul — il s'ouvre
	# au premier impact, donc il attend avec elles.
	if ability.rain_delay > 0.0:
		incantation_cast.emit(context.player_cell, ability)
	for i in ability.rain_count:
		var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		if not hunted.is_empty():
			cell = hunted[i % hunted.size()]
		# UNE PAR UNE, et non toutes ensemble. Les deux pluies existantes tirent
		# leurs délais au hasard : c'est ce qui convient à une averse, où
		# l'important est qu'il en tombe partout. Celle-ci DÉSIGNE ses cibles —
		# elle doit donc s'égrener, pour qu'on voie chaque météore partir, tomber
		# et frapper avant que la suivante ne s'annonce.
		var when := float(i) * ability.rain_duration / float(maxi(1, ability.rain_count)) \
			if ability.rain_hunts else _rng.randf_range(0.0, ability.rain_duration)
		var fall := ability.rain_delay + when + ability.rain_fall
		_meteors.append({"cell": cell, "time_left": fall, "ability": ability})
		meteor_incoming.emit(cell, fall, ability)


## Ouvre le séisme d'un sort. Sorti de `_cast_blast` parce qu'il n'y part plus
## toujours : la pluie qui vise le déclenche à son premier impact.
func _start_quake(ability: Ability) -> void:
	if ability.quake_duration <= 0.0:
		return
	for quake in _quakes:
		if quake["ability"] != ability:
			continue
		# CHAQUE MÉTÉORE SECOUE À NOUVEAU. Le séisme n'est pas EMPILÉ — douze
		# séismes superposés multiplieraient par douze les dégâts de tremblement —
		# il est REMIS À NEUF : sa durée repart de zéro et la secousse d'écran
		# reprend à pleine amplitude. On sent donc un coup par impact, et le sol
		# ne s'apaise jamais tant qu'il en tombe.
		quake["time_left"] = ability.quake_duration
		quake_started.emit(ability.quake_duration, ability)
		return
	_quakes.append({
		"ability": ability, "time_left": ability.quake_duration, "tick": 0.0,
	})
	quake_started.emit(ability.quake_duration, ability)


func _update_meteors(delta: float, context: CombatContext) -> void:
	for i in range(_meteors.size() - 1, -1, -1):
		_meteors[i]["time_left"] = float(_meteors[i]["time_left"]) - delta
		if float(_meteors[i]["time_left"]) > 0.0:
			continue
		var meteor: Dictionary = _meteors[i]
		_meteors.remove_at(i)
		var source: Ability = meteor["ability"]
		var cell: Vector2i = meteor["cell"]
		# LA PREMIÈRE QUI TOUCHE OUVRE LE SÉISME. Les onze suivantes retombent
		# sur un sol déjà en train de trembler.
		if source.rain_hunts:
			_start_quake(source)
		# Chaque météore est une petite explosion à part entière : mêmes règles
		# de rayon que n'importe quel sort de zone, avec ses propres chiffres.
		var strike := Ability.make({
			"id": source.id + "_meteore", "display_name": "Météore",
			"kind": Ability.Kind.BLAST, "element": source.element,
			"damage": source.rain_damage, "radius": source.rain_radius,
			"is_ultimate": true,
		})
		meteor_landed.emit(cell, source)
		_apply_area(strike, cell, context)


## LES QUATRE SCEAUX du Sorcier Suprême, dans l'ordre où ils se posent.
##
## L'élément est ATTACHÉ à la direction, et il ne change jamais : c'est ce qui
## rend le sort jouable. Un joueur qui a appris que le feu part à droite pose ses
## sceaux en sachant lequel gardera quel couloir ; des éléments tirés au hasard
## en feraient une loterie décorative.
const SEAL_ORDER := [
	{"step": Vector2i.RIGHT, "element": Element.Kind.FIRE},
	{"step": Vector2i.DOWN, "element": Element.Kind.WATER},
	{"step": Vector2i.LEFT, "element": Element.Kind.EARTH},
	{"step": Vector2i.UP, "element": Element.Kind.AIR},
]


## Un sceau, dérivé du sort de base : même durée, même rayon, mais l'effet de SON
## élément. Les quatre se partagent les dégâts du sort — c'est un contrôle de
## terrain, pas quatre fois la même zone.
##
## Chaque élément garde ici le trait qu'il a partout ailleurs dans le jeu, et
## c'est la seule règle qui compte : le joueur n'a rien de neuf à apprendre.
##   FEU    brûle — les dégâts les plus lourds, et ça continue après la sortie
##   EAU    trempe — ralentit tant qu'on reste dessus
##   TERRE  ébranle — arrête net, une fois par passage
##   AIR    bourrasque — le plus large, mais le moins mordant
func _seal_of(base: Ability, element: Element.Kind) -> Ability:
	var seal := {
		"id": base.id + "_seal", "kind": Ability.Kind.ZONE, "element": element,
		"display_name": base.display_name,
		"damage": base.damage, "radius": base.radius, "duration": base.duration,
		# ⚠️ LE STYLE SE RECOPIE. Les quatre sceaux sont fabriqués depuis un
		# dictionnaire, pas clonés : tout ce qu'on n'écrit pas ici retombe à sa
		# valeur par défaut. L'oublier a fait poser quatre zones ORDINAIRES —
		# le dessin du sceau ne sortait pas, et on ne voyait que les anneaux
		# tracés en code.
		"zone_style": base.zone_style,
	}
	match element:
		Element.Kind.FIRE:
			seal["damage"] = int(round(base.damage * 1.35))
			seal["poison_duration"] = 3.0
		Element.Kind.WATER:
			seal["slow_duration"] = 2.0
			seal["slow_sustained"] = true
		Element.Kind.EARTH:
			seal["snare"] = 0.9
		Element.Kind.AIR:
			seal["damage"] = int(round(base.damage * 0.7))
			seal["radius"] = base.radius * 1.35
	return Ability.make(seal)


## Écart minimal entre deux sceaux, en cases.
##
## C'est le DIAMÈTRE d'un sceau plus une marge. Deux cercles qui se touchent se
## lisent comme une seule flaque, et tout l'intérêt du sort — savoir quel élément
## garde quel passage — disparaît avec eux.
const SEAL_SPACING := 3
## Au-delà de deux voisins libres, le mage n'est plus dans un couloir.
const SEAL_OPEN_SIDES := 3


## Où tombe un sceau autour du mage : la case libre la plus LOIN dans sa
## direction, sans dépasser l'anneau demandé. `player_cell` si tout est bouché,
## ce que l'appelant écarte.
func _seal_cell(origin: Vector2i, step: Vector2i, ring: int) -> Vector2i:
	var cell := origin
	for _i in maxi(1, ring):
		var next: Vector2i = cell + step
		if not grid.is_floor_v(next):
			break
		cell = next
	return cell


## LE CARREFOUR : un sceau par point cardinal, en couronne.
##
## Une direction bouchée est ABANDONNÉE plutôt que rabattue sur le mage : un
## sceau replié sur la case centrale chevaucherait les trois autres, et on
## perdrait la lecture qu'on cherche justement à obtenir.
func _seal_ring_cells(ability: Ability, context: CombatContext) -> Array:
	var out: Array = []
	for entry in SEAL_ORDER:
		var cell := _seal_cell(context.player_cell, entry["step"], ability.seal_ring)
		out.append(cell if cell != context.player_cell else null)
	return out


## LE COULOIR : les quatre sceaux en enfilade DEVANT le mage, espacés.
##
## Dans un couloir d'une case — c'est-à-dire presque partout dans ce labyrinthe —
## deux des quatre directions sont des haies, et la couronne s'effondrait sur
## elle-même. Le sort devient alors un BALAYAGE : il grave le passage sur toute
## sa longueur, ce qui est exactement ce qu'on veut d'un sort de terrain dans un
## couloir.
##
## Le chemin suit les VIRAGES (`_corridor_ahead`), donc le balayage tourne avec
## le couloir au lieu de s'arrêter au premier coude. Et s'il n'y a pas assez de
## place devant, il se poursuit DERRIÈRE : le mage se retrouve encadré plutôt que
## de perdre la moitié de son sort.
func _seal_sweep_cells(_ability: Ability, context: CombatContext) -> Array:
	var reach := SEAL_SPACING * SEAL_ORDER.size()
	var out: Array = []
	for facing in [context.player_facing, -context.player_facing]:
		if facing == Vector2i.ZERO:
			continue
		var path := _corridor_ahead(context.player_cell, facing, reach)
		var index := 1
		while out.size() < SEAL_ORDER.size() and index < path.size():
			out.append(path[index])
			index += SEAL_SPACING
	while out.size() < SEAL_ORDER.size():
		out.append(null)
	return out


func _cast_seals(ability: Ability, context: CombatContext) -> bool:
	seals_cast.emit(context.player_cell)
	var sides := 0
	for entry in SEAL_ORDER:
		if grid.is_floor_v(context.player_cell + entry["step"]):
			sides += 1
	var cells: Array = _seal_ring_cells(ability, context) if sides >= SEAL_OPEN_SIDES \
		else _seal_sweep_cells(ability, context)

	var planted := 0
	for rank in SEAL_ORDER.size():
		var cell: Variant = cells[rank] if rank < cells.size() else null
		if cell == null:
			continue
		var id := _next_zone_id
		_next_zone_id += 1
		var seal := _seal_of(ability, SEAL_ORDER[rank]["element"])
		_zones.append({"id": id, "ability": seal, "cell": cell,
			"time_left": seal.duration, "tick": 0.0})
		zone_created.emit(id, seal, cell)
		planted += 1
	return planted > 0


func _cast_zone(ability: Ability, context: CombatContext) -> bool:
	if ability.seal_ring > 0:
		return _cast_seals(ability, context)
	var id := _next_zone_id
	_next_zone_id += 1
	var zone := {
		"id": id, "ability": ability, "cell": context.player_cell,
		"time_left": ability.duration, "tick": 0.0,
	}
	# LA TORNADE REMONTE LE COULOIR. Le chemin est calculé D'UN COUP au
	# lancement, virages compris — recalculé en route, elle changerait d'avis à
	# chaque carrefour et le joueur ne pourrait plus prévoir où elle emmène ses
	# poursuivants.
	if ability.zone_travel > 0.0:
		var reach := ability.range if ability.range > 0 else 7
		zone["path"] = _corridor_ahead(context.player_cell,
			context.player_facing, reach)
		zone["step"] = 1.0 / maxf(0.1, ability.zone_travel)
		zone["walk"] = float(zone["step"])
		zone["index"] = 0
	_zones.append(zone)
	zone_created.emit(id, ability, context.player_cell)
	return true


## Le mur se dresse DERRIÈRE le mage, jamais devant : un joueur qui se mure la
## route et meurt le nez contre sa propre pierre ne comprendrait pas.
func _cast_wall(ability: Ability, context: CombatContext) -> bool:
	var cell: Vector2i = context.player_cell - context.player_facing
	if not grid.is_floor_v(cell) or grid.is_occupied(cell):
		use_refused.emit("place")
		return false
	grid.set_cell(cell.x, cell.y, MazeGrid.Cell.WALL)
	_walls.append({"cell": cell, "time_left": ability.duration})
	wall_raised.emit(cell)
	return true


## LE JUGEMENT CÉLESTE : des nuages se forment un peu partout et restent.
##
## Ils sont posés AU HASARD sur les cases praticables, comme la pluie du Feu —
## mais là où une météore tombe une fois et disparaît, un nuage s'installe et
## frappe tant qu'il est là. C'est la différence entre une averse et un ciel
## d'orage.
##
## Leurs instants de première décharge sont ÉTALÉS : formés en même temps, ils
## frapperaient tous à l'unisson et le ciel entier clignoterait au même rythme.
func _gather_sky(ability: Ability) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	for i in ability.sky_clouds:
		var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		_sky.append({
			"cell": cell, "ability": ability,
			"time_left": ability.sky_duration,
			"timer": _rng.randf_range(0.0, ability.sky_interval),
		})
		sky_cloud_formed.emit(cell, ability.sky_duration, ability)


func _update_sky(delta: float, context: CombatContext) -> void:
	for i in range(_sky.size() - 1, -1, -1):
		var cloud: Dictionary = _sky[i]
		cloud["time_left"] = float(cloud["time_left"]) - delta
		if float(cloud["time_left"]) <= 0.0:
			var gone: Vector2i = cloud["cell"]
			_sky.remove_at(i)
			sky_cloud_faded.emit(gone)
			continue
		cloud["timer"] = float(cloud["timer"]) - delta
		if float(cloud["timer"]) > 0.0:
			continue
		var ability: Ability = cloud["ability"]
		cloud["timer"] = ability.sky_interval

		# Chaque nuage ne voit que SOUS lui : c'est ce qui fait du Jugement un
		# ciel et non une frappe téléguidée. Un ennemi qui reste à découvert est
		# puni, un ennemi qui bouge peut passer entre les nuages.
		var centre: Vector2i = cloud["cell"]
		var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
		var best := -1
		var best_distance := ability.sky_reach + 1
		for j in context.enemy_cells.size():
			if not context.enemy_alive(j) or context.is_structure(j):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[j])
			if distance >= 0 and distance < best_distance:
				best_distance = distance
				best = j
		if best < 0:
			continue
		sky_bolt.emit(centre, best, ability)
		var strike := Ability.make({
			"id": ability.id + "_foudre", "display_name": ability.display_name,
			"kind": Ability.Kind.PROJECTILE, "element": ability.element,
			"damage": maxi(1, int(round(float(ability.damage) * 0.18))),
			"is_ultimate": true,
		})
		# Coup d'origine : chaque frappe du ciel peut donc rebondir sur un
		# voisin, comme tout ce que lance ce mage.
		_apply_damage(best, strike, context)


## L'ORAGE : un nuage qui suit le mage et foudroie tout seul.
##
## Relancer l'orage le REMET à neuf plutôt que d'en ouvrir un second : deux
## nuages superposés doubleraient la cadence sans que rien ne le montre à
## l'écran, et le joueur ne comprendrait pas pourquoi sa deuxième invocation
## semble plus forte que la première.
func _cast_storm(ability: Ability, context: CombatContext) -> bool:
	_storm = {
		"ability": ability, "time_left": ability.duration,
		# La première décharge tombe TOUT DE SUITE : un sort qui ne fait rien
		# pendant sa première seconde se lit comme un sort raté.
		"timer": 0.0,
	}
	storm_gathered.emit(ability, ability.duration)
	return true


func _update_storm(delta: float, context: CombatContext) -> void:
	if _storm.is_empty():
		return
	var ability: Ability = _storm["ability"]
	_storm["time_left"] = float(_storm["time_left"]) - delta
	if float(_storm["time_left"]) <= 0.0:
		_storm.clear()
		storm_dispersed.emit()
		return

	_storm["timer"] = float(_storm["timer"]) - delta
	if float(_storm["timer"]) > 0.0:
		return
	_storm["timer"] = ability.storm_interval

	# La cible est la plus proche DU MAGE : le nuage est au-dessus de lui et
	# frappe ce qui l'entoure. Un orage qui bombarderait la carte entière ne
	# récompenserait plus le fait de rester mobile — il jouerait tout seul.
	var best := -1
	var best_distance := ability.storm_range + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	if best < 0:
		return
	storm_struck.emit(best, ability)
	# La décharge est un coup À PART ENTIÈRE : elle déclenche donc le trait de
	# l'élément, et chaque éclair peut rebondir sur un voisin. C'est ce qui rend
	# l'orage redoutable au milieu d'un groupe, et anodin sur un isolé.
	_apply_damage(best, ability, context)


## LA CHAÎNE D'ÉCLAIRS : elle saute d'une créature à l'autre, de proche en
## proche, en s'épuisant à chaque relais.
##
## Le parcours est calculé D'UN COUP au lancement, puis joué relais par relais.
## Le recalculer à chaque saut aurait laissé les ennemis bouger entre-temps : la
## chaîne aurait pu revenir en arrière ou changer d'avis en vol, ce qu'un éclair
## ne fait pas. Ici le trajet est décidé à l'instant du tir, et il s'accomplit.
##
## Chaque créature n'est touchée QU'UNE FOIS : sans cette mémoire, la chaîne
## ferait des allers-retours entre deux ennemis voisins jusqu'à épuisement du
## compteur de sauts.
func _cast_chain(ability: Ability, context: CombatContext) -> bool:
	var first := find_target(ability, context)
	if first < 0:
		use_refused.emit("cible")
		return false

	var hops: Array[int] = [first]
	var visited := {first: true}
	var current := first
	for jump in ability.chain_jumps:
		var next := _nearest_unvisited(current, visited, ability.chain_range, context)
		if next < 0:
			break
		visited[next] = true
		hops.append(next)
		current = next

	_chains.append({
		"ability": ability, "hops": hops, "index": 0, "timer": 0.0,
	})
	return true


## Créature vivante la plus proche de `origin` qui n'a pas encore été touchée.
## La distance se mesure en CHEMIN : la foudre suit les couloirs comme tout le
## reste du jeu — un arc qui traverserait une haie serait le privilège d'un
## ultime, pas d'un sort de rang 1.
func _nearest_unvisited(origin: int, visited: Dictionary, reach: int,
		context: CombatContext) -> int:
	var field := Pathfinder.distance_field(grid,
		[context.enemy_cells[origin]] as Array[Vector2i])
	var best := -1
	var best_distance := reach + 1
	for i in context.enemy_cells.size():
		if visited.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	return best


func _update_chains(delta: float, context: CombatContext) -> void:
	for i in range(_chains.size() - 1, -1, -1):
		var chain: Dictionary = _chains[i]
		chain["timer"] = float(chain["timer"]) - delta
		if float(chain["timer"]) > 0.0:
			continue
		var ability: Ability = chain["ability"]
		var hops: Array = chain["hops"]
		var index := int(chain["index"])
		if index >= hops.size():
			_chains.remove_at(i)
			continue
		chain["index"] = index + 1
		chain["timer"] = ability.chain_delay

		var target := int(hops[index])
		# Le trait part du mage pour le premier relais, de la victime
		# précédente pour les suivants.
		chain_arced.emit(int(hops[index - 1]) if index > 0 else -1, target)
		if not context.enemy_alive(target):
			continue
		# La chaîne s'ÉPUISE : sans cette décroissance, grouper cinq ennemis
		# reviendrait à les tuer tous pour le prix d'un.
		var power := int(round(float(ability.damage) * pow(ability.chain_falloff, index)))
		var relay := Ability.make({
			"id": "%s_relais_%d" % [ability.id, index],
			"display_name": ability.display_name,
			"kind": Ability.Kind.PROJECTILE, "element": ability.element,
			"damage": maxi(1, power),
		})
		# JAMAIS le trait : ce sort EST la chaîne de l'élément Foudre. Le laisser
		# déclencher en plus l'arc du trait ferait partir un arc de trop et
		# frapperait un maillon deux fois — mesuré : 5 arcs pour 3 relais.
		# L'exaltation, elle, s'applique au premier maillon comme à tout coup
		# d'origine.
		_apply_damage(target, relay, context, false, index == 0)


## LA VAGUE : un front qui part droit devant et balaie tout son chemin.
##
## Elle ne vise pas — elle prend le couloir. C'est ce qui la sépare du
## projectile, qui cherche une cible, et du souffle, qui frappe tout d'un coup
## autour du lanceur. Ici l'ennemi VOIT venir, et peut encore s'écarter dans une
## intersection : la vague récompense le joueur qui l'aligne sur un couloir
## droit, pas celui qui appuie au hasard.
func _cast_wave(ability: Ability, context: CombatContext) -> bool:
	# LA VAGUE VA CHERCHER L'ENNEMI, elle ne part pas droit devant.
	#
	# Première version : elle suivait le regard du mage. Défaut de conception —
	# en FUYANT, on tourne le dos à ses poursuivants, et le sort partait donc
	# systématiquement du mauvais côté. Il fallait s'arrêter et se retourner
	# pour s'en servir : exactement ce qu'un sort de fuite doit éviter.
	#
	# Elle remonte désormais le COULOIR jusqu'à l'ennemi le plus proche, comme
	# un projectile — mais en frappant tout ce qu'elle croise en chemin. À
	# défaut de cible, elle part devant : un sort qui refuserait de sortir
	# faute d'ennemi visible serait un bouton mort.
	var path: Array[Vector2i] = []
	var target := find_target(ability, context)
	if target >= 0:
		var route := trajectory(context.player_cell, context.enemy_cells[target])
		for i in range(1, route.size()):
			if path.size() >= ability.range:
				break
			path.append(route[i])
	if path.is_empty():
		var cell := context.player_cell
		for step in ability.range:
			var next: Vector2i = cell + context.player_facing
			if not grid.is_floor_v(next):
				break
			cell = next
			path.append(cell)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var duration := float(path.size()) / maxf(1.0, ability.wave_speed)
	_waves.append({
		"ability": ability, "path": path, "index": 0,
		"step": duration / float(path.size()), "timer": 0.0,
		# Chaque ennemi n'est frappé QU'UNE FOIS par vague : sans cette mémoire,
		# un ennemi qui recule devant le front encaisserait à chaque case.
		"hit": {},
	})
	wave_launched.emit(ability, path, duration)
	return true


func _update_waves(delta: float, context: CombatContext) -> void:
	for i in range(_waves.size() - 1, -1, -1):
		var wave: Dictionary = _waves[i]
		wave["timer"] = float(wave["timer"]) - delta
		if float(wave["timer"]) > 0.0:
			continue
		wave["timer"] = float(wave["step"])
		var path: Array = wave["path"]
		var index := int(wave["index"])
		if index >= path.size():
			_waves.remove_at(i)
			continue
		wave["index"] = index + 1
		_break_on_wave(wave, path[index], context)


## Le front est arrivé sur une case : il frappe ce qui s'y trouve, et ce qui est
## à portée de sa largeur.
func _break_on_wave(wave: Dictionary, cell: Vector2i, context: CombatContext) -> void:
	var ability: Ability = wave["ability"]
	var already: Dictionary = wave["hit"]
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or already.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		already[i] = true
		_apply_damage(i, ability, context)


## PICS DE TERRE : la gerbe COURT DANS LE COULOIR, elle n'entoure pas le mage.
##
## C'était un souffle circulaire de plus — la même mécanique que trois autres
## sorts du jeu, dessinée avec l'éclat générique. Le Mage de la Terre est le
## lent, le résistant, celui qui ferme un couloir : il lui fallait un geste à
## lui. C'est la LIGNE, comme la Foudre a la chaîne.
##
## Deux temps. La gerbe part des pieds du mage et file devant, de case en case,
## en frappant tout ce qu'elle croise. Puis les pointes RESTENT plantées : ce
## qui passe dessus est mordu et ralenti. Le premier temps est une attaque, le
## second est du terrain — et c'est le second qui le distingue du Feu (dont le
## brasier cloue sur place) et de l'Eau (dont le cercle englue sans blesser).
func _cast_line(ability: Ability, context: CombatContext) -> bool:
	var path := _corridor_ahead(context.player_cell, context.player_facing,
		ability.range)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var duration := float(path.size()) / maxf(1.0, ability.line_speed)
	var line := {
		"ability": ability, "path": path, "index": 0,
		"step": duration / float(path.size()), "timer": 0.0,
		# Comme la vague : chaque créature n'encaisse l'éruption QU'UNE FOIS,
		# même si elle recule devant la gerbe qui monte.
		"hit": {},
		"plant": _plant_of(ability),
	}
	line_erupted.emit(ability, path, duration)

	# D'UN COUP quand la vitesse est NULLE.
	#
	# La boucle d'entretien consomme le temps ÉCOULÉ, ce qui est juste pour une
	# gerbe qui court : elle avance de ce que le temps permet. Mais aucune
	# vitesse, si haute soit-elle, ne lève dix cases dans la même image par ce
	# chemin — la Faille, censée surgir, se voyait courir. Une vitesse de zéro
	# dit donc « simultané » : on lève tout ici même et la ligne n'entre jamais
	# dans la file. C'est une valeur qui se lit dans le catalogue, là où un
	# seuil en secondes aurait été un chiffre magique de plus.
	if ability.line_speed <= 0.0:
		for cell in path:
			_erupt(line, cell, context)
		return true
	_lines.append(line)
	return true


## Le couloir DEVANT le mage, virages compris.
##
## Une ligne qui s'arrêterait au premier mur serait inutilisable dans un
## labyrinthe : on y voit rarement plus de trois cases devant soi. La gerbe suit
## donc le couloir — tant qu'il n'y a qu'une seule façon de continuer. À une
## intersection elle s'arrête : au-delà, « tout droit » ne veut plus rien dire,
## et une gerbe qui choisirait sa route à la place du joueur serait un sort
## qu'on ne peut pas viser.
func _corridor_ahead(from: Vector2i, facing: Vector2i, limit: int) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cell := from
	var dir := facing
	for step in limit:
		var next: Vector2i = cell + dir
		if not grid.is_floor_v(next):
			var options: Array[Vector2i] = []
			for side in [Vector2i(dir.y, dir.x), Vector2i(-dir.y, -dir.x)]:
				if grid.is_floor_v(cell + side):
					options.append(side)
			if options.size() != 1:
				break
			dir = options[0]
			next = cell + dir
		cell = next
		path.append(cell)
	return path


## Le sort DÉRIVÉ des pics plantés : une zone d'une seule case.
##
## Les pointes qui restent sont une zone comme les autres — elles mordent par
## seconde, elles ralentissent, elles expirent. Plutôt que d'écrire un second
## mécanisme qui ferait la même chose, on fabrique le sort correspondant et on
## laisse tourner celui qui existe et qui est éprouvé.
func _plant_of(ability: Ability) -> Ability:
	# La durée des GERBES, distincte de celle du sort : un orbe qui tient trente
	# secondes ne doit pas laisser trente secondes de pierres derrière chaque
	# balayage, sinon le couloir se referme pour de bon.
	var life := ability.spike_life if ability.spike_life > 0.0 else ability.duration
	return Ability.make({
		"id": ability.id + "_plant", "display_name": ability.display_name,
		"kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": ability.line_bite, "radius": 0.5, "duration": life,
		"slow_duration": ability.slow_duration, "slow_factor": ability.slow_factor,
		"zone_style": "eruption" if ability.spike_anim else "pics",
	})


func _update_lines(delta: float, context: CombatContext) -> void:
	for i in range(_lines.size() - 1, -1, -1):
		var line: Dictionary = _lines[i]
		line["timer"] = float(line["timer"]) - delta
		if float(line["timer"]) > 0.0:
			continue
		var path: Array = line["path"]
		# TOUT CE QUE LE TEMPS ÉCOULÉ PERMET, et pas une case par image.
		#
		# La gerbe des Pics court à douze cases par seconde : une case par
		# image suffisait. La Faille, elle, se lève D'UN COUP — cent cases par
		# seconde — et une case par image l'aurait étalée sur dix images, soit
		# un sixième de seconde de retard sur la dernière. On consomme donc le
		# temps accumulé, ce qui rend la cadence indépendante du framerate.
		var budget := 32
		while float(line["timer"]) <= 0.0 and budget > 0:
			budget -= 1
			line["timer"] = float(line["timer"]) + float(line["step"])
			var index := int(line["index"])
			if index >= path.size():
				break
			line["index"] = index + 1
			_erupt(line, path[index], context)
		if int(line["index"]) >= path.size():
			_lines.remove_at(i)


## Une case se soulève : elle frappe, puis elle reste.
func _erupt(line: Dictionary, cell: Vector2i, context: CombatContext) -> void:
	var ability: Ability = line["ability"]
	var already: Dictionary = line["hit"]
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or already.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		already[i] = true
		_apply_damage(i, ability, context)
	var plant: Ability = line["plant"]
	if plant.duration <= 0.0:
		return
	var id := _next_zone_id
	_next_zone_id += 1
	_zones.append({
		"id": id, "ability": plant, "cell": cell,
		"time_left": plant.duration, "tick": 0.0,
	})
	zone_created.emit(id, plant, cell)


## ÉCLATS DE CRISTAL : il PLANTE le cristal, et le cristal se bat tout seul.
##
## Le sort MENTAIT : il annonçait « trois éclats » et en tirait un. C'était un
## Rocher plus faible, plus lointain, et huit fois plus lent — strictement
## moins bon que l'attaque de base du même mage. Aucune raison d'appuyer.
##
## Le cristal fiché dans le sol est la seule chose du jeu qui attaque SANS le
## joueur. L'Invocateur a des créatures, mais elles CHASSENT ; le cristal ne
## bouge jamais, et c'est ce qui les sépare à l'œil nu. Il récompense le seul
## mage qui ne peut pas fuir : il plante, il hérisse le couloir de pics, il
## s'entoure de son égide, et il tient.
func _cast_turret(ability: Ability, context: CombatContext) -> bool:
	# Devant lui de préférence — un cristal posé sur ses propres pieds ne dit
	# pas au joueur qu'il vient de tenir un couloir. Mais le nez au mur, il le
	# plante sur place plutôt que de refuser : un bouton qui ne part pas parce
	# qu'on regarde la pierre serait incompréhensible.
	var cell: Vector2i = context.player_cell + context.player_facing
	if not grid.is_floor_v(cell):
		cell = context.player_cell
	var id := _next_turret_id
	_next_turret_id += 1
	_turrets.append({
		"id": id, "ability": ability, "cell": cell,
		"time_left": ability.duration,
		# Le PREMIER éclat part tout de suite. Un cristal qui reste muet une
		# seconde et demie après avoir été planté se lit comme un sort raté.
		"tick": 0.0,
	})
	turret_planted.emit(id, ability, cell)
	return true


func _update_turrets(delta: float, context: CombatContext) -> void:
	for i in range(_turrets.size() - 1, -1, -1):
		var turret: Dictionary = _turrets[i]
		turret["time_left"] = float(turret["time_left"]) - delta
		turret["tick"] = float(turret["tick"]) - delta
		var ability: Ability = turret["ability"]
		# LE CRISTAL SUIT LE MAGE. Il est fiché dans le sol à ses pieds et
		# repart avec lui : c'est ce que demande le mage le plus lent du jeu,
		# qui ne peut pas revenir chercher ce qu'il a laissé derrière.
		if ability.turret_follows:
			turret["cell"] = context.player_cell
		if float(turret["tick"]) <= 0.0:
			turret["tick"] = maxf(0.1, ability.turret_interval)
			var cell: Vector2i = turret["cell"]
			var prey := _nearest_in_reach(cell, ability.range, context)
			if prey >= 0:
				turret_fired.emit(int(turret["id"]), ability, cell, prey)
				if ability.turret_sweep:
					# L'ORBE N'ENVOIE RIEN : IL OUVRE LE SOL.
					#
					# Une faille se lève dans le couloir, du mage jusqu'à sa
					# proie, et frappe tout ce qui s'y trouve. C'est le balayage
					# des Pics de terre — déclenché tout seul, dès qu'une
					# créature entre à portée, au lieu d'être visé à la main.
					_sweep_to(ability, cell, context.enemy_cells[prey], context)
				else:
					# Coup D'ORIGINE : il déclenche donc le trait de la Terre,
					# comme s'il venait du mage.
					_apply_damage(prey, ability, context)
		if float(turret["time_left"]) <= 0.0:
			_turrets.remove_at(i)
			turret_faded.emit(int(turret["id"]))


## LE SÉISME : le sol tremble, et la pierre CÈDE par pans.
##
## Ce qui le sépare de la pluie de météores du Feu n'est PAS l'endroit où ça
## tombe — mesuré : 97 à 99 % des cases d'un labyrinthe touchent un mur, donc
## une règle « les pans cèdent au pied des parois » aurait été décorative. Une
## première version la posait quand même, avec un commentaire qui promettait
## qu'y longer un mur serait dangereux : c'était faux.
##
## La vraie différence est la TEXTURE. Le Feu lâche quatorze météores lourdes
## étalées sur sa durée ; la Terre fait crouler des pans par vagues de trois, et
## la CADENCE s'emballe au début puis se calme — les premières secondes sont une
## avalanche, les dernières un grondement. Un test garde cette décroissance.
func _update_quakes(delta: float, context: CombatContext) -> void:
	for i in range(_quakes.size() - 1, -1, -1):
		var quake: Dictionary = _quakes[i]
		var ability: Ability = quake["ability"]
		quake["time_left"] = float(quake["time_left"]) - delta
		quake["tick"] = float(quake["tick"]) - delta
		# LE TREMBLEMENT LUI-MÊME BLESSE, partout, tant qu'il dure.
		#
		# Sans lui, l'ultime était un spectacle : mesuré, vingt-sept
		# éboulements tirés au sort sur six cents cases ne touchaient presque
		# jamais une créature donnée. Les pans qui cèdent restent la grosse
		# frappe, locale et aléatoire ; la secousse est le fond continu qui
		# n'épargne personne.
		if ability.quake_tremor > 0:
			quake["grind"] = float(quake.get("grind", 0.0)) - delta
			if float(quake["grind"]) <= 0.0:
				quake["grind"] = ZONE_TICK
				var slice := Ability.make({
					"id": ability.id, "kind": Ability.Kind.BLAST,
					"element": ability.element,
					"damage": maxi(1, int(round(ability.quake_tremor * ZONE_TICK))),
				})
				for prey in context.enemy_cells.size():
					if context.enemy_alive(prey):
						_apply_damage(prey, slice, context, false, false)
		if float(quake["tick"]) <= 0.0:
			# Au début, une vague tombe deux fois plus vite qu'à la fin.
			var left := clampf(float(quake["time_left"]) / maxf(0.1,
				ability.quake_duration), 0.0, 1.0)
			quake["tick"] = ability.quake_interval * (1.6 - 0.6 * left)
			for slide in ability.quake_slides:
				_collapse(ability, context)
		if float(quake["time_left"]) <= 0.0:
			_quakes.remove_at(i)


## Un pan cède, quelque part sur le sol du labyrinthe.
func _collapse(ability: Ability, context: CombatContext) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
	quake_slide.emit(cell, ability)
	var blow := Ability.make({
		"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.quake_damage, "radius": ability.quake_radius,
	})
	_apply_area(blow, cell, context, ability)


## Le balayage automatique de l'orbe : une faille du mage jusqu'à sa proie.
##
## Le chemin est celui du COULOIR, virages compris — la faille contourne la
## pierre, elle ne la traverse pas. Elle se lève d'un coup : rien à faire
## avancer, donc rien à mettre dans la file des lignes.
func _sweep_to(ability: Ability, from: Vector2i, prey: Vector2i,
		context: CombatContext) -> void:
	var route := trajectory(from, prey)
	var path: Array[Vector2i] = []
	for i in range(1, route.size()):
		if path.size() >= ability.range:
			break
		path.append(route[i])
	if path.is_empty():
		return
	var line := {
		"ability": ability, "path": path, "index": 0, "step": 0.0, "timer": 0.0,
		"hit": {}, "plant": _plant_of(ability),
	}
	line_erupted.emit(ability, path, 0.0)
	for cell in path:
		_erupt(line, cell, context)


## La proie la plus proche d'une CASE, en distance de chemin — pas à vol
## d'oiseau. Un ennemi à deux cases derrière un mur est à dix cases de marche :
## le cristal ne doit pas tirer à travers la pierre.
func _nearest_in_reach(cell: Vector2i, reach: int, context: CombatContext) -> int:
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	var best := -1
	var best_distance := reach + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or distance > reach or distance >= best_distance:
			continue
		best_distance = distance
		best = i
	return best


## LA TRANSLATION GLISSE, LE PASSAGE TRAVERSE.
##
## Deux translations dans le même kit avaient besoin de deux comportements —
## sinon la plus courte n'est qu'une version ratée de l'autre. Le Sorcier des
## Ténèbres avait exactement ça : une Translation de 4 cases toutes les 9 s à
## côté d'un Pas de l'ombre de 6 cases toutes les 6,5 s. Plus courte, plus lente,
## sur le même geste : elle n'avait aucune raison d'exister.
##
## `pierces_walls` la sépare pour de bon. Elle FRANCHIT une haie et se pose de
## l'autre côté, là où le Pas de l'ombre glisse jusqu'au mur et s'arrête. C'est
## la seule chose du jeu qui coupe à travers le labyrinthe, et ça va au mage des
## passages — la topologie du labyrinthe est TOUT le jeu, et rien dans son kit
## ne s'en servait.
##
## Elle vise la case la plus LOINTAINE praticable, et non la première :
## s'arrêter au premier sol franchi la remettrait dans le couloir d'où elle
## vient dès que le mage est collé à une haie.
func _cast_blink(ability: Ability, context: CombatContext) -> bool:
	var destination := context.player_cell
	if ability.rewind_seconds > 0.0:
		destination = cell_at_past(ability.rewind_seconds)
		if destination == context.player_cell:
			use_refused.emit("immobile")
			return false
		blink_performed.emit(context.player_cell, destination)
		return true
	if ability.pierces_walls:
		for step in range(ability.range, 0, -1):
			var far: Vector2i = context.player_cell + context.player_facing * step
			if grid.is_floor_v(far) and not grid.is_occupied(far):
				destination = far
				break
	else:
		for step in ability.range:
			var next: Vector2i = destination + context.player_facing
			if not grid.is_floor_v(next):
				break
			destination = next
	if destination == context.player_cell:
		use_refused.emit("mur")
		return false
	if ability.cloud_duration > 0.0:
		_cloud_zone(context.player_cell, ability)
	blink_performed.emit(context.player_cell, destination)
	if ability.blind_radius > 0:
		_blind_around(destination, ability, context)
	if ability.trail_damage > 0:
		_burn_trail(context.player_cell, destination, ability, context)
	return true


# --- Le temps : la trace du mage ----------------------------------------------------

func _record_trail(delta: float, context: CombatContext) -> void:
	_clock += delta
	if _trail.is_empty() or _trail[-1]["cell"] != context.player_cell:
		if _seep_left > 0.0 and not _trail.is_empty():
			_puddles[_trail[-1]["cell"]] = _seep_life
			puddle_laid.emit(_trail[-1]["cell"], _seep_life)
		_trail.append({"cell": context.player_cell, "time": _clock})
	# On garde la dernière case d'AVANT la limite : c'est là qu'il était à cet instant.
	while _trail.size() > 1 and float(_trail[1]["time"]) < _clock - TRAIL_KEEP:
		_trail.pop_front()


## La trace depuis `seconds` : son premier élément est la case où il se tenait alors.
func _trail_since(seconds: float) -> Array[Dictionary]:
	var cutoff := _clock - seconds
	var first := 0
	for i in _trail.size():
		if float(_trail[i]["time"]) <= cutoff:
			first = i
	return _trail.slice(first)


## Où était le mage il y a `seconds`. Plus tôt que le début du niveau : son départ.
func cell_at_past(seconds: float) -> Vector2i:
	var recent := _trail_since(seconds)
	return recent[0]["cell"] if not recent.is_empty() else Vector2i.ZERO


func _cast_echo(ability: Ability) -> bool:
	var recent := _trail_since(ability.echo_seconds)
	if recent.size() < 2:
		use_refused.emit("immobile")
		return false
	var cells: Array = []
	var times: Array = []
	var start := float(recent[1]["time"]) - 0.2
	for i in recent.size():
		cells.append(recent[i]["cell"])
		times.append(maxf(0.0, float(recent[i]["time"]) - start) if i > 0 else 0.0)
	_walkers.append({"ability": ability, "cells": cells, "times": times,
		"elapsed": 0.0, "at": 0, "hit": {}})
	echo_walked.emit(ability, cells, times)
	return true


## Le double frappe ce qui se tient sur sa case ou la touche, une seule fois par créature.
func _update_walkers(delta: float, context: CombatContext) -> void:
	for w in range(_walkers.size() - 1, -1, -1):
		var walker: Dictionary = _walkers[w]
		walker["elapsed"] = float(walker["elapsed"]) + delta
		var times: Array = walker["times"]
		while int(walker["at"]) + 1 < times.size() \
				and float(times[int(walker["at"]) + 1]) <= float(walker["elapsed"]):
			walker["at"] = int(walker["at"]) + 1
		var cell: Vector2i = walker["cells"][int(walker["at"])]
		var hit: Dictionary = walker["hit"]
		for i in context.enemy_cells.size():
			if hit.has(i) or not context.enemy_alive(i):
				continue
			var gap: Vector2i = context.enemy_cells[i] - cell
			if absi(gap.x) + absi(gap.y) <= 1:
				hit[i] = true
				_apply_damage(i, walker["ability"], context)
		if float(walker["elapsed"]) >= float(times[-1]):
			_walkers.remove_at(w)


func _update_hourglass(delta: float) -> void:
	if _hourglass_left <= 0.0:
		return
	_hourglass_left -= delta
	if _hourglass_left > 0.0:
		return
	var lost := maxi(0, _hourglass_health - health.current)
	var gained := health.heal(ceili(lost * _hourglass_ratio)) if lost > 0 else 0
	if gained > 0:
		player_healed.emit(gained)
	hourglass_ended.emit(gained)


## L'arrêt passe par l'ébranlement existant : la simulation d'équilibrage et le jeu savent
## déjà qu'une créature ébranlée ne bouge ni ne frappe. Les projectiles et les repaires,
## eux, lisent `time_factor_at` et `time_stop_left`.
func _stop_time(ability: Ability, context: CombatContext) -> void:
	_time_stop_left = ability.duration
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			enemy_staggered.emit(i, ability.duration)
	time_stopped.emit(ability.duration)


func time_stop_left() -> float:
	return _time_stop_left


## L'allure du temps sur une case, pour un projectile ennemi : 0 quand tout est figé.
func time_factor_at(cell: Vector2i) -> float:
	if _time_stop_left > 0.0:
		return 0.0
	var factor := 1.0
	for zone in _zones:
		var ability: Ability = zone["ability"]
		if ability.time_factor < factor and Vector2(cell).distance_to(
				Vector2(zone["cell"] as Vector2i)) <= ability.radius:
			factor = ability.time_factor
	return factor


# --- Le venin ---------------------------------------------------------------------

func _add_venom(index: int, context: CombatContext, doses: int = 1,
		duration: float = VENOM_DURATION) -> void:
	if not context.enemy_alive(index) or context.is_structure(index):
		return
	var venom: Dictionary = _venom.get(index,
		{"doses": 0, "time_left": 0.0, "timer": VENOM_TICK, "plague": false})
	venom["doses"] = mini(VENOM_MAX, int(venom["doses"]) + doses)
	venom["time_left"] = maxf(float(venom["time_left"]), duration)
	_venom[index] = venom
	enemy_venomed.emit(index, int(venom["doses"]), float(venom["time_left"]))


## Doses qui prélèvent ensemble. Ni trait ni exaltation : ce n'est pas un coup porté.
func _update_venom(delta: float, context: CombatContext) -> void:
	for index in _venom_locks.keys():
		_venom_locks[index] = float(_venom_locks[index]) - delta
		if float(_venom_locks[index]) <= 0.0:
			_venom_locks.erase(index)
	for index in _venom.keys():
		if not context.enemy_alive(index):
			_venom.erase(index)
			continue
		var venom: Dictionary = _venom[index]
		venom["time_left"] = float(venom["time_left"]) - delta
		venom["timer"] = float(venom["timer"]) - delta
		if float(venom["timer"]) <= 0.0:
			venom["timer"] = VENOM_TICK
			_apply_damage(index, Ability.make({"id": "venin", "display_name": "Venin",
				"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.POISON,
				"damage": int(venom["doses"]) * VENOM_DAMAGE}), context, false, false)
			if not context.enemy_alive(index):
				venom_killed.emit(context.enemy_cells[index])
				if bool(venom["plague"]) and _plague != null:
					_cloud_zone(context.enemy_cells[index], _plague)
				_venom.erase(index)
				continue
		if float(venom["time_left"]) <= 0.0:
			_venom.erase(index)
			enemy_venomed.emit(index, 0, 0.0)


## Une flaque ne pose qu'une dose par seconde : la traverser coûte moins que s'y attarder.
func _update_puddles(delta: float, context: CombatContext) -> void:
	_seep_left = maxf(0.0, _seep_left - delta)
	if _puddles.is_empty():
		return
	for cell in _puddles.keys():
		_puddles[cell] = float(_puddles[cell]) - delta
		if float(_puddles[cell]) <= 0.0:
			_puddles.erase(cell)
	for i in context.enemy_cells.size():
		if _venom_locks.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		if _puddles.has(context.enemy_cells[i]):
			_venom_locks[i] = VENOM_TICK
			_add_venom(i, context)
			puddle_stepped.emit(context.enemy_cells[i])


func _apply_zone_venom(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if _venom_locks.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_venom_locks[i] = VENOM_TICK
		_add_venom(i, context, ability.venom_doses)


## Le nuage que laissent la Brume et ce qui éclate : une zone sans dégâts, qui empoisonne.
func _cloud_zone(cell: Vector2i, source: Ability) -> void:
	var id := _next_zone_id
	_next_zone_id += 1
	var cloud := Ability.make({"id": "nuage_toxique", "kind": Ability.Kind.ZONE,
		"element": Element.Kind.POISON, "radius": source.cloud_radius,
		"duration": source.cloud_duration, "venom_doses": 1, "zone_style": "gaz_peint"})
	_zones.append({"id": id, "ability": cloud, "cell": cell,
		"time_left": source.cloud_duration, "tick": 0.0})
	zone_created.emit(id, cloud, cell)


## Le foyer est l'ennemi empoisonné le plus proche du mage, dans la portée du sort.
func _cast_contagion(ability: Ability, context: CombatContext) -> bool:
	var source := -1
	var best := ability.range + 1
	for index: int in _venom.keys():
		if not context.enemy_alive(index):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[index])
		if distance >= 0 and distance < best:
			best = distance
			source = index
	if source < 0:
		use_refused.emit("sain")
		return false
	var field := _field_from(context.enemy_cells[source])
	var spread := false
	for i in context.enemy_cells.size():
		if i == source or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or distance > ability.chain_range:
			continue
		_add_venom(i, context, int(_venom[source]["doses"]))
		contagion_spread.emit(context.enemy_cells[source], context.enemy_cells[i])
		spread = true
	if not spread:
		use_refused.emit("sain")
	return spread


func _cast_transfusion(ability: Ability, context: CombatContext) -> bool:
	if health.current >= health.maximum:
		use_refused.emit("pleine")
		return false
	var cells: Array = []
	for index: int in _venom.keys():
		if context.enemy_alive(index):
			cells.append(context.enemy_cells[index])
	if cells.is_empty():
		use_refused.emit("sain")
		return false
	var gained := health.heal(ceili(float(cells.size()) / float(maxi(1, ability.transfuse_per))))
	player_healed.emit(gained)
	transfused.emit(cells, gained)
	return true


func _cast_pandemic(ability: Ability, context: CombatContext) -> void:
	_plague = ability
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			_add_venom(i, context, VENOM_MAX, ability.duration)
			_venom[i]["plague"] = true
	pandemic_cast.emit(context.player_cell)


## Combien de doses porte cette créature ? L'interface et les tests s'en servent.
func venom_doses(index: int) -> int:
	return int(_venom[index]["doses"]) if _venom.has(index) else 0


# --- La lumière -------------------------------------------------------------------

## `force` passe le verrou : seule l'Aube y a droit, c'est son privilège d'ultime.
func _blind(index: int, duration: float, context: CombatContext, force: bool = false) -> void:
	if not context.enemy_alive(index) or context.is_structure(index):
		return
	if _blind_locks.has(index) and not force:
		return
	_blind_locks[index] = duration + BLIND_LOCK
	enemy_blinded.emit(index, duration)


func _update_light(delta: float, context: CombatContext) -> void:
	for index in _blind_locks.keys():
		_blind_locks[index] = float(_blind_locks[index]) - delta
		if float(_blind_locks[index]) <= 0.0:
			_blind_locks.erase(index)
	for i in range(_dawn.size() - 1, -1, -1):
		var strike: Dictionary = _dawn[i]
		strike["time_left"] = float(strike["time_left"]) - delta
		if float(strike["time_left"]) > 0.0:
			continue
		var index := int(strike["index"])
		var ability: Ability = strike["ability"]
		_dawn.remove_at(i)
		if not context.enemy_alive(index):
			continue
		dawn_struck.emit(context.enemy_cells[index])
		_apply_damage(index, ability, context, false)
		if ability.blind_seconds > 0.0:
			_blind(index, ability.blind_seconds, context, true)


func _blind_around(cell: Vector2i, ability: Ability, context: CombatContext) -> void:
	var field := _field_from(cell)
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance <= ability.blind_radius:
			_blind(i, ability.blind_seconds, context)


func _apply_zone_blind(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and float(distance) <= ability.radius:
			_blind(i, ability.blind_seconds, context)


## La coque a absorbé son coup : l'éclair aveugle ce qui se tient au contact.
func _burst_wings(context: CombatContext) -> void:
	wings_burst.emit(context.player_cell)
	_blind_around(context.player_cell, _wings, context)


func _cast_beam(ability: Ability, context: CombatContext) -> bool:
	var cells := _beam_path(ability.range, context)
	if cells.is_empty():
		use_refused.emit("mur")
		return false
	beam_fired.emit(context.player_cell, cells)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and cells.has(context.enemy_cells[i]):
			_apply_damage(i, ability, context)
	return true


## Le trajet de la Lance : elle part là où regarde le mage, puis file vers la proie la plus
## proche par les couloirs, en passe à la suivante, et sans proie continue devant elle. Elle ne
## repasse jamais sur ses pas : le regard du mage décide donc du côté qu'elle prend.
func _beam_path(limit: int, context: CombatContext) -> Array[Vector2i]:
	var prey := {}
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			prey[context.enemy_cells[i]] = true
	var path: Array[Vector2i] = []
	var walked := {context.player_cell: true}
	var cell: Vector2i = context.player_cell
	var dir: Vector2i = context.player_facing
	if grid.is_floor_v(cell + dir):
		cell += dir
		path.append(cell)
		walked[cell] = true
		prey.erase(cell)
	while path.size() < limit:
		var leg := _beam_leg(cell, walked, prey, limit - path.size())
		if leg.is_empty():
			var onward := _beam_onward(cell, dir, walked)
			if onward == Vector2i.ZERO:
				break
			leg.append(cell + onward)
		for step in leg:
			dir = step - cell
			cell = step
			path.append(cell)
			walked[cell] = true
			prey.erase(cell)
	return path


## Le plus court chemin libre jusqu'à la proie la plus proche, vide s'il n'y en a pas à portée.
func _beam_leg(from: Vector2i, walked: Dictionary, prey: Dictionary, limit: int) -> Array[Vector2i]:
	var came := {from: from}
	var frontier: Array[Vector2i] = [from]
	for depth in limit:
		var next: Array[Vector2i] = []
		for cell in frontier:
			for neighbour in grid.floor_neighbors(cell):
				if came.has(neighbour) or walked.has(neighbour):
					continue
				came[neighbour] = cell
				if prey.has(neighbour):
					var leg: Array[Vector2i] = []
					var back: Vector2i = neighbour
					while back != from:
						leg.push_front(back)
						back = came[back]
					return leg
				next.append(neighbour)
		frontier = next
	return []


## La direction sans proie : tout droit, sinon le virage libre, sinon demi-tour au départ.
func _beam_onward(cell: Vector2i, dir: Vector2i, walked: Dictionary) -> Vector2i:
	for way: Vector2i in [dir, Vector2i(dir.y, dir.x), Vector2i(-dir.y, -dir.x), -dir]:
		if grid.is_floor_v(cell + way) and not walked.has(cell + way):
			return way
	return Vector2i.ZERO


func _cast_dawn(ability: Ability, context: CombatContext) -> void:
	dawn_cast.emit(context.player_cell)
	var wait := DAWN_DELAY
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			_dawn.append({"index": i, "time_left": wait, "ability": ability})
			wait += DAWN_GAP


# --- Les étoiles -------------------------------------------------------------------

func _add_star_mark(index: int, ability: Ability, context: CombatContext) -> void:
	if not context.enemy_alive(index):
		return
	var count := int(_star_marks.get(index, 0)) + 1
	if count < ASTRE_MARKS:
		_star_marks[index] = count
		enemy_star_marks.emit(index, count)
		return
	_star_marks.erase(index)
	enemy_star_marks.emit(index, 0)
	astre_burst.emit(context.enemy_cells[index])
	var burst := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
		"damage": ASTRE_DAMAGE})
	# Sans trait : l'explosion ne doit pas reposer une étoile sur la cible qu'elle vient de vider.
	_apply_damage(index, burst, context, false, false)


func _cast_constellation(ability: Ability, context: CombatContext) -> bool:
	for star in _stars:
		if star["cell"] == context.player_cell:
			use_refused.emit("occupé")
			return false
	if _stars.size() >= STAR_MAX:
		_stars.pop_front()
	_stars.append({"cell": context.player_cell, "time_left": ability.duration, "ability": ability})
	_report_stars()
	return true


func _report_stars() -> void:
	var cells: Array = []
	for star in _stars:
		cells.append(star["cell"])
	stars_changed.emit(cells)


func _update_stars(delta: float, context: CombatContext) -> void:
	for i in range(_falling.size() - 1, -1, -1):
		var fall: Dictionary = _falling[i]
		fall["time_left"] = float(fall["time_left"]) - delta
		if not fall["warned"] and float(fall["time_left"]) <= STAR_FALL_LEAD:
			fall["warned"] = true
			star_falling.emit(fall["cell"], STAR_FALL_LEAD)
		if float(fall["time_left"]) <= 0.0:
			_falling.remove_at(i)
			_apply_area(fall["ability"], fall["cell"], context, null, false, false)
	if _stars.is_empty():
		return
	var faded := false
	for i in range(_stars.size() - 1, -1, -1):
		_stars[i]["time_left"] = float(_stars[i]["time_left"]) - delta
		if float(_stars[i]["time_left"]) <= 0.0:
			_stars.remove_at(i)
			faded = true
	if faded:
		_report_stars()
	_star_tick -= delta
	if _star_tick > 0.0 or _stars.is_empty():
		return
	_star_tick = STAR_TICK
	var ability: Ability = _stars[0]["ability"]
	# Comme une zone : l'usure est exprimée par seconde, et n'a ni trait ni exaltation.
	var slice := Ability.make({"id": ability.id, "kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": int(round(float(ability.damage) * STAR_TICK))})
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i) \
				and _on_star_ray(Vector2(context.enemy_cells[i])):
			_apply_damage(i, slice, context, false, false)


## À vol d'oiseau : les rayons passent par-dessus les haies, et le joueur juge à ce qu'il voit.
func _on_star_ray(at: Vector2) -> bool:
	for a in _stars.size():
		var from := Vector2(_stars[a]["cell"])
		if at.distance_to(from) <= STAR_REACH:
			return true
		for b in range(a + 1, _stars.size()):
			var closest := Geometry2D.get_closest_point_to_segment(at, from, Vector2(_stars[b]["cell"]))
			if at.distance_to(closest) <= STAR_REACH:
				return true
	return false


## Les ennemis à portée d'abord, puis des cases libres du cercle tirées au sort.
func _cast_starfall(ability: Ability, context: CombatContext) -> bool:
	var field := _field_from(context.player_cell)
	var targets: Array[Vector2i] = []
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if context.enemy_alive(i) and not context.is_structure(i) \
				and distance >= 0 and float(distance) <= ability.radius:
			targets.append(context.enemy_cells[i])
	var floor_cells: Array[Vector2i] = []
	var reach := int(ceil(ability.radius))
	for y in range(-reach, reach + 1):
		for x in range(-reach, reach + 1):
			var cell: Vector2i = context.player_cell + Vector2i(x, y)
			var distance := Pathfinder.value_at(grid, field, cell)
			if distance > 0 and float(distance) <= ability.radius:
				floor_cells.append(cell)
	if floor_cells.is_empty():
		use_refused.emit("mur")
		return false
	var noise := RandomNumberGenerator.new()
	noise.seed = hash(context.player_cell) + _next_zone_id
	var hit := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.damage, "radius": 1.0})
	for n in ability.star_falls:
		var cell: Vector2i = targets[n] if n < targets.size() \
			else floor_cells[noise.randi() % floor_cells.size()]
		_falling.append({"cell": cell, "ability": hit, "warned": false,
			"time_left": STAR_FALL_LEAD + float(n) * STAR_FALL_GAP})
	return true


func _burn_trail(from: Vector2i, to: Vector2i, ability: Ability, context: CombatContext) -> void:
	star_trail.emit(from, to)
	var burn := Ability.make({"id": ability.id, "kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": ability.trail_damage})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var at := Vector2(context.enemy_cells[i])
		var closest := Geometry2D.get_closest_point_to_segment(at, Vector2(from), Vector2(to))
		if at.distance_to(closest) <= STAR_REACH:
			_apply_damage(i, burn, context, false, false)


# --- La mort ----------------------------------------------------------------------

## Le coup de grâce : sous le seuil du sort, ou du trait s'il n'en a pas, l'ennemi est achevé.
## Les repaires n'ont pas de vie à prendre, seulement des murs à abattre.
func _sentence(index: int, ability: Ability, context: CombatContext) -> void:
	if not context.enemy_alive(index) or context.is_structure(index):
		return
	var life: Health = context.enemy_health[index]
	var below := ability.execute_below if ability.execute_below > 0.0 else SENTENCE_BELOW
	if float(life.current) > float(life.maximum) * below:
		return
	enemy_sentenced.emit(index)
	enemy_damaged.emit(index, life.take(Damage.new(life.current, ability.element, "player")), ability)


func _gain_soul() -> void:
	if _souls < SOUL_MAX:
		_souls += 1
		souls_changed.emit(_souls)


func _update_death(delta: float, context: CombatContext) -> void:
	for index in _marked.keys():
		_marked[index] = float(_marked[index]) - delta
		if float(_marked[index]) <= 0.0:
			_marked.erase(index)
	for i in range(_flying.size() - 1, -1, -1):
		var soul: Dictionary = _flying[i]
		soul["time_left"] = float(soul["time_left"]) - delta
		if float(soul["time_left"]) > 0.0:
			continue
		_flying.remove_at(i)
		var prey := int(soul["index"])
		if context.enemy_alive(prey):
			soul_struck.emit(context.enemy_cells[prey])
			_apply_damage(prey, soul["ability"], context)
	for i in range(_hour.size() - 1, -1, -1):
		var strike: Dictionary = _hour[i]
		strike["time_left"] = float(strike["time_left"]) - delta
		if float(strike["time_left"]) <= 0.0:
			_hour.remove_at(i)
			_strike_last_hour(int(strike["index"]), strike["ability"], context)


func _apply_zone_mark(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and float(distance) <= ability.radius:
			_marked[i] = ability.mark_seconds
			enemy_marked.emit(i, ability.mark_seconds)


## Une âme de base et toutes celles récoltées, une par proie, les plus proches d'abord. Sans
## proie à portée, le sort est refusé et les âmes restent : il ne se gaspille pas dans le vide.
func _cast_souls(ability: Ability, context: CombatContext) -> bool:
	var preys: Array[int] = []
	var distances := {}
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance <= ability.range:
			preys.append(i)
			distances[i] = distance
	if preys.is_empty():
		use_refused.emit("cible")
		return false
	preys.sort_custom(func(a: int, b: int) -> bool: return int(distances[a]) < int(distances[b]))
	for n in 1 + _souls:
		var prey: int = preys[n % preys.size()]
		var path := trajectory(context.player_cell, context.enemy_cells[prey])
		var duration := float(path.size()) / SOUL_SPEED + float(n) * SOUL_GAP
		_flying.append({"index": prey, "time_left": duration, "ability": ability})
		soul_sent.emit(path, duration)
	_souls = 0
	souls_changed.emit(0)
	return true


func _cast_last_hour(ability: Ability, context: CombatContext) -> void:
	last_hour_cast.emit(context.player_cell)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			var across := float(context.enemy_cells[i].x) / float(maxi(1, grid.cols))
			_hour.append({"index": i, "ability": ability,
				"time_left": HOUR_DELAY + HOUR_SWEEP * across})


func _strike_last_hour(index: int, ability: Ability, context: CombatContext) -> void:
	if not context.enemy_alive(index):
		return
	var life: Health = context.enemy_health[index]
	last_hour_struck.emit(context.enemy_cells[index])
	var share := ceili(float(life.current) * HOUR_SHARE)
	enemy_damaged.emit(index, life.take(Damage.new(share, ability.element, "player")), ability)
	_sentence(index, ability, context)
	if not context.enemy_alive(index):
		_marked.erase(index)
		_gain_soul()
		enemy_killed.emit(index)


# --- Invocations ------------------------------------------------------------------

func _cast_summon(ability: Ability, context: CombatContext) -> bool:
	if not SUMMON_KINDS.has(ability.summon_id):
		push_error("Créature d'invocation inconnue : " + ability.summon_id)
		return false
	if ability.summon_portals > 0:
		return _tear_rifts(ability, context)
	for i in maxi(1, ability.summon_count):
		# Les créatures naissent autour du mage, chacune sur sa case praticable :
		# empilées sur la sienne, on ne verrait qu'une seule invocation.
		var cell := _summon_spawn_cell(context, i)
		var summon := {
			"id": _next_summon_id, "kind": ability.summon_id,
			"position": Vector2(cell) , "cell": cell,
			"time_left": ability.duration, "strike_in": 0.6,
			"facing": Vector2i.DOWN, "target": -1,
		}
		_next_summon_id += 1
		_summons.append(summon)
		summon_spawned.emit(int(summon["id"]), ability.summon_id, summon["position"])
	# La plus ancienne cède la place au-delà du plafond — jamais la nouvelle :
	# un sort qui échoue parce qu'on l'a déjà lancé se lit comme une panne.
	while _summons.size() > MAX_SUMMONS:
		var oldest: Dictionary = _summons.pop_front()
		summon_expired.emit(int(oldest["id"]))
	# Le champ des proies est immédiatement rafraîchi : une créature qui reste
	# plantée une tierce de seconde à sa naissance a l'air cassée.
	_summon_field_timer = 0.0
	return true



## LA FAILLE DES TÉNÈBRES : des portes s'ouvrent SUR LES PROIES.
##
## L'ultime ne fait pas venir des créatures, il ouvre un ENDROIT. C'est ce qui le
## sépare de l'Invocateur, dont les bêtes naissent aux pieds du mage et doivent
## traverser le labyrinthe : ici le trajet est déjà fait, la porte s'ouvre au
## contact de ce qu'elle vient chasser.
##
## Une porte par créature, les plus proches d'abord, plafonnées à
## `summon_portals`. Autant de portes que d'ennemis viderait un stage tardif
## d'un seul geste — l'ultime cesserait d'être un coup pour devenir la fin de la
## partie.
##
## Les portes ne s'ouvrent PAS sur la case de la proie mais à côté : une ombre
## née sous les pieds d'un ennemi serait invisible, et deux sprites empilés ne
## disent ni qui frappe ni ce qui est frappé — la même règle que le refus du
## dernier pas des poursuivants.
func _tear_rifts(ability: Ability, context: CombatContext) -> bool:
	var prey := _closest_prey(ability.summon_portals, context)
	if prey.is_empty():
		# AUCUNE PROIE : le sort est refusé et ne coûte rien. Un ultime dépensé
		# dans un couloir vide serait un vol pur — il se gagne en quatre kills.
		use_refused.emit("cible")
		return false
	for index in prey:
		var door := _rift_cell(context.enemy_cells[index])
		rift_opened.emit(door)
		for i in maxi(1, ability.summon_count):
			var cell := _rift_spawn_cell(door, i)
			var summon := {
				"id": _next_summon_id, "kind": ability.summon_id,
				"position": Vector2(cell), "cell": cell,
				"time_left": ability.duration, "strike_in": 0.6,
				"facing": Vector2i.DOWN, "target": -1,
			}
			_next_summon_id += 1
			_summons.append(summon)
			summon_spawned.emit(int(summon["id"]), ability.summon_id, summon["position"])
	var cap := maxi(MAX_SUMMONS, ability.summon_cap)
	while _summons.size() > cap:
		var oldest: Dictionary = _summons.pop_front()
		summon_expired.emit(int(oldest["id"]))
	_summon_field_timer = 0.0
	return true


## Les N créatures vivantes les plus proches du mage, en distance de chemin.
##
## Les plus proches et non les plus faibles : le joueur lance son ultime en
## voyant une meute lui arriver dessus, et les portes doivent s'ouvrir sur CETTE
## meute-là. Un ciblage malin qui irait chercher le blessé à l'autre bout du
## labyrinthe se lirait comme un bug.
func _closest_prey(count: int, context: CombatContext) -> Array[int]:
	var field := _field_from(context.player_cell)
	var scored: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0:
			continue
		scored.append({"index": i, "distance": distance})
	scored.sort_custom(func(a, b): return int(a["distance"]) < int(b["distance"]))
	var chosen: Array[int] = []
	for entry in scored:
		if chosen.size() >= maxi(1, count):
			break
		chosen.append(int(entry["index"]))
	return chosen


## La case de la porte : voisine de la proie, praticable. À défaut, la sienne —
## mieux vaut une porte mal placée qu'un ultime qui n'ouvre rien.
func _rift_cell(prey: Vector2i) -> Vector2i:
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(prey + step):
			return prey + step
	return prey


func _rift_spawn_cell(door: Vector2i, offset: int) -> Vector2i:
	var candidates: Array[Vector2i] = [door]
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(door + step):
			candidates.append(door + step)
	return candidates[offset % candidates.size()]


func _summon_spawn_cell(context: CombatContext, offset: int) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + step):
			candidates.append(context.player_cell + step)
	if candidates.is_empty():
		return context.player_cell
	return candidates[offset % candidates.size()]


func _update_summons(delta: float, context: CombatContext) -> void:
	if _summons.is_empty():
		return
	_summon_field_timer -= delta
	if _summon_field_timer <= 0.0:
		_summon_field_timer = SUMMON_FIELD_REFRESH
		_refresh_summon_field(context)

	for i in range(_summons.size() - 1, -1, -1):
		var summon: Dictionary = _summons[i]
		summon["time_left"] = float(summon["time_left"]) - delta
		if float(summon["time_left"]) <= 0.0:
			_summons.remove_at(i)
			summon_expired.emit(int(summon["id"]))
			continue
		summon["strike_in"] = maxf(0.0, float(summon["strike_in"]) - delta)
		var stats: Dictionary = SUMMON_KINDS[summon["kind"]]
		var target := _nearest_prey(summon, context)
		summon["target"] = target
		if target >= 0 and _try_strike(summon, stats, target, context):
			continue
		_advance_summon(summon, stats, target, delta, context)


func _update_summon_projectiles(delta: float, context: CombatContext) -> void:
	for i in range(_summon_projectiles.size() - 1, -1, -1):
		var shot: Dictionary = _summon_projectiles[i]
		shot["time_left"] = float(shot["time_left"]) - delta
		if float(shot["time_left"]) > 0.0:
			continue
		_summon_projectiles.remove_at(i)
		var target := int(shot["target"])
		if target < 0 or not context.enemy_alive(target):
			continue
		var ability: Ability = shot["ability"]
		summon_projectile_hit.emit(int(shot["id"]), target,
			context.enemy_cells[target], ability)
		_apply_damage(target, ability, context, false)


## La proie : l'ennemi vivant le plus proche. À VOL D'OISEAU pour le dragon qui
## vole, en distance de couloir pour les marcheurs — chacun sa géométrie.
func _nearest_prey(summon: Dictionary, context: CombatContext) -> int:
	var best := -1
	var best_score := 1e9
	var position: Vector2 = summon["position"]
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var score := position.distance_to(Vector2(context.enemy_cells[i]))
		if score < best_score:
			best_score = score
			best = i
	return best


func _try_strike(summon: Dictionary, stats: Dictionary, target: int,
		context: CombatContext) -> bool:
	var reach := float(stats["reach"])
	var position: Vector2 = summon["position"]
	var distance := position.distance_to(Vector2(context.enemy_cells[target]))
	var min_reach := float(stats.get("min_reach", 0.0))
	if distance > reach or distance < min_reach:
		return false
	if float(summon["strike_in"]) > 0.0:
		return true
	summon["strike_in"] = float(stats["period"])
	if summon["kind"] == "dragon":
		var aim := Vector2(context.enemy_cells[target]) - position
		if absf(aim.x) > absf(aim.y):
			summon["facing"] = Vector2i.RIGHT if aim.x > 0.0 else Vector2i.LEFT
		else:
			summon["facing"] = Vector2i.DOWN if aim.y > 0.0 else Vector2i.UP
		summon_moved.emit(int(summon["id"]), position, summon["facing"])
	summon_struck.emit(int(summon["id"]), target)
	if summon["kind"] == "dragon":
		var ability := Ability.make({
			"id": "dragon_fire_breath", "display_name": "Souffle du dragon",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": int(stats["damage"]), "projectile_speed": float(stats["projectile_speed"]),
			"projectile_scale": 1.65, "trail_density": 0.9, "flames": 1.15,
			"pierces_walls": true,
		})
		var speed := PROJECTILE_SPEED * float(stats["projectile_speed"])
		var duration := maxf(0.12, distance / speed)
		_summon_projectiles.append({"id": int(summon["id"]), "target": target,
			"time_left": duration, "ability": ability})
		summon_projectile_launched.emit(int(summon["id"]), target, position,
			Vector2(context.enemy_cells[target]), duration, ability)
		return true
	# Les coups d'une créature ne déclenchent PAS de trait élémentaire : le
	# trait est la signature du mage, pas celle de ses bêtes — et un dragon qui
	# répandrait la brûlure du Feu brouillerait la lecture des personnages.
	var blow := Ability.make({
		"id": "summon_" + str(summon["kind"]), "kind": Ability.Kind.ZONE,
		"element": Element.Kind.SHADOW, "damage": int(stats["damage"]),
	})
	_apply_damage(target, blow, context, false)
	# LE GAZ EMPOISONNE. C'est ce qui fait d'un souffle autre chose qu'une
	# morsure à distance : il ne compte pas sur le coup mais sur ce qu'il laisse,
	# et six ombres qui empoisonnent la même créature ne l'empoisonnent pas six
	# fois — la pose la plus récente remplace la précédente, comme une flaque.
	if stats.has("poison") and context.enemy_alive(target):
		_poisoned[target] = {"time_left": POISON_TICK * 6.0,
			"timer": POISON_TICK, "damage": int(stats["poison"])}
		enemy_poisoned.emit(target, POISON_TICK * 6.0)
	return true


func _advance_summon(summon: Dictionary, stats: Dictionary, target: int,
		delta: float, context: CombatContext) -> void:
	var position: Vector2 = summon["position"]
	var step := Vector2.ZERO
	if bool(stats["flies"]):
		# Le dragon ignore les murs : droit sur la proie, meme en diagonale.
		if target >= 0:
			step = (Vector2(context.enemy_cells[target]) - position)
			if float(stats.get("min_reach", 0.0)) > 0.0 and \
				position.distance_to(Vector2(context.enemy_cells[target])) < float(stats["min_reach"]):
				step = -step
	else:
		# Les marcheurs descendent le champ des proies, couloir par couloir.
		_walk_summon(summon, float(stats["speed"]) * delta, context)
		return
	if step.length() < 0.05:
		return
	step = step.normalized() * minf(float(stats["speed"]) * delta, step.length())
	summon["position"] = position + step
	if absf(step.x) > absf(step.y):
		summon["facing"] = Vector2i.RIGHT if step.x > 0.0 else Vector2i.LEFT
	elif step.y != 0.0:
		summon["facing"] = Vector2i.DOWN if step.y > 0.0 else Vector2i.UP
	summon_moved.emit(int(summon["id"]), summon["position"], summon["facing"])


## Un marcheur va au CENTRE de la case qu'il a choisie avant d'en choisir une autre.
##
## Il rechoisissait à chaque image depuis la case la plus proche : passé le milieu d'une
## case d'angle, il partait en diagonale à travers le coin de la haie, et chaque nouveau
## champ des proies pouvait le faire revenir sur ses pas au milieu d'un couloir.
func _walk_summon(summon: Dictionary, travel: float, context: CombatContext) -> void:
	var position: Vector2 = summon["position"]
	var heading := Vector2.ZERO
	# Deux passages au plus : ce qui reste du pas à l'arrivée sert sur la case suivante,
	# sans quoi une image longue ralentirait la créature.
	for _i in 2:
		if not summon.has("next") or position.is_equal_approx(Vector2(summon["next"])):
			var cell := Vector2i(position.round())
			var towards := Pathfinder.step_toward(grid, _summon_field, cell)
			if towards == Vector2i.ZERO:
				summon.erase("next")
				break
			summon["next"] = cell + towards
		var left: Vector2 = Vector2(summon["next"]) - position
		var moved := minf(travel, left.length())
		position = Vector2(summon["next"]) if moved >= left.length() \
			else position + left.normalized() * moved
		heading = left
		travel -= moved
		if travel <= 0.0:
			break
	if heading == Vector2.ZERO:
		return
	summon["position"] = position
	if absf(heading.x) > absf(heading.y):
		summon["facing"] = Vector2i.RIGHT if heading.x > 0.0 else Vector2i.LEFT
	else:
		summon["facing"] = Vector2i.DOWN if heading.y > 0.0 else Vector2i.UP
	summon_moved.emit(int(summon["id"]), position, summon["facing"])


func _refresh_summon_field(context: CombatContext) -> void:
	var sources: Array[Vector2i] = []
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			sources.append(context.enemy_cells[i])
	_summon_field = Pathfinder.distance_field(grid, sources) 		if not sources.is_empty() else PackedInt32Array()


## Le nombre de créatures encore en chasse — l'interface l'affiche.
func summon_count() -> int:
	return _summons.size()


# --- Dégâts ----------------------------------------------------------------------

## Deux freins, et il a fallu les SÉPARER.
##
## `with_trait` est faux pour les dégâts DÉRIVÉS — tick de brûlure, arc, écho.
## Sans lui, la brûlure rallumerait une brûlure et l'arc rebondirait d'ennemi en
## ennemi jusqu'au dernier : les traits ne se composent qu'avec le coup
## d'origine, jamais entre eux.
##
## `empowered` est faux pour les mêmes dégâts dérivés, mais PAS toujours en même
## temps que `with_trait`. Le cas qui a forcé la séparation : la Chaîne
## d'éclairs. C'est un sort qui chaîne DÉJÀ, donc son premier maillon ne doit
## pas déclencher en plus le trait de l'élément Foudre — sinon un arc
## supplémentaire part et une créature encaisse deux fois. Mais ce premier
## maillon, lui, doit bien profiter de l'exaltation du joueur. Un seul drapeau
## ne pouvait pas dire les deux.
func _apply_damage(index: int, ability: Ability, context: CombatContext,
		with_trait: bool = true, empowered: bool = true) -> void:
	if not context.enemy_alive(index):
		return
	# L'exaltation ne s'applique qu'au coup D'ORIGINE (`with_trait`), jamais aux
	# dégâts dérivés : sinon +10 s'ajouterait à chaque tic de brûlure, à chaque
	# arc et à chaque écho, et le bonus se multiplierait au lieu de s'ajouter.
	var power := ability.damage + (_empower_bonus if empowered else 0)
	if _marked.has(index):
		power = int(round(float(power) * (1.0 + MARK_BONUS)))
	var dealt := context.enemy_health[index].take(
		Damage.new(power, ability.element, "player"))
	enemy_damaged.emit(index, dealt, ability)
	if with_trait and dealt > 0 and ability.kind != Ability.Kind.ZONE \
			and not context.is_structure(index):
		_apply_trait(index, dealt, ability, context)
	if not context.enemy_health[index].is_alive():
		_marked.erase(index)
		if _star_marks.erase(index):
			enemy_star_marks.emit(index, 0)
		if ability.element == Element.Kind.DEATH:
			_gain_soul()
		enemy_killed.emit(index)


func _apply_trait(index: int, dealt: int, ability: Ability, context: CombatContext) -> void:
	match ability.element:
		Element.Kind.FIRE:
			if context.enemy_alive(index):
				var per_tick := maxi(1, int(round(dealt * BURN_RATIO / float(BURN_TICKS))))
				_burning[index] = {"ticks": BURN_TICKS, "timer": BURN_TICK, "damage": per_tick}
				enemy_burning.emit(index, BURN_TICKS * BURN_TICK)
		Element.Kind.WATER:
			if context.enemy_alive(index):
				enemy_soaked.emit(index, SOAK_DURATION, SOAK_FACTOR)
		Element.Kind.EARTH:
			if context.enemy_alive(index) and not _stagger_locks.has(index):
				_stagger_locks[index] = STAGGER_LOCK
				enemy_staggered.emit(index, STAGGER_DURATION)
		Element.Kind.SHADOW:
			if _leech_left <= 0.0:
				var gained := health.heal(LEECH_HEAL)
				if gained > 0:
					_leech_left = LEECH_LOCK
					player_healed.emit(gained)
		Element.Kind.THUNDER:
			_chain_to_neighbour(index, dealt, ability, context)
		Element.Kind.AIR:
			if context.enemy_alive(index):
				_push_away(index, context)
		Element.Kind.POISON:
			_add_venom(index, context)
		Element.Kind.LIGHT:
			_blind(index, GLARE_SECONDS, context)
		Element.Kind.DEATH:
			_sentence(index, ability, context)
		Element.Kind.STARS:
			_add_star_mark(index, ability, context)
		Element.Kind.TIME:
			if context.enemy_alive(index):
				enemy_soaked.emit(index, RETARD_DURATION, RETARD_FACTOR)
		Element.Kind.SUPREME:
			if context.enemy_alive(index):
				_echoes.append({"index": index, "time_left": ECHO_DELAY,
					"damage": maxi(1, int(round(dealt * ECHO_RATIO))), "ability": ability})


## L'arc de foudre : le coup saute à l'ennemi vivant le plus proche DE LA
## VICTIME — pas du mage. C'est ce qui fait du mage de la Foudre le spécialiste
## des meutes : plus les poursuivants se serrent, plus il rend cher ce
## regroupement.
func _chain_to_neighbour(index: int, dealt: int, ability: Ability,
		context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid,
		[context.enemy_cells[index]] as Array[Vector2i])
	var best := -1
	var best_distance := CHAIN_RANGE + 1
	for i in context.enemy_cells.size():
		if i == index or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	if best < 0:
		return
	chain_arced.emit(index, best)
	var arc := Ability.make({"id": ability.id + "_arc", "display_name": "Arc",
		"kind": ability.kind, "element": ability.element,
		"damage": maxi(1, int(round(dealt * CHAIN_RATIO)))})
	# Ni trait ni exaltation : c'est un dégât DÉRIVÉ du trait Foudre.
	_apply_damage(best, arc, context, false, false)


## La bourrasque : l'ennemi recule en SUIVANT le gradient de distance au mage —
## il est soufflé le long du couloir, jamais à travers une haie.
## LE GRAND SOUFFLE : tout ce qui entoure le mage part en arrière, et ce qui
## percute une paroi le paie.
##
## La projection réemploie le pas du souffle élémentaire, à ceci près qu'elle
## compte les cases RÉELLEMENT parcourues : une créature coincée contre la
## pierre après une seule case a été plaquée, et c'est là que le sort fait mal.
func _blow_away(ability: Ability, context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])
	for index in context.enemy_cells.size():
		if not context.enemy_alive(index) or context.is_structure(index):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[index])
		if distance < 0 or float(distance) > ability.radius:
			continue
		var travelled := _push_away(index, context, ability.blow_cells)
		if travelled >= ability.blow_cells or ability.slam_damage <= 0:
			continue
		# Course écourtée : elle a rencontré un mur. Le choc est un coup
		# DÉRIVÉ — il ne redéclenche ni le trait de l'élément (qui pousserait
		# une seconde fois) ni l'exaltation, déjà comptée sur le souffle.
		var slam := Ability.make({
			"id": ability.id, "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.slam_damage,
		})
		_apply_damage(index, slam, context, false, false)
		enemy_slammed.emit(index, context.enemy_cells[index])


func _push_away(index: int, context: CombatContext, cells: int = PUSH_CELLS) -> int:
	var cell: Vector2i = context.enemy_cells[index]
	var travelled := 0
	for _step in cells:
		var best := cell
		var here := Pathfinder.value_at(grid, context.player_field, cell)
		for direction in MazeGrid.NEIGHBORS:
			var next: Vector2i = cell + direction
			if not grid.is_floor_v(next) or grid.is_occupied(next):
				continue
			var value := Pathfinder.value_at(grid, context.player_field, next)
			if value > here:
				here = value
				best = next
		if best == cell:
			break
		cell = best
		travelled += 1
	if cell == context.enemy_cells[index]:
		return 0
	context.enemy_cells[index] = cell
	enemy_pushed.emit(index, cell)
	return travelled



## L'ombre INSPIRE : elle ramène à elle ce qu'elle attrape.
##
## Miroir exact de `_push_away`, et c'est voulu — l'Air écarte, l'Ombre ramène.
## Deux éléments qui déplaceraient dans le même sens ne se distingueraient plus
## l'un de l'autre.
##
## ⚠️ Le champ est recalculé depuis `player_cell` et NON pris dans
## `context.player_field`, qui est celui de l'IA et date de 300 ms. Sur un
## déplacement d'ennemi, un tiers de seconde de retard ramène vers l'endroit où
## le mage ÉTAIT — le même piège qui avait faussé l'arrêt au corps à corps. Le
## cache d'une frame fait que ça ne coûte qu'un BFS par lancer.
func _haul_in(ability: Ability, context: CombatContext) -> void:
	var field := _field_from(context.player_cell)
	for i in context.enemy_cells.size():
		# Les REPAIRES ne bougent pas : une maison qu'on tire à soi n'a pas de
		# sens, et la déplacer sortirait le décor de sa case.
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var reach := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if reach < 0 or float(reach) > ability.pull_radius:
			continue
		var cell: Vector2i = context.enemy_cells[i]
		for _step in ability.pull_cells:
			var here := Pathfinder.value_at(grid, field, cell)
			# ON S'ARRÊTE SUR L'ANNEAU, pas au contact. `pull_min` vaut au moins
			# 1 — jamais sur la case du mage, deux sprites superposés et l'on ne
			# voit plus ni qui frappe ni où l'on est — mais un sort qui
			# rassemble a intérêt à s'arrêter plus loin encore : déposé au
			# contact, le poursuivant frappe dans la seconde.
			if here <= maxi(1, ability.pull_min):
				break
			var best := cell
			for direction in MazeGrid.NEIGHBORS:
				var next: Vector2i = cell + direction
				if not grid.is_floor_v(next) or grid.is_occupied(next):
					continue
				var value := Pathfinder.value_at(grid, field, next)
				if value >= 0 and value < here:
					here = value
					best = next
			if best == cell:
				break
			cell = best
		if cell != context.enemy_cells[i]:
			context.enemy_cells[i] = cell
			enemy_hauled.emit(i, cell)


func _update_burns(delta: float, context: CombatContext) -> void:
	for index in _burning.keys():
		if not context.enemy_alive(index):
			_burning.erase(index)
			continue
		var burn: Dictionary = _burning[index]
		burn["timer"] = float(burn["timer"]) - delta
		if float(burn["timer"]) > 0.0:
			continue
		burn["timer"] = BURN_TICK
		burn["ticks"] = int(burn["ticks"]) - 1
		var tick := Ability.make({"id": "burn", "display_name": "Brûlure",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": int(burn["damage"])})
		# Ni trait ni exaltation : un tic de brûlure n'est pas un coup porté.
		_apply_damage(index, tick, context, false, false)
		if int(burn["ticks"]) <= 0:
			_burning.erase(index)



## LE POISON RONGE LOIN DE SA SOURCE.
##
## Calqué sur la brûlure, à trois différences près, et ce sont elles qui en font
## un autre effet : il dure dix fois plus longtemps, il ne dépend pas du coup qui
## l'a posé, et il SUIT sa victime — une créature qui sort de l'ombre l'emporte
## avec elle. C'est ce qui distingue « ne reste pas là » de « tu y es passé ».
##
## Se reposer le RENOUVELLE plutôt que de s'ajouter : deux flaques d'ombre qui
## se chevaucheraient doubleraient la cadence en silence, comme deux nuages
## d'orage l'avaient déjà fait.
func _update_poisons(delta: float, context: CombatContext) -> void:
	for index in _poisoned.keys():
		if not context.enemy_alive(index):
			_poisoned.erase(index)
			continue
		var poison: Dictionary = _poisoned[index]
		poison["time_left"] = float(poison["time_left"]) - delta
		poison["timer"] = float(poison["timer"]) - delta
		if float(poison["timer"]) <= 0.0:
			poison["timer"] = POISON_TICK
			var tick := Ability.make({"id": "poison", "display_name": "Poison d'ombre",
				"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SHADOW,
				"damage": int(poison["damage"])})
			# NI TRAIT NI EXALTATION. Le trait de l'Ombre est la Ponction : un
			# poison qui le déclencherait soignerait le mage une fois par seconde
			# et par créature empoisonnée, sans qu'il ait rien à faire.
			_apply_damage(index, tick, context, false, false)
		if float(poison["time_left"]) <= 0.0:
			_poisoned.erase(index)


## L'ombre empoisonne CE QU'ELLE TOUCHE, une fois par passage.
##
## Même verrou que le givre et le piège : une zone tique deux fois par seconde,
## et sans verrou elle repose le poison à chaque tic — la durée annoncée ne
## voudrait plus rien dire.
func _apply_poison(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _snare_locks.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_snare_locks[i] = POISON_TICK
		_poisoned[i] = {"time_left": ability.poison_duration,
			"timer": POISON_TICK, "damage": maxi(1, ability.poison_damage)}
		enemy_poisoned.emit(i, ability.poison_duration)


## L'OMBRE QUE L'EXPLOSION LAISSE DERRIÈRE ELLE.
##
## Une zone dérivée, fabriquée comme les pics de la ligne de terre : le sort
## d'origine n'a pas à être une zone, il lui suffit d'en décrire une. Elle ne
## reprend PAS les dégâts de l'explosion — une flaque qui referait 34 par seconde
## serait le vrai sort, et l'explosion son décor.
func _residue_of(ability: Ability) -> Ability:
	return Ability.make({
		"id": ability.id + "_ombre", "display_name": ability.display_name,
		"kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": 0, "radius": ability.radius,
		"duration": ability.residue_duration,
		"poison_duration": ability.poison_duration,
		"poison_damage": ability.poison_damage,
		"zone_style": "ombre",
	})


func _update_echoes(delta: float, context: CombatContext) -> void:
	for i in range(_echoes.size() - 1, -1, -1):
		_echoes[i]["time_left"] = float(_echoes[i]["time_left"]) - delta
		if float(_echoes[i]["time_left"]) > 0.0:
			continue
		var echo: Dictionary = _echoes[i]
		_echoes.remove_at(i)
		var source: Ability = echo["ability"]
		var index := int(echo["index"])
		# Une entrée « burn » n'est pas un écho : c'est la brûlure différée d'un
		# piège de zone, qui s'allume au moment où la créature est libérée.
		var burn_time := float(echo.get("burn", 0.0))
		if burn_time > 0.0:
			if context.enemy_alive(index):
				var ticks := maxi(1, int(round(burn_time / BURN_TICK)))
				var per_tick := maxi(1, int(round(source.damage * BURN_RATIO)))
				_burning[index] = {"ticks": ticks, "timer": BURN_TICK, "damage": per_tick}
				enemy_burning.emit(index, burn_time)
			continue
		var repeat := Ability.make({"id": source.id + "_echo", "display_name": "Écho",
			"kind": source.kind, "element": Element.Kind.SUPREME,
			"damage": int(echo["damage"])})
		# Ni trait ni exaltation : l'écho répète un coup, il n'en est pas un.
		_apply_damage(index, repeat, context, false, false)


## Explosions et zones : le rayon se mesure en DISTANCE DE CHEMIN, pas à vol
## d'oiseau. Une explosion qui traverse une haie pour toucher le couloir d'à côté
## serait incompréhensible dans un labyrinthe.
## `with_trait` à false quand le sort FAIT DÉJÀ ce que fait le trait de son
## élément. Le cas est né avec le Grand souffle : il projette de quatre cases,
## et le trait de l'Air en poussait deux de plus par-dessus. Les deux se
## cumulaient, donc la course réelle dépassait celle du sort et le choc contre
## la pierre se comptait de travers. Même raison que la Chaîne d'éclairs, qui ne
## déclenche pas l'arc de la Foudre.
func _apply_area(ability: Ability, centre: Vector2i, context: CombatContext,
		reported: Ability = null, with_trait: bool = true,
		empowered: bool = true) -> void:
	# UN ULTIME PASSE LES MURS. Ailleurs le rayon se mesure en distance de
	# chemin — une explosion ne doit pas traverser une haie. Ici on mesure à vol
	# d'oiseau : le souffle balaye le labyrinthe sans se soucier des couloirs.
	if ability.pierces_walls:
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i):
				continue
			if Vector2(context.enemy_cells[i] - centre).length() > ability.radius:
				continue
			_apply_damage(i, ability, context, with_trait, empowered)
			if reported != null and context.enemy_alive(i):
				enemy_damaged.emit(i, 0, reported)
		return

	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		if not _within_arc(ability, centre, context.enemy_cells[i], context):
			continue
		_apply_damage(i, ability, context, with_trait, empowered)
		if reported != null and context.enemy_alive(i):
			# La zone rapporte la compétence D'ORIGINE et non sa tranche : c'est
			# elle que l'interface et les effets doivent nommer.
			enemy_damaged.emit(i, 0, reported)


## La cible est-elle dans l'OUVERTURE du souffle ?
##
## Mesuré à vol d'oiseau depuis le lanceur, et non le long du couloir : une
## vague balaie ce qui est DEVANT, et le joueur juge « devant » à ce qu'il voit,
## pas à la topologie du labyrinthe.
func _within_arc(ability: Ability, centre: Vector2i, target: Vector2i,
		context: CombatContext) -> bool:
	if ability.arc <= 0.0 or ability.arc >= 360.0:
		return true
	var facing := Vector2(context.player_facing)
	if facing.length() < 0.01 or target == centre:
		return true
	var to_target := Vector2(target - centre)
	return absf(rad_to_deg(facing.angle_to(to_target))) <= ability.arc * 0.5


## Chemin case par case d'un projectile, du joueur à la cible : un BFS depuis la
## CIBLE puis une descente du gradient — le même mécanisme que la poursuite des
## ennemis, réutilisé tel quel.
func trajectory(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [from]
	if from == to:
		return path
	var field := Pathfinder.distance_field(grid, [to] as Array[Vector2i])
	var current := from
	for _step in grid.cols * grid.rows:
		var direction := Pathfinder.step_toward(grid, field, current)
		if direction == Vector2i.ZERO:
			break
		current += direction
		path.append(current)
		if current == to:
			break
	return path
