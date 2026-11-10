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
	ECHO,         ## un double REJOUE la marche récente du mage et blesse ce qu'il croise
	HOURGLASS,    ## note les coups reçus pendant sa durée, et en rend une part à la fin
	TIME_STOP,    ## tout se fige sauf le mage
	TRAIL,        ## le mage laisse du poison sur les cases qu'il quitte
	CONTAGION,    ## le poison d'une cible passe à ses voisins
	TRANSFUSION,  ## rend de la vie selon le nombre d'ennemis empoisonnés
	PANDEMIC,     ## toute la carte tombe malade
	BEAM,         ## un rayon qui suit les couloirs vers ses proies et touche tout ce qu'il traverse
	DAWN,         ## une colonne de lumière sur chaque ennemi de la carte
	SOULS,        ## lâche les âmes récoltées, qui chassent par les couloirs
	CONSTELLATION, ## pose une étoile ; des rayons les relient et brûlent ce qui passe
	STARFALL,     ## des étoiles tombent une à une autour du lanceur
	LAST_HOUR,    ## une faux traverse l'écran : chaque ennemi perd une part de ses PV
	BLADES,       ## une volée de lames part en éventail, puis revient au lanceur
	ANVIL,        ## une onde court dans les couloirs depuis le lanceur et étourdit
	PACT,         ## ne fait que payer son prix : sa force vient de l'exaltation qu'il porte
	POSSESS,      ## la cible se retourne contre ses voisins ; l'ultime possède tout l'écran
	BOND,         ## enchaîne des ennemis : une part des dégâts de l'un passe aux autres
	SWAP,         ## le lanceur et l'ennemi le plus proche échangent leurs places
	HUNTERS,      ## ses gantelets quittent leur orbite et chassent seuls
	CHEST,        ## son plastron, posé au sol, mord le premier ennemi qui passe
	RECALL,       ## toutes ses pièces reviennent d'un coup et blessent ce qu'elles traversent
	CAGES,        ## une cage se referme sur chaque ennemi, puis se resserre
	DASH,         ## il file droit dans le couloir et frappe tout ce qu'il traverse
	GUARD,        ## annule le premier coup reçu et riposte autour de lui
	SHEATHE,      ## fait éclater les entailles ; l'ultime en couvre d'abord tout l'écran
	HOOK,         ## une chaîne ramène l'ennemi le plus éloigné à portée devant le lanceur
	SOUL_CHAINS,  ## enchaîne des ennemis au lanceur : ralentis, ils brûlent de froid
	GAOL,         ## un cercle cloue au sol tous les ennemis qu'il contient, et les brûle
	FLIGHT,       ## le lanceur s'élève, survole les haies sans être touché, puis retombe avec une onde
	WHIRL,        ## une arme tourne autour du lanceur et frappe tout ce qui est à sa portée, par passages
	WHEELS,       ## deux roues roulent dans les couloirs, dans deux sens, et frappent ce qu'elles croisent
	GARDEN,       ## un cercle planté au sol : aucun ennemi n'y entre, ceux qui s'y trouvent sont rejetés
	BREATH,       ## un jet de flammes court dans le couloir devant le lanceur et laisse les cases en feu
	BITE,         ## bondit sur l'ennemi le plus proche et le mord ; une proie en feu le soigne
	MAGMA_SCALES, ## absorbe un coup, brûle ce qui le touche, puis éclate en écailles de lave
	WINGBEAT,     ## repousse et enflamme ce qui l'entoure, et le lanceur recule d'un bond
	DRAGON_SHADOW, ## une ombre de dragon survole l'écran : tout brûle, puis explose en colonnes
	DICE,         ## deux dés roulent dans le couloir : leur total fixe les dégâts, un double sonne
	TRAP_CARD,    ## une carte posée au sol ; le premier ennemi la retourne et elle frappe au hasard
	COIN,         ## pile ou face : intouchable et soigné, ou ses prochains coups doublés
	ROULETTE,     ## une roulette tourne, la bille tombe : rouge brûle, noir fige, zéro foudroie
	GULF,         ## une gueule s'ouvre au sol, aspire ce qui l'entoure, puis se referme
	DEVOUR,       ## avale l'ennemi le plus proche ; un ennemi blessé meurt d'un coup
	REGURGITATE,  ## recrache toutes les bouchées en boules de bile qui explosent
	LEAP,         ## un bond en avant ; l'atterrissage sonne ce qui l'entoure
	FEAST,        ## le lanceur devient géant et avale les ennemis proches, un à un
	HERO_TRANSFORM,
	COMET,
	TRANSMISSION,
	PILLARS,      ## des piliers de feu jaillissent en cercle autour du lanceur
	LEVIATHAN,    ## un serpent d'eau géant traverse le labyrinthe et frappe ce qu'il croise
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var kind: Kind = Kind.PROJECTILE
@export var element: Element.Kind = Element.Kind.SHADOW

## Dégâts au centre de l'effet. Une ZONE les inflige PAR SECONDE, les autres en
## une fois — la distinction est portée par `kind`, pas par un second champ.
@export var damage: int = 0
## Petite onde qui suit une attaque au contact (Éveillé).
@export var follow_wave: int = 0
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
## Habillage dédié d'un projectile. Vide = l'orbe du mage ; une valeur comme
## `convergence` charge ses sprites propres sans changer l'attaque de base, et les
## clés de `MagicOrb.PAINTED` peignent le projectile au shader.
@export var projectile_visual: String = ""
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
## LES QUATRE SCEAUX. Distance, en cases, à laquelle un sort de zone plante ses
## quatre sceaux — un par point cardinal, un par élément. Zéro = zone unique,
## c'est-à-dire tous les autres sorts de zone du jeu.
##
## Un seul sort s'en sert, et c'est voulu : c'est ce qui distingue le Sorcier
## Suprême. Tous les autres mages posent UNE zone d'UN élément ; lui seul en pose
## quatre d'un coup, et chacune porte l'effet de son élément.
@export var seal_ring: int = 0

@export var zone_travel: float = 0.0
## Ce qu'elle attrape VOYAGE avec elle au lieu de rester sur place.
##
## C'est le pilier de l'Air : le DÉPLACEMENT. Rien d'autre dans le jeu ne fait
## parcourir des cases à une créature — le trait de l'élément la pousse de deux
## cases, une fois.
@export var zone_carries: bool = false

## LES GEYSERS : combien de colonnes d'eau jaillissent AU HASARD sur la carte,
## toutes en même temps. Zéro = aucune.
##
## Ils remplacent la colonne unique qui montait sous les pieds du mage : posée
## là, elle l'EFFAÇAIT une seconde durant, et le joueur perdait son propre
## personnage. Éparpillés sur le labyrinthe, ils frappent ce qui passe et ne
## cachent rien d'important.
@export var geyser_count: int = 0
@export var geyser_damage: int = 0
@export var geyser_radius: float = 1.4

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

## Allure de la zone : "nappe", "brasier", "champ", "pics" ou "rune", et
## "nappe_peinte" ou "brasier_peint" pour les zones peintes au shader.
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

## La pluie VISE-t-elle les ennemis, au lieu de tomber au hasard ?
##
## Les deux pluies existantes arrosent le labyrinthe : c'est ce qui convient à
## une éruption ou à une averse. Celle du Suprême est un JUGEMENT — elle cherche
## ses cibles. Conséquence voulue : le total de météores étant fixe, moins il
## reste d'ennemis, plus chacun en reçoit.
@export var rain_hunts: bool = false

## L'ATTENTE AVANT LA PREMIÈRE MÉTÉORE, en secondes.
##
## Le temps du GESTE. Un sort qui appelle le ciel a une incantation dessinée —
## les quatre éléments tournent autour du mage, montent, quittent le cadre — et
## le ciel ne doit répondre qu'une fois ce départ terminé. Sans cette attente,
## la première pierre tombait pendant que les éléments montaient encore : les
## deux moitiés du sort se chevauchaient et aucune ne se lisait.
##
## Zéro pour les pluies sans geste : une éruption ne s'annonce pas, c'est tout
## son intérêt.
##
## ⚠️ Ce nombre doit valoir la durée de la planche d'incantation.
## `tools/build_jugement.py` le vérifie au découpage.
@export var rain_delay: float = 0.0


