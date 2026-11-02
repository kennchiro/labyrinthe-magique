class_name Progress
extends RefCounted

## Ce que le joueur a acquis DÉFINITIVEMENT : ses stages ouverts.
##
## Sauvegardé sur le disque. Les sorts n'y sont plus : ils sont tous disponibles dès
## le départ, seules leurs recharges les limitent.
##
## Aucune dépendance au moteur de scène en dehors de ConfigFile : la simulation
## d'équilibrage peut donc se fabriquer une progression fictive sans toucher au
## fichier du joueur.

const PATH := "user://progress.cfg"

## Index du stage le plus avancé jamais atteint. Le menu n'en propose pas plus.
var reached_stage := 0
## Épisode atteint dans ce stage.
var reached_episode := 0
## Cette progression a-t-elle le droit d'écrire sur le disque ?
##
## FAUX PAR DÉFAUT, et c'est délibéré : seule une progression revenue du disque
## (`load_saved`) a le droit d'y réécrire. Toutes les autres — tests, simulation
## d'équilibrage, outils de développement — sont fabriquées en mémoire et ne
## doivent jamais toucher au fichier d'un joueur.
##
## Le défaut inverse a coûté une sauvegarde : un test appelait `reach(5, 2)` sur
## un `Progress.new()`, et la partie du joueur s'est retrouvée au stage 5. Un
## garde-fou qu'il faut penser à activer n'en est pas un.
var persistent := false


static func load_saved() -> Progress:
	var progress := Progress.new()
	var file := ConfigFile.new()
	progress.persistent = true
	if file.load(PATH) == OK:
		progress.reached_stage = int(file.get_value("progress", "stage", 0))
		progress.reached_episode = int(file.get_value("progress", "episode", 0))
	return progress


## Progression fictive, pour les tests et l'équilibrage : tout est ouvert.
static func everything(stages: int = 99) -> Progress:
	var progress := Progress.new()
	progress.reached_stage = stages
	return progress


func save() -> void:
	if not persistent:
		return
	var file := ConfigFile.new()
	file.set_value("progress", "stage", reached_stage)
	file.set_value("progress", "episode", reached_episode)
	file.save(PATH)


## Le stage est-il proposé au menu ?
##
## Tous ceux déjà bouclés, PLUS le suivant : sans ce « plus un », un joueur qui
## vient de finir le stage 1 ne pourrait pas choisir le stage 2 depuis le menu,
## alors que c'est précisément là qu'il va. La campagne s'ouvre donc devant lui
## d'un cran, jamais de deux.
func stage_unlocked(stage: int) -> bool:
	return stage <= reached_stage + 1


## L'épisode est-il proposé ?
##
## Le premier épisode d'un stage ouvert l'est toujours. Le second demande que le
## premier ait été gagné — c'est ce qui fait des deux épisodes un chapitre et
## non deux niveaux indépendants.
func episode_unlocked(stage: int, episode: int) -> bool:
	if not stage_unlocked(stage):
		return false
	if episode <= 1:
		return true
	if stage < reached_stage:
		return true
	return stage == reached_stage and reached_episode >= 1


func reach(stage: int, episode: int) -> void:
	if stage > reached_stage or (stage == reached_stage and episode > reached_episode):
		reached_stage = maxi(reached_stage, stage)
		reached_episode = episode if stage >= reached_stage else reached_episode
		save()
