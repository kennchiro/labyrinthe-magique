extends SceneTree

## Prouve que le CARNET DE QUÊTE dit la vérité sur les vingt épisodes.
##   godot --headless --path . --script res://tests/test_quest.gd
##
## Ce test existe pour une raison précise : le carnet est le seul endroit du jeu
## où une consigne est écrite en toutes lettres, et une consigne fausse est pire
## que pas de consigne — le joueur cherche sept gemmes là où le niveau en pose
## six et croit le jeu cassé. Rien dans le moteur ne l'attraperait : le texte
## s'afficherait très bien.
##
## On ne teste donc PAS que le carnet affiche quelque chose, mais qu'il affiche
## EXACTEMENT ce que `LevelConfig` contient. Aucune valeur n'est écrite ici en
## dur : chaque attente est relue de la config du niveau.

var _failures: Array[String] = []


func _init() -> void:
	for config in LevelConfig.all_levels():
		_test_level(config)
	_test_demo()

	print("")
	if _failures.is_empty():
		print("✅  TOUS LES TESTS PASSENT (%d épisodes)" % LevelConfig.all_levels().size())
	else:
		print("❌  %d ÉCHEC(S) :" % _failures.size())
		for f in _failures:
			print("   - ", f)
	quit(0 if _failures.is_empty() else 1)


func _test_level(config: LevelConfig) -> void:
	var where := "stage %d ép. %d" % [config.stage, config.episode]
	var book := QuestBook.new(config)

	if not book.title().contains(str(config.stage)):
		_fail(where, "le titre ne porte pas le numéro de chapitre : « %s »" % book.title())
	if not book.title().contains(config.level_name):
		_fail(where, "le titre ne porte pas le nom du lieu : « %s »" % book.title())
	if book.order().strip_edges().is_empty():
		_fail(where, "aucun ordre de mission")

	# LES CHIFFRES DU TEXTE VIENNENT DE LA CONFIG, c'est tout l'enjeu du test.
	var goals := book.objectives(0, 2, false)
	var expected := 3 if config.must_destroy_lairs else 2
	if goals.size() != expected:
		_fail(where, "%d objectifs au lieu de %d" % [goals.size(), expected])
		return
	if not str(goals[0]["text"]).contains(str(config.gem_count)):
		_fail(where, "l'objectif des gemmes annonce autre chose que %d : « %s »"
			% [config.gem_count, str(goals[0]["text"])])
	if str(goals[0]["progress"]) != "0/%d" % config.gem_count:
		_fail(where, "avancement des gemmes faux : « %s »" % str(goals[0]["progress"]))

	# La ligne des repaires n'existe QUE là où ils sont destructibles. Un
	# objectif impossible affiché « pour la forme » apprend à ne plus lire.
	var has_lairs := false
	for goal in goals:
		if str(goal["text"]).contains("repaire"):
			has_lairs = true
	if has_lairs != config.must_destroy_lairs:
		_fail(where, "ligne des repaires %s alors que must_destroy_lairs = %s"
			% ["présente" if has_lairs else "absente", str(config.must_destroy_lairs)])

	# AUCUN OBJECTIF FAIT AU DÉPART. Un carnet qui s'ouvre déjà à moitié coché
	# au premier pas du niveau se lit comme une erreur de comptage.
	for goal in goals:
		if bool(goal["done"]):
			_fail(where, "objectif déjà coché au départ : « %s »" % str(goal["text"]))

	# ... et tout est fait quand tout est fait.
	var done := book.objectives(config.gem_count, 0, true)
	for goal in done:
		if not bool(goal["done"]):
			_fail(where, "objectif non coché une fois rempli : « %s »" % str(goal["text"]))

	# LA NOUVEAUTÉ N'EST NOUVELLE QU'UNE FOIS : au second épisode du chapitre, la
	# créature a déjà été rencontrée.
	if config.episode > 1 and not book.novelty().is_empty():
		_fail(where, "annonce une nouveauté au second épisode : %s" % str(book.novelty()))
	if config.episode == 1 and book.novelty().is_empty():
		_fail(where, "aucune nouveauté annoncée au premier épisode")

	# Les potions ne sont mentionnées que là où il y en a.
	if config.potion_count <= 0 and not book.provisions().is_empty():
		_fail(where, "parle de potions alors qu'il n'y en a pas")
	# ⚠️ AU SINGULIER LE TEXTE N'A PAS DE CHIFFRE — il dit « Une potion », ce qui
	# est le bon français. Exiger le chiffre partout ferait échouer un texte
	# juste : le test doit vérifier ce que la phrase PROMET, pas sa forme.
	if config.potion_count > 0:
		var promise := book.provisions()
		if not promise.contains("potion"):
			_fail(where, "n'annonce pas les potions du lieu")
		elif config.potion_count > 1 and not promise.contains(str(config.potion_count)):
			_fail(where, "n'annonce pas le nombre de potions (%d) : « %s »"
				% [config.potion_count, promise])


## LE TERRAIN D'ESSAI N'A PAS DE MISSION, et le carnet doit le dire en se
## taisant plutôt qu'en cochant des cases qui ne comptent pas.
func _test_demo() -> void:
	var demo := LevelConfig.demo()
	var book := QuestBook.new(demo)
	if not book.objectives(0, 2, false).is_empty():
		_fail("démo", "affiche des objectifs")
	if not book.novelty().is_empty():
		_fail("démo", "annonce une nouveauté")
	if book.order().strip_edges().is_empty():
		_fail("démo", "ne dit pas à quoi sert le terrain d'essai")


func _fail(where: String, what: String) -> void:
	_failures.append("%s : %s" % [where, what])