## Points absorbés par l'exaltation, sur toute sa durée. 0 = aucune protection.
##
## LA DÉFENSE DE CE JEU EST UNE ABSORPTION, PAS UN POURCENTAGE, et ce n'est pas
## un choix d'implémentation : tout coup porté au mage coûte exactement UN point
## de vie, quelle que soit l'espèce qui le touche (voir
## `GameManager.on_player_caught`). Il n'y a donc rien à réduire — un tiers de
## dégâts en moins sur un dégât de 1 est soit 1, soit 0. Ce qui se règle, c'est
## le NOMBRE de coups qu'on encaisse avant de perdre un point.
##
## Le compte se lit donc en coups : 2 points absorbés, ce sont deux contacts
## gratuits. Sur un mage à 4 points de vie, c'est la moitié de sa chair en plus.
##
## Comme le bonus de dégâts, il est REMIS à neuf et non empilé : relancer le
## sort ne fabrique pas une réserve infinie.
@export var empower_shield: int = 0


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


## --- Le Chronomancien : tout part de la TRACE que le mage laisse derrière lui ---

## Le saut ne va pas devant : il ramène là où le mage était il y a ce temps (forme BLINK).
## Seule fuite du jeu qui répare une erreur de chemin : elle sort d'un cul-de-sac.
@export var rewind_seconds: float = 0.0
## Secondes de marche que le double rejoue (forme ECHO). Il repasse par où le mage est
## venu : c'est-à-dire là où sont ses poursuivants.
@export var echo_seconds: float = 0.0
## Part des points de vie perdus que le sablier rend à la fin, arrondie au-dessus : un
## coup coûte toujours un point, et une moitié de point n'existe pas (forme HOURGLASS).
@export var hourglass_ratio: float = 0.5
## Allure des projectiles ennemis qui visent l'intérieur de la zone. 1 = aucun effet.
@export var time_factor: float = 1.0

## L'ÉVEIL DU CHRONOMANCIEN (le Seigneur des Heures).
## Le Dôme de stase FIGE net, une seule fois, chaque créature qui y entre (forme ZONE). Zéro = rien.
@export var entry_freeze: float = 0.0
## Le Paradoxe : un second double rejoue autant de secondes de marche, en plus du premier. Zéro = un seul.
@export var echo_second_seconds: float = 0.0
## Chaque double explose en onde d'horloge au bout de son trajet. Zéro = rien.
@export var echo_end_damage: int = 0
@export var echo_end_radius: float = 1.5
## Le Rembobinage : il récupère d'un coup les PV perdus dans ces dernières secondes (forme HOURGLASS,
## instantanée). Zéro = le Sablier ordinaire.
@export var rewind_heal_seconds: float = 0.0
## Le Saut temporel laisse là d'où il part une bombe-horloge qui sonne après ce délai. Zéro = rien.
@export var clock_bomb_delay: float = 0.0
@export var clock_bomb_damage: int = 0
@export var clock_bomb_radius: float = 1.8
@export var clock_bomb_stun: float = 0.0
## Le Jugement des Heures : pendant l'arrêt du temps, ses coups s'accumulent sur les ennemis au lieu de
## porter, puis tombent tous ensemble à ce multiple (forme TIME_STOP). Zéro = l'Arrêt ordinaire.
@export var judgement_ratio: float = 0.0

## L'ÉVEIL DU MAGE DE LA PESTE (le Seigneur du Fléau).
## Le Sillage pestilent : ses flaques mettent ces doses et ralentissent à ce facteur (forme TRAIL). Zéro = la
## flaque ordinaire, une dose sans ralentir.
@export var trail_doses: int = 0
@export var trail_slow: float = 0.0
## L'Épidémie : le poison saute d'ennemi en ennemi, `chain_range` cases au plus, ce nombre de fois ; chaque saut
## blesse de `damage` et ajoute `epidemic_doses` (forme CONTAGION). Zéro = la Contagion ordinaire.
@export var epidemic_jumps: int = 0
@export var epidemic_doses: int = 2
## La Saignée : chaque dose portée dans `radius` éclate pour ces dégâts ; il reprend 1 PV par `transfuse_per`
## doses éclatées (forme TRANSFUSION). Zéro = la Transfusion ordinaire.
@export var bleed_per_dose: int = 0
## La Nuée de corbeaux : ce qu'elle survole prend ces dégâts et ces doses (forme BLINK). Zéro = rien.
@export var flock_damage: int = 0
@export var flock_doses: int = 0
## Le nuage de la fuite se pose là où il arrive, et non là d'où il part.
@export var cloud_at_arrival: bool = false
## La Grande Peste ralentit tout ce qu'elle charge à ce facteur (forme PANDEMIC). 1 = rien.
@export var plague_slow: float = 1.0
## Doses que met le nuage des morts de la peste, une fois par seconde. Zéro = une.
@export var cloud_venom_doses: int = 0

## L'ÉVEIL DU SORCIER SUPRÊME (l'Archimage Primordial).
## La Grande Convergence : à l'impact, le noyau se brise en ce nombre d'éclats, un par élément de la roue,
## chacun sur une créature proche, pour ces dégâts et le trait de son élément. Zéro = rien.
@export var element_shards: int = 0
@export var element_shard_damage: int = 0
## La Couronne des sceaux : les quatre sceaux s'accrochent au mage et le suivent (forme ZONE à `seal_ring`).
@export var seals_follow: bool = false
## L'Apothéose : tant que dure l'exaltation, son Écho frappe deux fois.
@export var double_echo: bool = false
## Le Pas des éléments : à l'arrivée, un rayon de chaque élément part dans chaque couloir, sur cette longueur,
## pour ces dégâts et le trait de son élément (forme BLINK). Zéro = rien.
@export var element_ray_damage: int = 0
@export var element_ray_range: int = 5
## La Genèse : chaque météore prend l'élément suivant de la roue et porte son trait.
@export var rain_elements: bool = false
## La Genèse : la lumière de l'origine, quand la dernière météore est tombée. À vol d'oiseau. Zéro = rien.
@export var nova_damage: int = 0
@export var nova_radius: float = 0.0


## --- Le Mage de la Peste : ses dégâts sont des DOSES, qui travaillent quand il a fui ---

## Doses de venin que pose une zone, une fois par seconde et par créature.
@export var venom_doses: int = 0
## Secondes que durent les flaques de la Traînée (forme TRAIL).
@export var trail_life: float = 0.0
## Ennemis empoisonnés qu'il faut pour un point de vie (forme TRANSFUSION).
@export var transfuse_per: int = 2
## Le nuage toxique que le sort laisse : sa durée et son rayon. Zéro = aucun.
@export var cloud_duration: float = 0.0
@export var cloud_radius: float = 1.4


## --- Le Porte-Lumière : un ennemi aveuglé perd sa trace et ne frappe plus --------------

## Secondes d'aveuglement que pose le sort : zone, coque qui cède, atterrissage ou ultime.
@export var blind_seconds: float = 0.0
## Rayon, en cases, de l'éclair qui aveugle quand la coque cède ou quand il atterrit.
@export var blind_radius: int = 0

## L'ÉVEIL DE L'ANGE DE LA MORT (le Faucheur des Âmes).
## Le projectile revient vers le mage après sa cible, et frappe ce qu'il croise au retour.
@export var returns: bool = false
## Le Glas funèbre (forme BLAST) : ce nombre de coups, à `toll_gap` s d'écart, autour du mage ; chacun marque
## (`mark_seconds`) et ralentit (`toll_slow` pendant `slow_duration`). Zéro = une explosion ordinaire.
@export var toll_count: int = 0
@export var toll_gap: float = 1.5
@export var toll_slow: float = 1.0
## La Légion des âmes : âmes lâchées en plus de celles récoltées. Zéro = une.
@export var souls_base: int = 0
## Le Pas de l'ombre marque ce temps tout ce qui est sur la ligne du passage. Zéro = rien.
@export var blink_mark_seconds: float = 0.0
## Minuit : la faux de l'Heure dernière passe ce nombre de fois (aller, puis retour).
@export var hour_passes: int = 1

