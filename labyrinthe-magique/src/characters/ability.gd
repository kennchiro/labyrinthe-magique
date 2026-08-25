class_name Ability
extends Resource

## Une compétence : attaque de base, sort, ou ultime.
##
## Tout est DONNÉE. Aucune compétence n'a de code à elle : c'est le CombatSystem
## qui sait exécuter chacune des sept formes ci-dessous. Ajouter un sort revient
## donc à écrire une ligne dans le catalogue, jamais une nouvelle classe — c'est
## ce qui rend cinq personnages réellement différents tenables.

enum Kind {
	PROJECTILE,   ## part vers une cible et lui fait des dégâts à l'impact
	BLAST,        ## explosion immédiate autour du lanceur ou d'un point
	ZONE,         ## surface qui blesse tant qu'on y reste (durée)
	SHIELD,       ## absorbe des dégâts pendant une durée
	HEAL,         ## rend des points de vie
	WALL,         ## bloque un couloir pendant une durée
	BLINK,        ## déplacement instantané
	SUMMON,       ## invoque des créatures qui chassent les ennemis (durée)
	WAVE,         ## un front qui DÉFERLE devant le lanceur et balaie son chemin
	CHAIN,        ## la foudre SAUTE d'un ennemi à l'autre, de proche en proche
	STORM,        ## un nuage qui SUIT le mage et foudroie tout seul
	LINE,         ## une gerbe qui COURT dans le couloir et reste plantée
	TURRET,       ## un cristal PLANTÉ qui tire tout seul tant qu'il tient
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var kind: Kind = Kind.PROJECTILE
@export var element: Element.Kind = Element.Kind.SHADOW

## Dégâts au centre de l'effet. Une ZONE les inflige PAR SECONDE, les autres en
## une fois — la distinction est portée par `kind`, pas par un second champ.
@export var damage: int = 0
## Rayon d'effet, en cases. 0 = cible unique.
@export var radius: float = 0.0
## Portée maximale, en distance de CHEMIN (les couloirs, pas le vol d'oiseau).
@export var range: int = 0
@export var cooldown: float = 1.0
## Durée pour ZONE, SHIELD, WALL et SUMMON. Ignorée par les autres.
@export var duration: float = 0.0
@export var is_ultimate: bool = false

## --- Signature visuelle -----------------------------------------------------
## Deux sorts de MÊME forme (deux PROJECTILE) se ressemblaient trait pour trait :
## le jeu donnait la même orbe à tous les projectiles d'un personnage. Le
## « Trait de flamme » et la « Boule de feu » étaient littéralement le même
## sprite. Ce qui distingue un sort lourd d'un sort léger — la taille, la
## lenteur, la traînée, l'onde de choc — appartient donc à la COMPÉTENCE.

## Taille du projectile, en multiple de la taille de base.
@export var projectile_scale: float = 1.0
## Vitesse du projectile, en multiple de `CombatSystem.PROJECTILE_SPEED`.
## Un sort lourd vole LENTEMENT : on le voit partir, et l'ennemi peut s'écarter.
## C'est du gameplay autant que du décor — la simulation d'équilibrage le voit.
@export var projectile_speed: float = 1.0
## Densité de la traînée de braises, 0 = aucune.
@export var trail_density: float = 0.0
## Le bouclier rend INTOUCHABLE au lieu d'absorber (forme SHIELD).
##
## Une réserve de dégâts et un répit ne se jouent pas pareil : la première se
## vide sous les coups, le second tient jusqu'à l'heure dite. Le Mage de la
## Terre a le second — c'est le seul du jeu.
@export var immune: bool = false

## LE GRAND SOUFFLE : de combien de cases il projette ce qu'il touche. Zéro =
## il ne projette pas.
@export var blow_cells: int = 0
## Dégâts SUPPLÉMENTAIRES pour qui percute une paroi avant d'avoir fini sa
## course. Le labyrinthe devient l'arme : souffler dans un couloir ouvert
## déplace, souffler contre un cul-de-sac tue.
@export var slam_damage: int = 0

## La zone AVANCE, en cases par seconde (forme ZONE). Zéro = elle reste posée.
##
## Une tornade qui ne bouge pas n'est pas une tornade — c'était la quatrième
## zone immobile du jeu. Celle-ci remonte le couloir toute seule.
@export var zone_travel: float = 0.0
## Ce qu'elle attrape VOYAGE avec elle au lieu de rester sur place.
##
## C'est le pilier de l'Air : le DÉPLACEMENT. Rien d'autre dans le jeu ne fait
## parcourir des cases à une créature — le trait de l'élément la pousse de deux
## cases, une fois.
@export var zone_carries: bool = false

## LE SÉISME : combien de temps le sol tremble, en secondes. Zéro = pas de
## séisme. Le tremblement DÉCROÎT tout seul sur cette durée.
@export var quake_duration: float = 0.0
## Dégâts PAR SECONDE du tremblement lui-même, sur tout ce qui tient debout
## dans le labyrinthe. Les éboulements frappent fort et par endroits ; la
## secousse, elle, n'épargne personne.
@export var quake_tremor: int = 0
## Secondes entre deux vagues d'éboulement.
@export var quake_interval: float = 0.6
## Éboulements par vague.
@export var quake_slides: int = 3
## Dégâts d'un éboulement, et son rayon en cases.
@export var quake_damage: int = 0
@export var quake_radius: float = 1.2

## L'orbe ne LANCE rien : il ouvre une faille dans le couloir vers sa proie
## (forme TURRET). C'est le balayage des Pics, déclenché tout seul.
@export var turret_sweep: bool = false

## Durée des gerbes plantées, en secondes. À zéro, elles durent le temps du
## sort — ce qui convient à une ligne lancée à la main, mais pas à un orbe qui
## reste trente secondes : ses gerbes doivent retomber entre deux balayages.
@export var spike_life: float = 0.0

## Les pics sont joués par la planche ANIMÉE, cristal et pierre en alternance
## (forme LINE). Sinon, c'est la gerbe unique de pierre.
@export var spike_anim: bool = false

## Le cristal ACCOMPAGNE le mage au lieu de rester planté (forme TURRET).
##
## Un cristal posé récompense le choix de l'endroit ; un cristal qui suit
## récompense le fait de tenir. Le second convient au mage lent : il ne peut
## pas revenir chercher ce qu'il a laissé derrière lui.
@export var turret_follows: bool = false

## Secondes entre deux éclats du cristal planté (forme TURRET).
@export var turret_interval: float = 1.3

## Vitesse de la gerbe, en cases par seconde (forme LINE). ZÉRO = d'un coup.
##
## Les Pics de terre courent : le joueur doit VOIR la fissure partir de ses
## pieds et filer dans le couloir, sinon la ligne se lit comme un dégât appliqué
## et non comme une éruption. La Faille de cristal, elle, SURGIT partout à la
## fois — c'est le même geste à deux vitesses, et ça donne deux sorts.
@export var line_speed: float = 12.0
## Dégâts PAR SECONDE des pics restés plantés (forme LINE).
##
## Séparés des dégâts de l'éruption : se prendre la gerbe dans la figure et
## marcher sur des pointes plantées ne sont pas le même coup.
@export var line_bite: int = 0

## Le tir est un ÉCLAIR et non une orbe qui vole.
##
## Une boule lumineuse qui traverse le couloir convient au Feu, à l'Eau, à
## l'Ombre. Elle ne convient pas à la Foudre : un éclair ne VOYAGE pas, il
## relie. Quand ce drapeau est levé, le tir est dessiné comme un trait brisé
## qui suit le couloir jusqu'à la cible — la mécanique, elle, ne change pas.
@export var bolt: bool = false
## Ce sort produit-il une onde de choc à l'impact ?
@export var shockwave: bool = false

## --- Piège de zone -----------------------------------------------------------
## Une zone qui RETIENT ce qui entre dedans, puis le laisse repartir en feu.
## C'est ce qui distingue un brasier d'une simple nappe de dégâts : on ne le
## traverse pas, on s'y fait prendre.
##
## Appliqué UNE FOIS par créature et par passage, jamais à chaque tick — un
## piège qui se réarme deux fois par seconde serait une paralysie définitive.

## Secondes d'immobilisation quand une créature entre dans la zone.
@export var snare: float = 0.0
## Secondes de brûlure APRÈS la libération. La créature repart, mais elle brûle.
@export var snare_burn: float = 0.0
## Densité des flammes animées de la zone, 0 = aucune.
@export var flames: float = 0.0

## --- Jugement céleste : des nuages sur toute la carte ------------------------
## L'ultime lève un ORAGE : plusieurs nuages se forment un peu partout dans le
## labyrinthe et foudroient chacun ce qui passe sous eux. Là où l'Embrasement du
## Feu fait tomber des météores UNE fois, celui-ci installe un ciel — les nuages
## restent, et frappent tant qu'ils sont là.
@export var sky_clouds: int = 0
@export var sky_duration: float = 0.0
@export var sky_interval: float = 1.2
## Rayon dans lequel un nuage cherche sa proie, en cases de chemin.
@export var sky_reach: int = 4

## --- Orage ---------------------------------------------------------------
## Le nuage SUIT le mage et frappe tout seul, à intervalle régulier.
##
## C'est la première chose du jeu qui ACCOMPAGNE le joueur au lieu de l'attendre
## quelque part : toutes les autres zones sont des endroits qu'on pose et qu'on
## quitte. Ça colle au Mage de la Foudre — le plus rapide et le plus fragile,
## celui qui doit rester en mouvement. Un sort qui le récompense de courir
## plutôt que de camper.

## Secondes entre deux décharges. Court, sinon le nuage est un décor.
@export var storm_interval: float = 0.9
## Portée d'une décharge, en cases de chemin depuis le MAGE : le nuage est
## au-dessus de lui et frappe ce qui l'entoure, il ne bombarde pas la carte.
@export var storm_range: int = 5

## --- Chaîne d'éclairs --------------------------------------------------------
## Nombre de RELAIS après la première cible. Le sort touchait une seule créature
## alors qu'il s'appelait « Chaîne d'éclairs » et promettait de sauter de l'une
## à l'autre : c'était le mensonge le plus voyant du catalogue.
@export var chain_jumps: int = 0
## Distance maximale d'un saut, en cases de CHEMIN. Courte : la chaîne
## récompense les ennemis groupés, elle ne traverse pas le labyrinthe.
@export var chain_range: int = 4
## Ce que chaque relais garde des dégâts du précédent. En dessous de 1, la
## chaîne s'épuise — sans quoi grouper cinq ennemis les tuerait tous d'un coup.
@export var chain_falloff: float = 0.75
## Temps entre deux relais. Nul, la chaîne est une explosion ; trop long, elle
## se lit comme cinq sorts distincts.
@export var chain_delay: float = 0.07

## Vitesse d'un front de WAVE, en cases par seconde.
##
## Une vague n'est ni une explosion ni un projectile : elle AVANCE, et on la
## voit venir. C'est ce qui la distingue d'un souffle instantané — l'ennemi a le
## temps de la voir arriver, et le joueur celui de la regarder faire son
## chemin. Trop vite, elle redevient une explosion ; trop lentement, on la
## contourne à la marche.
@export var wave_speed: float = 9.0

## Ouverture du souffle, en degrés. 0 = tout autour du lanceur.
##
## Une VAGUE balaie le couloir DEVANT le mage : elle n'explose pas autour de
## lui. Sans cette ouverture, tous les sorts de souffle du jeu étaient des
## novas et se ressemblaient — et le nom du sort promettait une direction que
## la mécanique ne tenait pas. Viser devient alors une décision.
@export var arc: float = 0.0

## Ralentissement infligé par une ZONE : durée en secondes, et part de la
## vitesse conservée (0,45 = l'ennemi va à 45 % de son allure).
##
## Comme le piège du brasier, il s'applique UNE FOIS par créature et par
## passage : une zone tique deux fois par seconde, et un ralentissement réarmé
## à chaque tick ne s'arrêterait jamais.
@export var slow_duration: float = 0.0
@export var slow_factor: float = 0.5

## Le ralentissement dure-t-il TANT QUE la créature reste dans la zone ?
##
## Par défaut un englu est un compte à rebours : on le prend en entrant, il
## s'épuise, et la créature retrouve son allure même immobile au milieu du
## sort. Soutenu, il est rafraîchi tant qu'elle est dedans et ne s'épuise
## qu'APRÈS la sortie — `slow_duration` cesse alors d'être la durée de l'effet
## pour devenir sa TRAÎNÉE, le temps qu'il faut pour retrouver son allure une
## fois dehors.
##
## C'est ce qui distingue un sort qui gêne d'un sort qui ENFERME : dans une
## rune soutenue, plus on s'attarde, plus on est lent à en sortir.
@export var slow_sustained: bool = false


## ASPIRATION : ce sort TIRE VERS LUI ce qu'il attrape, au lieu de l'écarter.
##
## `pull_radius` est la portée du souffle, `pull_cells` le nombre de cases dont
## chaque créature est ramenée. Les deux sont mesurés en distance de CHEMIN : on
## n'aspire pas à travers une haie.
##
## La portée du souffle est volontairement plus large que celle des dégâts. Un
## sort qui n'aspirerait que ce qu'il frappe déjà ne servirait à rien — c'est le
## fait de ramener de PLUS LOIN ce qu'on va frapper qui fait le sort : le joueur
## convertit de la distance en dégâts, et rassemble une meute avant de la punir.
@export var pull_radius: float = 0.0
@export var pull_cells: int = 0

## Distance que l'aspiration NE FRANCHIT PAS, en cases.
##
## Sans elle, le souffle dépose les poursuivants AU CONTACT du mage : il leur
## offre le coup qu'ils cherchaient. Mesuré en jeu — le dragonnet ramené touchait
## dans la seconde qui suivait. Un sort qui rassemble ne doit pas livrer son
## lanceur : il range la meute sur un anneau, à portée de l'explosion mais hors
## de portée des griffes.
##
## Elle ne REPOUSSE personne : une créature déjà au contact y reste. Le sort
## corrige ce qu'il provoque, pas ce qu'il trouve.
@export var pull_min: int = 1

## POISON déposé par une zone : durée en secondes, et dégâts par seconde.
##
## Distinct de la brûlure, qui est courte, violente et proportionnelle au coup
## qui l'a allumée. Le poison est long, faible et FIXE — il ne récompense pas la
## puissance du sort, il récompense le fait d'avoir tenu quelqu'un dans l'ombre.
## Il suit sa victime hors de la zone : ce qu'on emporte, on le garde.
@export var poison_duration: float = 0.0
@export var poison_damage: int = 0

## OMBRE RÉSIDUELLE : durée de la flaque laissée derrière une explosion.
##
## Une explosion qui laisse une trace n'est plus un instant, c'est un LIEU. Le
## sort cesse d'être un coup pour devenir un endroit où l'on ne veut pas être —
## et c'est ce qui donne sa valeur au fait d'y avoir rassemblé tout le monde.
@export var residue_duration: float = 0.0

## EXALTATION : ce sort renforce tous les autres pendant un temps.
##
## Un ultime n'est pas forcément une explosion. Celui de l'Eau installe un état :
## pendant sa durée, chaque coup du mage porte plus fort. C'est un ultime qui se
## joue APRÈS, là où celui du Feu se joue au moment où on l'appuie.
##
## Le bonus s'ajoute une seule fois, au coup d'origine — jamais aux dégâts
## DÉRIVÉS (brûlure, arc de foudre, écho, météore). Sans cette limite, une
## exaltation de +10 ajouterait +10 à chaque tic de brûlure et le bonus se
## multiplierait au lieu de s'ajouter.
@export var empower_bonus: int = 0
@export var empower_duration: float = 0.0

## Colonne de pression qui jaillit du sol au lancement.
@export var column_burst: bool = false

## Points de vie rendus au LANCEUR. Un sort peut blesser et soigner à la fois —
## c'est ce qui distingue un mage de survie d'un mage de dégâts.
@export var heal_self: int = 0

## Allure de la zone : "nappe", "brasier", "champ", "pics" ou "rune".
##
## Deux zones de feu du même mage se ressemblaient trait pour trait — même
## anneau orange, mêmes flammes. Or elles ne font pas le même métier, et la
## FORME doit le dire avant les chiffres :
##
##   nappe    elle S'ÉTALE. Basse, large, elle se répand au sol et s'éteint
##            vite. On la jette sous les pieds de quelqu'un.
##   brasier  il TIENT. Haut, resserré, cerné d'un anneau net qui montre où il
##            mord. On l'installe et on le laisse travailler.
@export var zone_style: String = "nappe"

## --- Privilèges d'ULTIME -----------------------------------------------------
## Ce que seul un ultime a le droit de faire. Les valeurs par défaut donnent le
## comportement normal ; un sort ordinaire n'y touche jamais.

## L'onde traverse-t-elle les HAIES ?
##
## Le jeu applique partout ses dégâts de zone en distance de CHEMIN : une
## explosion qui passerait à travers une haie pour toucher le couloir d'à côté
## serait incompréhensible. Un ultime, lui, a le droit — c'est même ce qui le
## rend ultime : la seule chose du jeu contre laquelle un mur ne protège pas.
##
## À une condition, et elle n'est pas négociable : que ça SE VOIE. L'onde de
## choc doit balayer l'écran par-dessus le labyrinthe, sinon le joueur croit à
## un bug plutôt qu'à une règle.
@export var pierces_walls: bool = false

## Pluie de météores : combien tombent, où et pour combien.
## Elles tombent AU HASARD sur les cases praticables — c'est du chaos, pas de
## la visée. Elles ne touchent que les ennemis : une pluie qui blesserait aussi
## le lanceur ferait de l'ultime un pari, alors qu'il se mérite en kills.
@export var rain_count: int = 0
@export var rain_damage: int = 0
@export var rain_radius: float = 1.5
## Durée pendant laquelle elles pleuvent, et temps de chute de chacune.
@export var rain_duration: float = 2.5
@export var rain_fall: float = 0.7

## Nombre de lancers d'affilée AVANT la recharge. 1 = comportement classique.
##
## Un sort de TERRAIN ne se joue pas comme un sort de combat : poser un seul
## brasier puis attendre une demi-minute, c'est décider une fois par minute.
## Avec cinq charges, on installe un dispositif — on ferme un couloir, on couvre
## une sortie de repaire, on garde la dernière en réserve. La recharge, elle,
## rend TOUTES les charges d'un coup : cinq petites recharges séparées
## donneraient un goutte-à-goutte qu'on ne peut pas planifier.
@export var charges: int = 1
## SUMMON : quelle créature (voir CombatSystem.SUMMON_KINDS), et combien.
##
## `summon_count` se compte PAR PORTE quand il y a des portes — voir plus bas.
@export var summon_id: String = ""
@export var summon_count: int = 1

## PORTES : le sort ouvre N passages AU LOIN plutôt que d'appeler ses créatures
## autour du lanceur.
##
## C'est toute la différence entre invoquer et DÉCHIRER. L'Invocateur fait
## naître ses bêtes à ses pieds : elles doivent traverser le labyrinthe pour
## atteindre quoi que ce soit, et c'est la contrepartie de son sort. Une faille,
## elle, s'ouvre là où sont les proies — le trajet ne coûte rien parce que le
## sort ne fait pas venir des créatures, il ouvre un ENDROIT.
##
## Une porte par créature ciblée, plafonnées : autant de portes que d'ennemis
## viderait un stage tardif d'un seul geste, et l'ultime cesserait d'être un
## coup pour devenir la fin de la partie.
@export var summon_portals: int = 0

## Plafond de créatures simultanées pour CE sort, quand il déborde le plafond
## ordinaire (`CombatSystem.MAX_SUMMONS`). Zéro = on garde le plafond commun.
##
## Il est propre au sort et non au jeu : le plafond commun existe pour empêcher
## l'Invocateur d'accumuler ses bêtes lancer après lancer, ce qu'un ultime à
## usage unique ne peut pas faire.
@export var summon_cap: int = 0


## Fabrique lisible : `Ability.make({"id": "fireball", "damage": 30, …})`.
## Un _init à douze paramètres positionnels serait illisible au point d'être
## dangereux — une valeur décalée d'un cran passerait inaperçue.
static func make(values: Dictionary) -> Ability:
	var ability := Ability.new()
	for key in values:
		ability.set(key, values[key])
	return ability


## Chiffres du sort, pour la fiche de personnage.
##
## Les PARTICULARITÉS viennent après les chiffres de base : charges, piège,
## traversée des murs, pluie de météores. Ce sont elles qui décident du choix
## d'un personnage — deux sorts à « 30 dégâts · rayon 2 » ne se jouent pas
## pareil si l'un cloue sur place et l'autre non, et la fiche doit le dire.
## Un chiffre LISIBLE : pas de décimale inutile, mais pas d'arrondi menteur.
##
## « recharge 2 s » pour un sort réglé à 1,8 s contredit le chiffre annoncé au
## joueur ; « recharge 2.0 s » pour un sort à 2 s alourdit six lignes de fiche
## sur sept. On tranche au cas par cas.
static func _number(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return "%d" % int(roundf(value))
	return "%.1f" % value


func summary() -> String:
	var parts: Array[String] = [_base_summary()]
	if charges > 1:
		parts.append("%d charges" % charges)
	if cooldown > 0.0 and not is_ultimate:
		parts.append("recharge %s s" % _number(cooldown))
	if arc > 0.0 and arc < 360.0:
		parts.append("balaie %.0f° devant" % arc)
	if pull_radius > 0.0:
		parts.append("aspire à %s cases" % _number(pull_radius))
	if residue_duration > 0.0:
		parts.append("laisse une ombre %s s" % _number(residue_duration))
	if poison_duration > 0.0:
		parts.append("empoisonne %s s à %d PV/s" % [_number(poison_duration), poison_damage])
	if slow_duration > 0.0:
		if slow_sustained:
			parts.append("englue à %d %% tant qu'on y reste" % int(slow_factor * 100.0))
		else:
			parts.append("englue %s s à %d %%" % [_number(slow_duration), int(slow_factor * 100.0)])
	if heal_self > 0:
		parts.append("soigne %d PV" % heal_self)
	if snare > 0.0:
		parts.append("cloue %.0f s" % snare)
	if snare_burn > 0.0:
		parts.append("puis brûle %.0f s" % snare_burn)
	if pierces_walls:
		parts.append("TRAVERSE LES MURS")
	if rain_count > 0:
		parts.append("%d météores à %d dégâts" % [rain_count, rain_damage])
	if blow_cells > 0:
		parts.append("projette de %d cases" % blow_cells)
	if slam_damage > 0:
		parts.append("+%d contre un mur" % slam_damage)
	if zone_travel > 0.0:
		parts.append("remonte %d cases" % range)
	if zone_carries:
		parts.append("EMPORTE ce qu'elle attrape")
	if kind == Kind.LINE and duration > 0.0:
		parts.append("pics plantés %.0f s à %d dégâts/s" % [duration, line_bite])
	if quake_duration > 0.0:
		parts.append("la terre tremble %.0f s · éboulements à %d dégâts"
			% [quake_duration, quake_damage])
	if sky_clouds > 0:
		parts.append("%d nuages foudroient %.0f s" % [sky_clouds, sky_duration])
	if empower_bonus > 0:
		parts.append("+%d dégâts %.0f s" % [empower_bonus, empower_duration])
	return " · ".join(parts)


## Les chiffres propres à la FORME du sort. Séparé de `summary()` pour que les
## particularités s'ajoutent sans toucher au tableau des formes — la session
## voisine y a ajouté les invocations pendant ce travail.
func _base_summary() -> String:
	match kind:
		Kind.PROJECTILE:
			return "%d dégâts · portée %d" % [damage, range]
		Kind.BLAST:
			return "%d dégâts · rayon %s" % [damage, _number(radius)]
		Kind.ZONE:
			return "%d dégâts/s · rayon %s · %s s" % [damage, _number(radius), _number(duration)]
		Kind.SHIELD when immune:
			return "INTOUCHABLE %.0f s" % duration
		Kind.SHIELD:
			return "absorbe %d · %.0f s" % [damage, duration]
		Kind.HEAL:
			return "rend %d PV" % damage
		Kind.WALL:
			return "bloque %.0f s" % duration
		Kind.BLINK:
			return "saut de %d cases" % range
		Kind.WAVE:
			return "%d dégâts · déferle sur %d cases" % [damage, range]
		Kind.CHAIN:
			return "%d dégâts · %d relais · portée %d" % [damage, chain_jumps, range]
		Kind.LINE:
			return "%d dégâts · ligne de %d cases" % [damage, range]
		Kind.TURRET:
			# Ce que le joueur doit lire, dans l'ordre : ce que ça fait, à quelle
			# cadence, combien de temps, et jusqu'où. « Tout seul » est la
			# particularité du sort — c'est le seul du jeu qui frappe sans qu'on
			# vise — donc elle passe en tête.
			var geste := "fend le couloir" if turret_sweep else "tire"
			var porte := "autour de lui" if turret_follows else "posé"
			return "%s tout seul · %d dégâts toutes les %s s · %s s · portée %d · %s" % [
				geste, damage, _number(turret_interval), _number(duration),
				range, porte]
		Kind.STORM:
			return "%d dégâts toutes les %.1f s · %.0f s · portée %d" % [
				damage, storm_interval, duration, storm_range]
		Kind.SUMMON when summon_portals > 0:
			return "%d failles · %d ombres chacune · %.0f s" % [
				summon_portals, summon_count, duration]
		Kind.SUMMON:
			# Le pluriel se pose : « 2 créature(s) » dans une fiche de
			# personnage donne l'impression d'une chaîne de caractères oubliée.
			return "%d créature%s · %.0f s" % [
				summon_count, "s" if summon_count > 1 else "", duration]
	return ""
