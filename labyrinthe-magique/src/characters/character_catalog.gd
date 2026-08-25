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
	c.ultimate_required_kills = 4
	c.attack = Ability.make({
		"id": "shadow_orb", "display_name": "Orbe d'ombre",
		"description": "Une bille d'ombre qui remonte les couloirs jusqu'à sa cible.",
		"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SHADOW,
		"damage": 16, "range": 10, "cooldown": 0.45,
	})
	c.abilities = [
		Ability.make({
			"id": "shadow_rune", "display_name": "Rune",
			"description": "Un passage laissé au sol. Qui marche dessus rampe et perd 10 PV par seconde tant qu'il n'en est pas sorti.",
			"kind": Ability.Kind.ZONE, "element": Element.Kind.SHADOW,
			# LE PORTAIL DU MAGE, POSÉ AU SOL. Il reprend le dessin de sa
			# translation — le même passage, ouvert pour soi ou laissé derrière
			# soi — au lieu du disque générique des zones.
			#
			# TROIS CHARGES rendues d'un coup après 8 s : on ne pose pas un
			# passage, on installe un DISPOSITIF. Trois recharges séparées
			# donneraient un sort qu'on lance sans y penser ; une seule qui rend
			# tout oblige à choisir le moment où l'on ouvre les trois.
			"zone_style": "portail", "charges": 3,
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
			"id": "shadow_blink", "display_name": "Translation",
			"description": "Saut instantané de quelques cases dans la direction regardée.",
			"kind": Ability.Kind.BLINK, "element": Element.Kind.SHADOW,
			"range": 4, "cooldown": 9.0,
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
			"flames": 0.6, "zone_style": "nappe",
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
			"snare": 5.0, "snare_burn": 3.0, "flames": 1.0, "zone_style": "brasier",
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
			"zone_style": "nappe",
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
		"column_burst": true, "flames": 1.0,
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