## L'ÉVEIL DE L'ARCHANGE DU CIEL (le Séraphin).
## La Lance du Séraphin : un tir `from_sky` en appelle un second sur un autre ennemi à portée.
@export var sky_twin: bool = false
## La Pluie de plumes (forme BLADES) : une plume tombe du ciel sur chaque ennemi à portée, ce nombre au plus.
## Zéro = la volée ordinaire.
@export var feather_rain: int = 0
## La Colonne du jugement : la colonne reste allumée ce temps sur sa case, et brûle (`column_burn` par seconde) ce
## qui y entre. Zéro = elle s'éteint aussitôt.
@export var column_linger: float = 0.0
@export var column_burn: int = 0
## L'Ascension (forme FLIGHT) : pendant le vol, une lance tombe toutes les `flight_lance_gap` s sur l'ennemi le plus
## proche (`flight_lance_damage`). Zéro = rien.
@export var flight_lance_gap: float = 0.0
@export var flight_lance_damage: int = 0
## Le Jugement dernier : après la pluie d'épées, une épée géante tombe sur lui et frappe à vol d'oiseau. Zéro = rien.
@export var great_sword_damage: int = 0
@export var great_sword_radius: float = 0.0

## L'ÉVEIL DU CHÉRUBIN (le Gardien du Trône).
## L'Épée flamboyante : le couloir que la flamme traverse reste en feu ce temps (une case en feu ordinaire). Zéro = rien.
@export var line_fire: float = 0.0
## Les Roues dans les roues : à quatre ou plus, une roue part dans chacune des quatre directions. Deux = l'ordinaire.
@export var wheel_count: int = 2
## Les Ailes du Trône : quand l'intouchabilité finit, un œil s'ouvre sur tout ce qui est à ce rayon. Zéro = rien.
@export var veil_eyes_radius: float = 0.0
## L'Éden gardé : une épée de flamme tourne sur le bord du cercle et frappe ce qui s'en approche. Zéro = aucune.
@export var garden_sword_damage: int = 0

## L'ÉVEIL DE L'ARCHANGE D'ACIER (le Forgeron Céleste).
## Le Marteau du ciel : un coup sur ce nombre étourdit `stun_seconds` ce que l'onde touche. Zéro = jamais (et alors
## `stun_seconds` étourdit à chaque coup, comme avant).
@export var stun_every: int = 0
## La Tempête de lames : les lames partent sur tout le tour au lieu d'un éventail.
@export var blades_circle: bool = false
## L'Enclume céleste (forme ANVIL) : une enclume tombe d'abord sur l'ennemi le plus proche (dégâts, rayon,
## étourdissement), et l'onde part de son point d'impact. Zéro = l'onde part du lanceur.
@export var anvil_drop_damage: int = 0
@export var anvil_drop_radius: float = 0.0
@export var anvil_drop_stun: float = 0.0
## Le Bastion de la forge (forme SHIELD) : à la fin, une gerbe de lames (dégâts, rayon) et ce nombre de plaques.
@export var bastion_burst_damage: int = 0
@export var bastion_burst_radius: float = 0.0
@export var bastion_plates: int = 0
## La Charge du bélier : ce qu'elle renverse est étourdi ce temps, et sa traînée laisse du métal en fusion au sol
## (`molten_trail_seconds`, brûlant comme une case en feu). Zéro = rien.
@export var trail_stun: float = 0.0
@export var molten_trail_seconds: float = 0.0
## Le Cœur de la forge : pendant la fusion, chaque case où il marche reste en fusion ce temps. Zéro = rien.
@export var molten_steps_seconds: float = 0.0

## L'ÉVEIL DE L'ANGE DES ÉTOILES (la Reine du Firmament).
## Le Trait de comète : quand les étoiles de la cible explosent, une étoile éphémère s'allume sur sa case ce temps,
## reliée à la constellation. Zéro = aucune.
@export var spark_seconds: float = 0.0
## La Grande Constellation : quand toutes les étoiles sont posées, la figure se ferme et brûle ce qu'elle enferme
## (dégâts par seconde). Zéro = elle ne se ferme pas.
@export var figure_damage: int = 0
## La Pluie de météores : un dernier gros météore sur l'ennemi le plus solide à portée. Zéro = aucun.
@export var big_meteor_damage: int = 0
@export var big_meteor_radius: float = 0.0
## L'Éclipse (forme SHIELD intouchable) : à la fin, un anneau de lune de ce rayon blesse (`moon_ring_damage`) et
## ralentit (`moon_ring_slow` pendant `moon_ring_slow_seconds`). Zéro = rien.
@export var moon_ring_radius: float = 0.0
@export var moon_ring_damage: int = 0
@export var moon_ring_slow: float = 1.0
@export var moon_ring_slow_seconds: float = 0.0
## La Comète : la fuite pose gratuitement une étoile là où elle arrive.
@export var blink_star: bool = false
## Naissance d'une galaxie (forme DAWN) : chaque point d'impact devient une étoile ce temps, reliée à ses voisines,
## et leurs rayons brûlent (`galaxy_damage` par seconde). Zéro = l'impact s'éteint.
@export var galaxy_seconds: float = 0.0
@export var galaxy_damage: int = 0

## L'ÉVEIL DU PORTE-LUMIÈRE (l'Étoile du Matin).
## Le Trait solaire : un coup sur ce nombre aveugle `blind_seconds`. Zéro = jamais.
@export var blind_every: int = 0
## La Lance de l'Aurore reste allumée ce temps sur son trajet, et brûle (`linger_damage` par seconde) et aveugle
## (`blind_seconds`) ce qui le traverse. Zéro = elle s'éteint aussitôt.
@export var beam_linger: float = 0.0
@export var linger_damage: int = 0
## La Cathédrale de lumière lui rend un PV toutes ces secondes passées dedans. Zéro = aucun soin.
@export var zone_heal_every: float = 0.0
## L'Égide solaire renvoie chaque coup encaissé en un rayon de ces dégâts. Zéro = aucun renvoi.
@export var aegis_ray_damage: int = 0
## Le Soleil de midi (forme DAWN) : il brille ce temps, lance un rayon de `sun_damage` par seconde sur chaque
## ennemi à l'écran, puis tombe en une vague de `sun_end_damage` sur `sun_end_radius`. Zéro = l'Aube de base.
@export var sun_seconds: float = 0.0
@export var sun_damage: int = 0
@export var sun_end_damage: int = 0
@export var sun_end_radius: float = 0.0


## --- L'Ange de la Mort : ce qu'il a blessé, il vient le prendre ------------------------

## Part des PV sous laquelle ce sort achève sa cible. 0 = le seuil du trait.
@export var execute_below: float = 0.0
## Secondes de la marque que pose la zone : le marqué prend plus de dégâts.
@export var mark_seconds: float = 0.0


## --- L'Ange des Étoiles : elle dessine ses pièges dans le labyrinthe -------------------

## Nombre d'étoiles que lâche une Pluie.
@export var star_falls: int = 0
## Dégâts de la traînée d'une fuite, sur ce qui se tient sur son trajet. 0 = pas de traînée.
@export var trail_damage: int = 0
## Le Rempart : ce qu'il renvoie à chaque coup refusé. Le lanceur ne bouge plus tant qu'il tient.
@export var reflect_damage: int = 0
## Le nombre de lames d'une volée.
@export var blade_count: int = 0
## L'onde d'enclume : le temps que restent étourdis ceux qu'elle touche.
@export var stun_seconds: float = 0.0
## L'armure en fusion : combien de temps elle dure après le coup.
@export var molten_seconds: float = 0.0
## Les PV que coûte le lancer. Le sort est refusé s'il prendrait le dernier.
@export var self_cost: int = 0
## Le soin de `heal_self` ne vient que si le souffle a touché un ennemi.
@export var heal_needs_hit: bool = false

## LA DÉMONE DE LA DISCORDE. Durée d'une possession, et ce que chaque coup porté ou rendu retire.
@export var possess_seconds: float = 0.0
@export var possess_strike: int = 0
## Chaque ennemi en plus dans la zone en augmente les dégâts de cette part.
@export var discord_bonus: float = 0.0
## La zone se pose sur l'ennemi le plus proche à portée, et non sous le lanceur.
@export var zone_on_prey: bool = false
## Combien d'ennemis le lien enchaîne, et la part des dégâts qui passe aux autres.
@export var bond_count: int = 0
@export var bond_share: float = 0.0
## L'Œil de la Reine (l'Éveil de la Discorde) : la cible ET ses N plus proches voisins sont possédés.
@export var possess_neighbors: int = 0
## Le Grand Bal : tant qu'il dure, chaque ennemi qui meurt éclate en fils, ces dégâts dans ce rayon.
@export var ball_burst_damage: int = 0
@export var ball_burst_radius: float = 0.0

