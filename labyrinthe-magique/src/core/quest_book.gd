class_name QuestBook
extends RefCounted

## LE CARNET DE QUÊTE — ce que le joueur est venu faire dans cet épisode.
##
## Il ne change AUCUNE règle. La mission est déjà écrite dans `LevelConfig` :
## ramasser les gemmes, franchir la porte, et sur deux épisodes de la campagne
## abattre les repaires. Le carnet la met en PHRASES et la suit en direct.
##
## Le manque qu'il comble n'est pas « qu'ai-je d'autre à faire » mais « que
## suis-je censé faire ici, et où j'en suis ». L'écran de jeu affiche des
## compteurs — une rangée de gemmes, `KILLS : 0/4` — et jamais une phrase. Un
## joueur qui reprend sa partie deux jours plus tard n'a rien pour se rappeler.
##
## ⚠️ TOUT EST DÉDUIT DE LA CONFIG, RIEN N'EST RECOPIÉ. C'est la règle des
## fiches générées (`docs/PERSONNAGES.md`) appliquée à l'interface : une quête
## qui annoncerait « ramasse 4 gemmes » sur un niveau qui en pose 6 serait un
## mensonge qu'aucun test n'attrape et qu'aucun joueur ne pardonne. La seule
## part écrite à la main est l'AMBIANCE — dix phrases de chapitre, qui ne
## portent aucun chiffre.
##
## ⚠️ Aucun `Node` ici, c'est la règle d'architecture n° 1 : `tests/test_quest.gd`
## vérifie les vingt épisodes en headless, avec le vrai code du jeu.

## L'ordre du chapitre, écrit à la main — la seule chose qui ne se déduit pas.
## Aucune de ces phrases ne contient de CHIFFRE : le nombre de gemmes change
## d'un épisode à l'autre et la ligne d'objectif s'en charge. Une ambiance qui
## compte à la place du code ment au premier réglage.
const ORDERS := [
	"Le labyrinthe s'éveille. Apprends à marcher entre ses haies, et ramasse ce qui brille.",
	"Les dunes ont enseveli trois caravanes. Leurs gemmes dorment encore sous le sable brûlant.",
	"La marée a rendu ce qu'elle avait pris. Trouve-le avant qu'elle ne se ravise.",
	"Les cavernes de cristal résonnent d'un chant qui n'est pas le tien. Ne t'y attarde pas.",
	"Le gel a scellé la montagne. Ce qu'il garde ne fondra pas tout seul.",
	"Rien ne pousse ici sans une raison. Prends les gemmes, ne demande pas laquelle.",
	"Les ruines se souviennent de ceux qui les ont bâties. Elles ne t'attendaient pas.",
	"Le sanctuaire a été profané avant ta venue. Recompose ce qui a été dispersé.",
	"Le seuil est gardé. Cette fois, il ne suffira pas de courir plus vite.",
	"Tout ce que tu as traversé menait ici. Ramasse, et franchis la dernière porte.",
]

## Ce que le SECOND épisode resserre, dit au joueur avec les mots du jeu.
## `LevelConfig._apply_episode` ajoute un poursuivant, une gemme et raccourcit le
## retour : trois faits, une phrase.
const SECOND_EPISODE := "Le même lieu, la garde doublée. Un poursuivant de plus, une gemme de plus, et moins de répit."

var config: LevelConfig


func _init(level_config: LevelConfig) -> void:
	config = level_config


## « Chapitre 3 · Épisode 2 — Les Rivages Océaniques ». Le mot CHAPITRE et pas
## « stage » : c'est ainsi que le jeu les compte depuis qu'un stage vaut deux
## épisodes, et l'interface ne doit pas parler une autre langue que ses règles.
func title() -> String:
	if config.is_demo:
		return "Terrain d'essai — %s" % config.level_name
	return "Chapitre %d · Épisode %d — %s" % [config.stage, config.episode, config.level_name]


func order() -> String:
	if config.is_demo:
		return "Ici rien ne compte : tout est débloqué, rien ne se recharge, et l'on n'y meurt pas. Essaie tes sorts."
	var index := clampi(config.stage - 1, 0, ORDERS.size() - 1)
	var text: String = ORDERS[index]
	if config.episode > 1:
		text += "\n" + SECOND_EPISODE
	return text


## LES OBJECTIFS, DANS L'ORDRE OÙ ILS SE FONT — et c'est un ordre réel, pas une
## présentation : la porte ne s'ouvre qu'au compte plein, les repaires tombent
## avant elle. Chaque entrée porte `done`, `text` et un `progress` déjà formaté,
## vide quand l'objectif ne se compte pas.
##
## Le carnet REÇOIT l'avancement, il ne va pas le chercher : il ne connaît ni le
## `Level` ni le `GameManager`, et c'est ce qui le rend vérifiable en headless.
func objectives(gems_taken: int, lairs_left: int, house_open: bool) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if config.is_demo:
		return out

	var gems: int = config.gem_count
	out.append({
		"text": "Ramasser les %d gemmes du lieu" % gems,
		"progress": "%d/%d" % [clampi(gems_taken, 0, gems), gems],
		"done": gems_taken >= gems,
	})

	# ⚠️ Les repaires ne sont destructibles qu'au dernier épisode des stages 3 et
	# 9. La ligne ne s'affiche donc QUE là — un objectif grisé « impossible ici »
	# apprendrait au joueur à ne pas lire son carnet.
	if config.must_destroy_lairs:
		out.append({
			"text": "Abattre les deux repaires",
			"progress": "%d/2" % (2 - clampi(lairs_left, 0, 2)),
			"done": lairs_left <= 0,
		})

	out.append({
		"text": "Franchir la porte du sanctuaire",
		"progress": "",
		"done": house_open and gems_taken >= gems,
	})
	return out


## LA NOUVEAUTÉ DU CHAPITRE — la créature que ce stage ajoute au bestiaire.
## Vide au second épisode : elle n'est plus une nouveauté, on l'a déjà vue.
## Vide aussi si le chapitre n'ajoute rien, ce qui n'arrive pas aujourd'hui mais
## coûte une ligne à prévoir.
func novelty() -> Array[String]:
	if config.is_demo or config.episode > 1:
		return []
	var index := clampi(config.stage - 1, 0, Bestiary.NEWCOMERS.size() - 1)
	var names: Array[String] = []
	for id in Bestiary.NEWCOMERS[index]:
		names.append(Bestiary.display_name(str(id)))
	return names


## Ce que le lieu offre en plus des gemmes, s'il offre quelque chose. Les
## potions n'apparaissent qu'à partir du stage 2 (`potion_count`), et le silence
## vaut mieux qu'une ligne « Potions : 0 ».
func provisions() -> String:
	if config.is_demo or config.potion_count <= 0:
		return ""
	if config.potion_count == 1:
		return "Une potion est cachée dans les couloirs."
	return "%d potions sont cachées dans les couloirs." % config.potion_count