## LE ROI DE BRAISE. Combien de temps le plastron retient sa proie, et le leurre attire les ennemis.
@export var hold_seconds: float = 0.0
@export var decoy_seconds: float = 0.0
@export var decoy_radius: float = 0.0
## L'EMPEREUR DES CENDRES (l'Éveil du Roi de Braise). La Forge impériale aspire jusqu'à cette distance tant
## qu'elle est posée ou qu'elle mord, puis explose quand elle recrache sa proie.
@export var forge_pull: float = 0.0
@export var forge_blast_damage: int = 0
@export var forge_blast_radius: float = 0.0
## Le Retour de l'Empire : les pièces rappelées laissent un mur de flammes, et si les trois reviennent
## ensemble, une onde de cendres part de lui.
@export var recall_fire_seconds: float = 0.0
@export var recall_wave_damage: int = 0
@export var recall_wave_radius: float = 0.0
## L'Empire des Cendres : chaque cage éclate en colonne de lave quand elle se resserre.
@export var cage_burst_damage: int = 0
@export var cage_burst_radius: float = 0.0

## LE CHEVALIER ÉCARLATE. Les entailles que laisse chaque coup du sort.
@export var cuts: int = 0
## Ce que chaque entaille retire quand il rengaine.
@export var cut_damage: int = 0
## La translation part dans son dos.
@export var backward: bool = false
## LE SEIGNEUR ÉCARLATE (l'Éveil du Chevalier). Le Pas des Mille Lames : sa lame fantôme repasse sur le même couloir
## `dash_echo_delay` secondes après, pour ces dégâts et ces entailles.
@export var dash_echo_damage: int = 0
@export var dash_echo_delay: float = 0.5
@export var dash_echo_cuts: int = 0
## La Garde du Seigneur pare TOUS les coups tant qu'elle dure, et riposte à chacun.
@export var guard_all: bool = false
## La Rengaine écarlate : chaque éclat projette des pétales-lames qui posent ces entailles aux voisins.
@export var petal_cuts: int = 0
@export var petal_radius: float = 0.0
## LE GARDIEN DE L'ABÎME (l'Éveil du Geôlier). Les Crochets lancent autant de chaînes à la fois.
@export var hook_count: int = 1
## Les Chaînes de l'Abîme se resserrent en cédant : ces dégâts, et chaque proie figée ce temps-là.
@export var snap_damage: int = 0
@export var snap_stun: float = 0.0
## L'Hiver de l'Abîme laisse une plaque de givre qui ralentit ce temps-là, au facteur `slow_factor`.
@export var frost_seconds: float = 0.0
## Le Pas de l'Abîme fige à l'arrivée ce que son onde (`end_blast_*`) touche.
@export var end_blast_stun: float = 0.0
## L'Abîme tire ses prisonniers d'une case vers lui toutes les `gaol_pull_gap` s, puis se referme sur eux.
@export var gaol_pull_gap: float = 0.0
@export var gaol_end_damage: int = 0
## LE DRAGON PRIMORDIAL (l'Éveil du Dragon des Abysses). Le Souffle embrase aussi les cases qui bordent le couloir.
@export var breath_spill: bool = false
## LE MAÎTRE DU CASINO (l'Éveil du Croupier). Les Dés du Diable roulent autant de dés ; un brelan fige et brûle.
@export var dice_count: int = 2
## La Table piégée pose ses cartes en croix autour de lui, et un Joker sort à cette chance.
@export var trap_cross: bool = false
@export var joker_chance: float = 0.0
## La Pièce truquée retombe sur la tranche : les deux faces à la fois.
@export var coin_both: bool = false
## Le Grand Jeu : la roulette tourne autant de fois de suite.
@export var roulette_spins: int = 1
## FAIM SANS FOND (l'Éveil de l'Avide). Tout dévorer saisit autant de proies à la fois.
@export var devour_count: int = 1
## Le Déluge de bile : chaque boule laisse une flaque d'acide, ce temps-là, à ces dégâts par seconde.
@export var bile_seconds: float = 0.0
@export var bile_damage: int = 0
## Le Grand Festin avale à cet intervalle (0 : `CombatSystem.FEAST_GAP`), et se soigne au plus tant de fois.
@export var feast_gap: float = 0.0
@export var feast_heal_cap: int = 0
## L'Ombre lâche un météore à rayon sur chaque proie, au lieu d'une colonne qui ne frappe qu'elle.
@export var meteor_radius: float = 0.0
## Le Dernier Pacte : le lanceur tombe à 1 PV et reste intouchable ce temps-là.
@export var last_pact_seconds: float = 0.0
## La part des PV sacrifiés qu'il retrouve à la fin.
@export var last_pact_return: float = 0.0
## L'Apocalypse de Sang (l'Archidémon) : tant que dure le Dernier Pacte, une serre géante s'abat toutes les
## `pact_claw_gap` secondes sur l'ennemi le plus proche, pour ces dégâts.
@export var pact_claw_damage: int = 0
@export var pact_claw_gap: float = 1.0
## Le soin du souffle se compte PAR ENNEMI touché, plafonné à `heal_self` (la Gueule de l'Abîme).
@export var heal_per_hit: bool = false
## Le dessin de ce qu'une gerbe laisse planté. Vide = les pics de pierre.
@export var plant_style: String = ""

## L'ARCHANGE DU CIEL. Le coup TOMBE DU CIEL au lieu de remonter les couloirs : la cible se
## choisit à vol d'oiseau, par-dessus les haies, et le coup frappe après `sky_fall` secondes,
## où qu'elle soit allée. C'est son trait, et il doit se voir : un sceau s'ouvre sous la cible
## avant que le coup ne tombe.
@export var from_sky: bool = false
@export var sky_fall: float = 0.35
## La volée de lames revient-elle au lanceur ? Les plumes, elles, filent et ne reviennent pas.
@export var blades_return: bool = true
## L'Envol : son allure en vol, en multiple de la sienne.
@export var flight_speed: float = 1.0

## LE CHÉRUBIN. Le projectile brûle aussi tout ce qu'il croise sur son trajet, pas seulement sa cible.
@export var pierce_line: bool = false
## Le Glaive tournoyant : secondes entre deux passages de l'arme.
@export var whirl_interval: float = 0.5
## Les Ailes voilées : de combien de cases elles repoussent ce qui le touche. Zéro = rien.
@export var repel_cells: int = 0

## L'ÉVEIL DU PHÉNIX (Mage du Feu éveillé).
## Le projectile part sur autant de cibles à la fois (les plus proches, une chacune).
@export var volley: int = 1
## Une seconde explosion au même endroit, après ce délai, pour ces dégâts. Zéro = aucune.
@export var echo_delay: float = 0.0
@export var echo_damage: int = 0
## Le magma laissé à l'impact : durée et dégâts par seconde. Zéro = aucun.
@export var magma_duration: float = 0.0
@export var magma_damage: int = 0
## Les Colonnes de feu : combien de piliers, et à quelle distance du lanceur.
@export var pillar_count: int = 0
@export var pillar_ring: float = 0.0
## Une explosion à chaque bout de la fuite : ses dégâts et son rayon. Zéro = aucune.
@export var end_blast_damage: int = 0
@export var end_blast_radius: float = 0.0

## L'ÉVEIL DU SEIGNEUR DES MARÉES (Mage de l'Eau éveillé).
## Le tir rebondit ensuite sur autant d'ennemis voisins, à cette distance de couloir, en perdant
## une part de ses dégâts à chaque fois.
@export var bounces: int = 0
@export var bounce_range: int = 3
@export var bounce_falloff: float = 0.7
## Le bouclier rend autant de PV s'il tient jusqu'à son échéance sans céder.
@export var heal_if_held: int = 0
## La fuite suit le couloir et tourne avec lui, au lieu de filer droit.
@export var follows_corridor: bool = false
## Elle laisse derrière elle une eau qui ralentit, ce temps-là. Zéro = rien.
@export var wake_seconds: float = 0.0

## L'ÉVEIL DU COLOSSE (Mage de la Terre éveillé).
## La gerbe part dans les QUATRE directions à la fois, en croix, au lieu de devant lui seulement.
@export var line_cross: bool = false
## Le cristal planté tire sur autant d'ennemis à la fois. Zéro ou un = le plus proche seulement.
@export var turret_volley: int = 0
## Le séisme fait jaillir autant de colonnes de lave, une à une, chacune de ces dégâts et ce rayon.
@export var lava_columns: int = 0
@export var lava_damage: int = 0
@export var lava_radius: float = 1.0
## L'explosion de bout de fuite projette ce qu'elle touche d'autant de cases. Zéro = rien.
@export var end_blast_push: int = 0
## L'explosion de bout de fuite n'a lieu qu'à l'arrivée (l'Éruption), pas au départ.
@export var end_blast_arrival_only: bool = false
## Un bouclier qui renvoie les coups (`reflect_damage`) cloue le lanceur sur place, comme le Rempart de
## l'Acier ; le Bastion du Colosse le laisse marcher (demande du joueur, 2026-11-07).
@export var reflect_mobile: bool = false

## L'ÉVEIL DE L'AVATAR DE LA TEMPÊTE (Mage de la Foudre éveillé).
## Chaque maillon de la chaîne est paralysé ce temps-là. Zéro = rien.
@export var chain_stun: float = 0.0
## La zone suit le lanceur au lieu de rester où elle est posée (la Cage électrique).
@export var zone_follows: bool = false
## L'orage frappe autant de cibles à chaque décharge (un nuage chacune). Zéro ou un = la plus proche.
@export var storm_clouds: int = 0
## La fuite saute d'ennemi en ennemi, `hop_count` fois, à `hop_range` cases au plus l'un de l'autre, en
## frappant chacun de `hop_damage`, et le lanceur réapparaît sur le dernier. Zéro = une fuite ordinaire.
@export var hop_count: int = 0
@export var hop_damage: int = 0
@export var hop_range: int = 5
## La Colère du ciel : un éclair géant sur chaque ennemi à `wrath_reach` cases (à vol d'oiseau), un par
## un, `wrath_gap` secondes l'un après l'autre. Zéro = rien.
@export var wrath_damage: int = 0
@export var wrath_reach: float = 10.0
@export var wrath_gap: float = 0.15

## L'ÉVEIL DU SOUVERAIN DES VENTS (Mage de l'Air éveillé).
## Le tir qui traverse (`pierce_line`) repousse de ce nombre de cases tout ce qu'il touche. Zéro = rien.
@export var pierce_push: int = 0
## La zone aspire, à chaque tic, les ennemis à cette distance d'elle (au-delà de son rayon) d'une case
## vers elle. Zéro = rien.
@export var zone_pull: float = 0.0
## Ce qui heurte un mur sous le souffle (`slam_damage`) est étourdi ce temps-là. Zéro = rien.
@export var slam_stun: float = 0.0
## L'œil de l'ouragan : une zone qui suit le lanceur, ses secondes, ses dégâts par seconde, son rayon et
## la distance d'où elle aspire. Zéro = rien.
@export var eye_seconds: float = 0.0
@export var eye_damage: int = 0
@export var eye_radius: float = 3.0
@export var eye_pull: float = 6.0

## L'ÉVEIL DU SEIGNEUR DU NÉANT (Sorcier des Ténèbres éveillé).
## À l'impact, le tir rapproche d'une case de son point de chute ce qui est à cette distance. Zéro = rien.
@export var impact_pull: float = 0.0
## Le Trou noir : il s'ouvre sur la cible, aspire `hole_seconds` secondes ce qui est à `hole_pull` cases,
## puis s'effondre (les dégâts et le rayon du sort). Zéro = un souffle ordinaire.
@export var hole_seconds: float = 0.0
@export var hole_pull: float = 4.0
## L'Éclipse : tous les ennemis sont ralentis à cette part de leur allure, ce temps-là. Zéro = rien.
@export var eclipse_seconds: float = 0.0
@export var eclipse_slow: float = 0.6

## L'ÉVEIL DE L'INVOCATEUR (le Maître des Légions).
## La Marque : la cible touchée devient la proie de TOUTES ses créatures ce temps-là. Zéro = rien.
## (Distincte de `mark_seconds`, la marque de l'Ange de la Mort, qui fait prendre plus de dégâts.)
@export var prey_mark_seconds: float = 0.0
## Les créatures de ce sort explosent quand elles s'en vont (fin de vie ou place cédée). Zéro = rien.
@export var summon_burst_damage: int = 0
@export var summon_burst_radius: float = 1.0
## La créature TOMBE du ciel près de la proie la plus proche : dégâts, rayon et étourdissement du choc.
@export var summon_drop_damage: int = 0
@export var summon_drop_radius: float = 1.5
@export var summon_drop_stun: float = 0.0
## Taille de la créature à l'écran, et l'apparence à lire dans allies.json à la place de la sienne.
@export var summon_scale: float = 1.0
@export var summon_look: String = ""
## La Porte des abysses : la zone fait sortir une créature `summon_id` toutes les `zone_spawn_every`
## secondes, qui vit `zone_spawn_life` secondes. Zéro = rien.
@export var zone_spawn_every: float = 0.0
@export var zone_spawn_life: float = 10.0
## L'Échange : la fuite le met à la place de sa créature la plus éloignée, et elle à la sienne.
@export var swap_with_summon: bool = false
## Le Roi-Dragon passe au-dessus de la rangée du mage, par-dessus les haies : dégâts, portée de chaque
## côté et demi-largeur, en cases. Zéro = rien.
@export var flyover_damage: int = 0
@export var flyover_reach: float = 12.0
@export var flyover_width: float = 1.5

## LE DRAGON DES ABYSSES. Secondes de feu laissées sur les cases touchées. Zéro = aucune.
@export var ground_fire: float = 0.0
## La Morsure : PV rendus quand la proie brûlait.
@export var bite_heal: int = 0
## Les Écailles de magma : combien d'éclats partent quand elles cèdent, et ce que fait chacun.
@export var shard_count: int = 0
@export var shard_damage: int = 0
## Brûlure posée sur les ennemis touchés, en dégâts par seconde, pendant `duration`.
@export var burn_dps: int = 0

## LE CROUPIER DES ENFERS. Combien de cartes pièges tiennent au sol à la fois.
@export var trap_count: int = 0
## Pile ou face : ce que rend Face, et combien de coups Pile double.
@export var coin_heal: int = 0
@export var doubled_hits: int = 0
## La Roulette : les dégâts du Noir (ceux du Zéro sont `damage`).
@export var black_damage: int = 0


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
		parts.append(("+%d PV s'il touche" if heal_needs_hit else "soigne %d PV") % heal_self)
	if snare > 0.0:
		parts.append("cloue %.0f s" % snare)
	if snare_burn > 0.0:
		parts.append("puis brûle %.0f s" % snare_burn)
	if pierces_walls:
		parts.append("TRAVERSE LES MURS")
	if from_sky:
		parts.append("à vol d'oiseau, par-dessus les haies")
	if pierce_line:
		parts.append("brûle tout sur son trajet")
	if volley > 1:
		parts.append("%d cibles à la fois" % volley)
	if echo_damage > 0:
		parts.append("explose une 2e fois (%d)" % echo_damage)
	if magma_duration > 0.0:
		parts.append("magma %s s à %d/s" % [_number(magma_duration), magma_damage])
	if end_blast_damage > 0:
		parts.append(("explose à l'arrivée (%d)" if end_blast_arrival_only else "explose aux deux bouts (%d)") % end_blast_damage)
	if bounces > 0:
		parts.append("rebondit sur %d voisins" % bounces)
	if heal_if_held > 0:
		parts.append("+%d PV s'il tient" % heal_if_held)
	if follows_corridor:
		parts.append("suit le couloir")
	if wake_seconds > 0.0:
		parts.append("laisse un courant qui ralentit")
	if line_cross:
		parts.append("en croix")
	if turret_volley > 1:
		parts.append("%d cibles à la fois" % turret_volley)
	if lava_columns > 0:
		parts.append("%d colonnes de lave à %d dégâts" % [lava_columns, lava_damage])
	if end_blast_push > 0:
		parts.append("projette de %d cases" % end_blast_push)
	if chain_stun > 0.0:
		parts.append("paralyse %s s" % _number(chain_stun))
	if zone_follows:
		parts.append("le suit")
	if storm_clouds > 1:
		parts.append("%d nuages" % storm_clouds)
	if hop_count > 0:
		parts.append("rebondit sur %d ennemis (%d)" % [hop_count, hop_damage])
	if wrath_damage > 0:
		parts.append("un éclair géant par ennemi (%d)" % wrath_damage)
	if pierce_push > 0:
		parts.append("repousse de %d case(s)" % pierce_push)
	if zone_pull > 0.0:
		parts.append("aspire à %s cases" % _number(zone_pull))
	if slam_stun > 0.0:
		parts.append("étourdit %s s au choc" % _number(slam_stun))
	if eye_seconds > 0.0:
		parts.append("œil de l'ouragan %s s à %d/s" % [_number(eye_seconds), eye_damage])
	if impact_pull > 0.0:
		parts.append("aspire à %s cases à l'impact" % _number(impact_pull))
	if hole_seconds > 0.0:
		parts.append("aspire %s s puis s'effondre" % _number(hole_seconds))
	if eclipse_seconds > 0.0:
		parts.append("éclipse %s s, ennemis ralentis" % _number(eclipse_seconds))
	if prey_mark_seconds > 0.0:
		parts.append("marque la proie %s s" % _number(prey_mark_seconds))
	if entry_freeze > 0.0:
		parts.append("fige %s s à l'entrée" % _number(entry_freeze))
	if echo_end_damage > 0:
		parts.append("onde de %d dégâts au bout" % echo_end_damage)
	if flock_damage > 0:
		parts.append("la volée blesse de %d et met %d doses" % [flock_damage, flock_doses])
	if element_shards > 0:
		parts.append("%d éclats d'élément à %d" % [element_shards, element_shard_damage])
	if seals_follow:
		parts.append("les sceaux le suivent")
	if double_echo:
		parts.append("écho double")
	if element_ray_damage > 0:
		parts.append("4 rayons à %d à l'arrivée" % element_ray_damage)
	if nova_damage > 0:
		parts.append("nova de %d au bout" % nova_damage)
	if returns:
		parts.append("revient et frappe au retour")
	if toll_count > 0:
		parts.append(("%d coups de cloche · marque %s s" % [toll_count, _number(mark_seconds)]) if mark_seconds > 0.0
			else "%d coups de cloche" % toll_count)
	if souls_base > 1:
		parts.append("%d âmes en plus des siennes" % souls_base)
	if blink_mark_seconds > 0.0:
		parts.append("marque la ligne %s s" % _number(blink_mark_seconds))
	if hour_passes >= 2:
		parts.append("la faux passe %d fois" % hour_passes)
	if sky_twin:
		parts.append("×2")
	if flight_lance_gap > 0.0:
		parts.append("lances")
	if great_sword_damage > 0:
		parts.append("épée géante %d" % great_sword_damage)
	if line_fire > 0.0:
		parts.append("en feu")
	if veil_eyes_radius > 0.0:
		parts.append("yeux à %s" % _number(veil_eyes_radius))
	if garden_sword_damage > 0:
		parts.append("épée du bord %d" % garden_sword_damage)
	if anvil_drop_damage > 0:
		parts.append("enclume de %d" % anvil_drop_damage)
	if bastion_burst_damage > 0:
		parts.append("gerbe %d" % bastion_burst_damage)
	if molten_trail_seconds > 0.0:
		parts.append("en fusion")
	if molten_steps_seconds > 0.0:
		parts.append("pas en fusion")
	if spark_seconds > 0.0:
		parts.append("allume une étoile %s s" % _number(spark_seconds))
	if big_meteor_damage > 0:
		parts.append("+ météore de %d" % big_meteor_damage)
	if moon_ring_radius > 0.0:
		parts.append("anneau de lune %d" % moon_ring_damage)
	if blink_star:
		parts.append("pose une étoile")
	if galaxy_seconds > 0.0:
		parts.append("impacts en étoiles %s s" % _number(galaxy_seconds))
	if blind_every > 0:
		parts.append("un coup sur %d aveugle %s s" % [blind_every, _number(blind_seconds)])
	if beam_linger > 0.0:
		parts.append("reste %s s à %d dégâts/s" % [_number(beam_linger), linger_damage])
	if zone_heal_every > 0.0:
		parts.append("+1 PV toutes les %s s dedans" % _number(zone_heal_every))
	if aegis_ray_damage > 0:
		parts.append("renvoie chaque coup en rayon de %d" % aegis_ray_damage)
	if clock_bomb_damage > 0:
		parts.append("bombe-horloge %d dégâts, fige %s s" % [clock_bomb_damage, _number(clock_bomb_stun)])
	if summon_burst_damage > 0:
		parts.append("explosent à %d dégâts" % summon_burst_damage)
	if summon_drop_damage > 0:
		parts.append("chute à %d dégâts" % summon_drop_damage)
	if summon_drop_stun > 0.0:
		parts.append("étourdit %s s" % _number(summon_drop_stun))
	if zone_spawn_every > 0.0:
		parts.append("un diablotin toutes les %s s" % _number(zone_spawn_every))
	if swap_with_summon:
		parts.append("échange avec une créature")
	if flyover_damage > 0:
		parts.append("passage de feu à %d dégâts" % flyover_damage)
	if geyser_count > 0:
		parts.append("%d geysers à %d dégâts" % [geyser_count, geyser_damage])
	if rain_count > 0:
		# « Météores » pour le Feu, « gouttes » pour l'Eau : c'est le même
		# mécanisme, mais le joueur ne lit pas une fiche de code.
		var nom := "gouttes" if element == Element.Kind.WATER \
			else "épées" if element == Element.Kind.SKY else "météores"
		parts.append("%d %s à %d dégâts" % [rain_count, nom, rain_damage])
	if blow_cells > 0:
		parts.append("projette de %d cases" % blow_cells)
	if slam_damage > 0:
		parts.append("+%d contre un mur" % slam_damage)
	if zone_travel > 0.0:
		parts.append("remonte %d cases" % range)
	if zone_carries:
		parts.append("EMPORTE ce qu'elle attrape")
	if kind == Kind.LINE and duration > 0.0:
		parts.append(("brûle %.0f s à %d/s" if plant_style != "" else "pics plantés %.0f s à %d dégâts/s")
			% [duration, line_bite])
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
		Kind.HERO_TRANSFORM:
			return "Prisme %s s · +2 s par kill (plafond %s s)" % [_number(Transformation.START_TIME), _number(Transformation.MAX_TIME)]
		Kind.COMET:
			return "%d dégâts à l’arrivée · rayon %s · portée %d" % [damage, _number(radius), range]
		Kind.TRANSMISSION:
			return "réapparaît derrière la cible · portée %d" % range
		Kind.PROJECTILE when radius > 0.0 and stun_seconds > 0.0:
			return "%d dégâts · rayon %s · cloue %s s · portée %d" % [damage, _number(radius),
				_number(stun_seconds), range]
		Kind.PROJECTILE:
			return "%d dégâts · portée %d" % [damage, range]
		Kind.LEVIATHAN:
			return "%d dégâts · traverse le labyrinthe · bande de %s cases · +%d PV" % [damage,
				_number(radius * 2.0), heal_self]
		Kind.PILLARS:
			return "%d piliers · %d dégâts · cercle de %s cases" % [pillar_count, damage, _number(pillar_ring)]
		Kind.WHIRL:
			return "%d par passage · %s par seconde · rayon %s · %s s" % [damage,
				_number(1.0 / maxf(0.05, whirl_interval)), _number(radius), _number(duration)]
		Kind.WHEELS:
			return "%d roues · %d dégâts · %d cases de couloir chacune" % [wheel_count, damage, range]
		Kind.GARDEN:
			return "rayon %s · %s s · aucun ennemi n'entre · %d dégâts au rejet" % [
				_number(radius), _number(duration), damage]
		Kind.GULF:
			return "portée %d · aspire %s s · rayon %s · puis %d dégâts" % [range, _number(duration), _number(radius), damage]
		Kind.DEVOUR when devour_count > 1:
			return "%d proies · %d dégâts · portée %d · avale sous %d %% de leurs PV : +%d PV chacune" % [
				devour_count, damage, range, int(execute_below * 100.0), bite_heal]
		Kind.DEVOUR:
			return "%d dégâts · portée %d · avale sous %d %% de ses PV : +%d PV" % [damage, range,
				int(execute_below * 100.0), bite_heal]
		Kind.REGURGITATE when bile_seconds > 0.0:
			return "une boule par bouchée · %d dégâts · rayon %s · flaque %s s à %d/s" % [damage, _number(radius),
				_number(bile_seconds), bile_damage]
		Kind.REGURGITATE:
			return "une boule par bouchée · %d dégâts chacune · rayon %s · portée %d" % [damage, _number(radius), range]
		Kind.LEAP when damage > 0:
			return "bond de %d cases · morsure %d · sonnés %s s · rayon %s" % [range, damage,
				_number(stun_seconds), _number(radius)]
		Kind.LEAP:
			return "bond de %d cases · sonnés %s s · rayon %s" % [range, _number(stun_seconds), _number(radius)]
		Kind.FEAST when feast_gap > 0.0:
			return "colossal %s s · avale un ennemi toutes les %s s · rayon %s · %d dégâts · +%d PV par proie" % [
				_number(duration), _number(feast_gap), _number(radius), damage, bite_heal]
		Kind.FEAST:
			return "géant %s s · avale un ennemi toutes les %s s · rayon %s · %d dégâts · +%d PV par proie" % [
				_number(duration), _number(CombatSystem.FEAST_GAP), _number(radius), damage, bite_heal]
		Kind.DICE when dice_count > 2:
			return "%d dés · %d par point · %d cases · double : sonnés · brelan : figés et brûlent" % [
				dice_count, damage, range]
		Kind.DICE:
			return "2 dés · %d par point (2 à 12) · %d cases · double : sonnés %s s" % [damage, range,
				_number(stun_seconds)]
		Kind.TRAP_CARD when trap_cross:
			return "%d dégâts · %d cartes en croix · %s s · Joker %d %% : les trois à la fois" % [
				damage, trap_count, _number(duration), int(joker_chance * 100.0)]
		Kind.TRAP_CARD:
			return "%d dégâts · %d cartes au sol · %s s · feu, glace ou foudre" % [damage, trap_count, _number(duration)]
		Kind.COIN when coin_both:
			return "sur la tranche : INTOUCHABLE %s s, +%d PV et %d coups doublés" % [_number(duration),
				coin_heal, doubled_hits]
		Kind.COIN:
			return "face : INTOUCHABLE %s s, +%d PV · pile : %d coups doublés" % [_number(duration), coin_heal,
				doubled_hits]
		Kind.ROULETTE when roulette_spins > 1:
			return "%d tours de roue · rouge : brûle %d/s · noir : figés %s s, %d · zéro : %d" % [roulette_spins,
				burn_dps, _number(stun_seconds), black_damage, damage]
		Kind.ROULETTE:
			return "tout l'écran · rouge : brûle %d/s %s s · noir : figés %s s, %d · zéro : %d" % [burn_dps,
				_number(duration), _number(stun_seconds), black_damage, damage]
		Kind.BLINK when decoy_seconds > 0.0 and damage <= 0:
			return "%d cases · leurre %s s" % [range, _number(decoy_seconds)]
		Kind.BREATH when breath_spill:
			return "%d dégâts · %d cases de couloir et leurs bords · en feu %s s" % [damage, range, _number(ground_fire)]
		Kind.BREATH:
			return "%d dégâts · %d cases de couloir · en feu %s s" % [damage, range, _number(ground_fire)]
		Kind.BITE when execute_below > 0.0:
			return "%d dégâts · bond de portée %d · avale une proie en feu sous %d %% · +%d PV" % [
				damage, range, int(execute_below * 100.0), bite_heal]
		Kind.BITE:
			return "%d dégâts · bond de portée %d · +%d PV sur une proie en feu" % [damage, range, bite_heal]
		Kind.MAGMA_SCALES:
			return "absorbe %d · %s s · brûle qui le touche · %d éclats à %d" % [damage, _number(duration),
				shard_count, shard_damage]
		Kind.WINGBEAT:
			return "%d dégâts · rayon %s · brûle %d/s · recule de %d cases" % [damage,
				_number(radius), burn_dps, range]
		Kind.DRAGON_SHADOW when meteor_radius > 0.0:
			return "tout l'écran · brûle %d/s %s s · puis météore de %d (rayon %s)" % [burn_dps, _number(duration),
				damage, _number(meteor_radius)]
		Kind.DRAGON_SHADOW:
			return "tout l'écran · brûle %d/s %s s · puis colonne de %d" % [burn_dps, _number(duration), damage]
		Kind.SHIELD when repel_cells > 0:
			return "INTOUCHABLE %s s · repousse de %d cases" % [_number(duration), repel_cells]
		Kind.FLIGHT:
			return "vole %s s · INTOUCHABLE · allure x%s · %d dégâts à l'atterrissage" % [
				_number(duration), _number(flight_speed), damage]
		Kind.BLAST when molten_seconds > 0.0:
			return "%d dégâts · rayon %s · armure en fusion %s s" % [damage, _number(radius),
				_number(molten_seconds)]
		Kind.BLAST when last_pact_seconds > 0.0 and pact_claw_damage > 0:
			return "%d dégâts · rayon %s · 1 PV · INTOUCHABLE %s s · une serre de %d toutes les %s s" % [
				damage, _number(radius), _number(last_pact_seconds), pact_claw_damage, _number(pact_claw_gap)]
		Kind.BLAST when last_pact_seconds > 0.0:
			return "%d dégâts · rayon %s · 1 PV · INTOUCHABLE %s s" % [
				damage, _number(radius), _number(last_pact_seconds)]
		Kind.BLAST when heal_per_hit:
			return "%d dégâts · rayon %s · +1 PV par ennemi touché, %d au plus" % [
				damage, _number(radius), heal_self]
		# ⚠️ Avant le cas général : placé après lui, il n'était jamais atteint.
		Kind.BLAST when stun_seconds > 0.0:
			return "%d dégâts · rayon %s · figés %s s" % [damage, _number(radius), _number(stun_seconds)]
		Kind.BLAST when damage <= 0 and rain_count > 0:
			return "sur les ennemis de toute la carte"
		Kind.BLAST:
			return "%d dégâts · rayon %s" % [damage, _number(radius)]
		Kind.PACT:
			return "coûte %d PV · jamais le dernier" % self_cost
		Kind.POSSESS when is_ultimate and ball_burst_damage > 0:
			return "tous les ennemis · %s s · %d par coup · chaque mort éclate (%d, rayon %s)" % [
				_number(possess_seconds), possess_strike, ball_burst_damage, _number(ball_burst_radius)]
		Kind.POSSESS when is_ultimate:
			return "tous les ennemis · %s s · %d par coup" % [_number(possess_seconds), possess_strike]
		Kind.POSSESS when possess_neighbors > 0:
			return "possède %d ennemis · portée %d · %s s · %d par coup" % [
				1 + possess_neighbors, range, _number(possess_seconds), possess_strike]
		Kind.POSSESS:
			return "possède 1 ennemi · portée %d · %s s · %d par coup" % [
				range, _number(possess_seconds), possess_strike]
		Kind.BOND:
			return "enchaîne %d ennemis · portée %d · %d %% des dégâts · %s s" % [
				bond_count, range, int(bond_share * 100.0), _number(duration)]
		Kind.SWAP when decoy_seconds > 0.0:
			return "échange avec un ennemi · portée %d · pantin %s s · %d dégâts · rayon %s" % [
				range, _number(decoy_seconds), damage, _number(decoy_radius)]
		Kind.SWAP:
			return "échange avec un ennemi · portée %d" % range
		Kind.HUNTERS when radius > 0.0:
			return "%d par coup · gerbe rayon %s · %s s · portée %d" % [damage, _number(radius), _number(duration), range]
		Kind.HUNTERS:
			return "%d par coup · %s s · portée %d" % [damage, _number(duration), range]
		Kind.CHEST when forge_blast_damage > 0:
			return "aspire à %s · retient %s s · %d dégâts/s · explose %d (rayon %s)" % [
				_number(forge_pull), _number(hold_seconds), damage, forge_blast_damage, _number(forge_blast_radius)]
		Kind.CHEST:
			return "retient %s s · %d dégâts/s" % [_number(hold_seconds), damage]
		Kind.RECALL when recall_wave_damage > 0:
			return "%d par pièce · mur de flammes %s s · onde %d (rayon %s)" % [
				damage, _number(recall_fire_seconds), recall_wave_damage, _number(recall_wave_radius)]
		Kind.RECALL:
			return "%d par pièce · traverse les haies" % damage
		Kind.CAGES when cage_burst_damage > 0:
			return "tous les ennemis · bloqués %s s · puis %d dégâts · éclat %d (rayon %s)" % [
				_number(duration), damage, cage_burst_damage, _number(cage_burst_radius)]
		Kind.CAGES:
			return "tous les ennemis · bloqués %s s · puis %d dégâts" % [_number(duration), damage]
		Kind.HOOK when hook_count > 1:
			return "%d chaînes · portée %d · %d dégâts · sonnés %s s" % [
				hook_count, range, damage, _number(stun_seconds)]
		Kind.HOOK:
			return "ramène le plus éloigné · portée %d · %d dégâts · sonné %s s" % [
				range, damage, _number(stun_seconds)]
		Kind.SOUL_CHAINS when snap_damage > 0:
			return "%d ennemis · %s s · %d dégâts/s · puis %d et figés %s s" % [
				bond_count, _number(duration), damage, snap_damage, _number(snap_stun)]
		Kind.SOUL_CHAINS:
			return "%d ennemis · portée %d · %d dégâts/s · ralentis à %d %% · %s s" % [
				bond_count, range, damage, int(slow_factor * 100.0), _number(duration)]
		Kind.GAOL when gaol_end_damage > 0:
			return "rayon %s · cloués %s s · %d dégâts/s · tirés vers lui · puis %d" % [
				_number(radius), _number(duration), damage, gaol_end_damage]
		Kind.GAOL:
			return "rayon %s · cloués %s s · %d dégâts/s" % [_number(radius), _number(duration), damage]
		Kind.DASH when dash_echo_damage > 0:
			return "%d cases · %d dégâts · %d entailles · écho %d" % [range, damage, cuts, dash_echo_damage]
		Kind.DASH:
			# Le Trait de l'étoile n'entaille pas : il aveugle.
			if cuts <= 0:
				return "%d cases · %d dégâts · aveugle %s s" % [range, damage, _number(blind_seconds)]
			return "%d cases · %d dégâts · %d entaille" % [range, damage, cuts]
		Kind.GUARD when guard_all:
			return "pare tout %s s · riposte %d · rayon %s · %d entailles" % [
				_number(duration), damage, _number(radius), cuts]
		Kind.GUARD:
			return "pare %s s · riposte %d · rayon %s · %d entailles" % [
				_number(duration), damage, _number(radius), cuts]
		Kind.SHEATHE when is_ultimate:
			return "tout l'écran · %d entailles · %d par entaille · %s s" % [cuts, cut_damage, _number(duration)]
		Kind.SHEATHE when petal_cuts > 0:
			return "%d par entaille · portée %d · pétales %d entaille (rayon %s)" % [
				cut_damage, range, petal_cuts, _number(petal_radius)]
		Kind.SHEATHE:
			return "%d par entaille · portée %d" % [cut_damage, range]
		Kind.BLINK when decoy_seconds > 0.0:
			return "%d cases · leurre %s s · %d dégâts · rayon %s" % [
				range, _number(decoy_seconds), damage, _number(decoy_radius)]
		Kind.ZONE when discord_bonus > 0.0:
			return "%d dégâts/s · +%d %% par ennemi en plus · rayon %s · %s s" % [
				damage, int(discord_bonus * 100.0), _number(radius), _number(duration)]
		Kind.ZONE:
			return "%d dégâts/s · rayon %s · %s s" % [damage, _number(radius), _number(duration)]
		Kind.SHIELD when reflect_damage > 0:
			return "INTOUCHABLE %.0f s · immobile · renvoie %d" % [duration, reflect_damage]
		Kind.SHIELD when immune:
			return "INTOUCHABLE %.0f s" % duration
		Kind.SHIELD:
			return "absorbe %d · %.0f s" % [damage, duration]
		Kind.HEAL:
			return "rend %d PV" % damage
		Kind.WALL:
			return "bloque %.0f s" % duration
		Kind.BLINK when rewind_seconds > 0.0:
			return "revient %s s en arrière" % _number(rewind_seconds)
		Kind.BLINK when blow_cells > 0:
			return "charge de %d cases · %d dégâts · renverse" % [range, trail_damage]
		Kind.BLINK when trail_damage > 0:
			return "saut de %d cases · traînée de %d dégâts" % [range, trail_damage]
		Kind.BLINK:
			return "saut de %d cases" % range
		Kind.ECHO when echo_second_seconds > 0.0:
			return "%d dégâts · deux doubles, %s s et %s s" % [damage, _number(echo_seconds),
				_number(echo_second_seconds)]
		Kind.ECHO:
			return "%d dégâts · rejoue %s s de marche" % [damage, _number(echo_seconds)]
		Kind.HOURGLASS when rewind_heal_seconds > 0.0:
			return "rend les PV perdus en %s s" % _number(rewind_heal_seconds)
		Kind.HOURGLASS:
			return "rend %d %% des PV perdus en %s s" % [
				int(hourglass_ratio * 100.0), _number(duration)]
		Kind.TIME_STOP when judgement_ratio > 0.0:
			return "tout se fige %s s · coups rendus à %d %%" % [_number(duration),
				int(round(judgement_ratio * 100.0))]
		Kind.TIME_STOP:
			return "tout se fige %s s" % _number(duration)
		Kind.TRAIL when trail_doses > 1:
			return "flaques %s s · %d doses · ralentit" % [_number(trail_life), trail_doses]
		Kind.TRAIL:
			return "flaques %s s · pendant %s s" % [_number(trail_life), _number(duration)]
		Kind.CONTAGION when epidemic_jumps > 0:
			return "%d sauts · %d dégâts et %d doses chacun" % [epidemic_jumps, damage, epidemic_doses]
		Kind.CONTAGION:
			return "passe le poison à %d cases · portée %d" % [chain_range, range]
		Kind.TRANSFUSION when bleed_per_dose > 0:
			return "%d dégâts par dose · 1 PV pour %d doses" % [bleed_per_dose, transfuse_per]
		Kind.TRANSFUSION:
			return "1 PV par %d ennemis empoisonnés" % transfuse_per
		Kind.PANDEMIC when plague_slow < 1.0:
			return "toute la carte empoisonnée au maximum %s s · ralentie · ils éclatent" % _number(duration)
		Kind.PANDEMIC:
			return "toute la carte empoisonnée %s s · ils éclatent" % _number(duration)
		Kind.BEAM:
			return "%d dégâts · rayon de %d cases dans les couloirs" % [damage, range]
		Kind.SOULS:
			return "%d dégâts par âme · portée %d" % [damage, range]
		Kind.LAST_HOUR:
			return "la moitié des PV de chaque ennemi · achève sous %d %%" \
				% int(CombatSystem.SENTENCE_BELOW * 100.0)
		Kind.CONSTELLATION when figure_damage > 0:
			return "%d dégâts/s · %d étoiles · la figure fermée brûle %d/s · %s s" % [
				int(round(float(damage) * CombatSystem.FIRMAMENT_RAY)), CombatSystem.FIRMAMENT_STARS, figure_damage,
				_number(duration)]
		Kind.CONSTELLATION:
			return "%d dégâts/s · %d étoiles · %s s" % [damage, CombatSystem.STAR_MAX, _number(duration)]
		Kind.BLADES when feather_rain > 0:
			return "%d plumes du ciel · %d dégâts · portée %d" % [feather_rain, damage, range]
		Kind.BLADES when not blades_return:
			return "%d plumes · %d dégâts · portée %d" % [blade_count, damage, range]
		Kind.BLADES:
			return "%d lames · %d dégâts à l'aller et au retour · portée %d" % [blade_count, damage, range]
		Kind.ANVIL:
			return "%d dégâts · étourdit %s s · %d cases de couloirs" % [damage, _number(stun_seconds), range]
		Kind.STARFALL:
			return "%d étoiles de %d dégâts · rayon %s" % [star_falls, damage, _number(radius)]
		Kind.DAWN:
			if sun_seconds > 0.0:
				return "%s s · un rayon de %d par seconde sur chaque ennemi à l'écran · puis %d dégâts rayon %s" % [
					_number(sun_seconds), sun_damage, sun_end_damage, _number(sun_end_radius)]
			if blind_seconds <= 0.0:
				return "%d dégâts sur toute la carte" % damage
			return "%d dégâts sur toute la carte · aveugle %s s" % [damage, _number(blind_seconds)]
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
