extends SceneTree

var failures: Array[String] = []

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)

func _init() -> void:
	var hero := HeroProgress.new()
	check(not hero.persistent, "une progression fictive ne sauvegarde pas")
	check(HeroProgress.threshold(10) == 900 and HeroProgress.threshold(20) == 2660 and HeroProgress.threshold(30) == 5220, "paliers de la courbe")
	hero.gain(899)
	check(hero.level() == 9 and hero.form() == 0, "avant l’éveil")
	hero.gain(1)
	check(hero.level() == 10 and hero.form() == 1, "éveil au niveau 10")
	hero.gain(-100)
	check(hero.xp == 900, "gain négatif ignoré")
	check(hero.win(1, 1) == 75 and hero.win(1, 1) == 50, "première victoire une seule fois")
	hero.gain(999999)
	# Le plafond est 80 depuis le Dragon d'or (2026-11-05) ; ni le Prisme ni le Dragon ne sont permanents.
	check(hero.level() == HeroProgress.MAX_LEVEL and HeroProgress.MAX_LEVEL == 80 and hero.ratio() == 1.0 \
		and hero.form() == 2, "plafond et pas de Prisme permanent")
	check(HeroCatalog.at_level(80, true, true).hero_form == 4, "Dragon d'or accessible au niveau 80")
	check(HeroCatalog.at_level(79, true, true).hero_form == 3, "pas de Dragon d'or avant 80")
	for rank in [1, 9, 10, 19, 20, 29, 30, 80]:
		var c := HeroCatalog.at_level(rank)
		check(c.action_bar().size() == 6, "six boutons à chaque niveau")
		check(c.id == "ael", "identité stable")
		check(c.hero_form < 3, "Prisme seulement en combat")
	check(HeroCatalog.at_level(30, true).hero_form == 3, "Prisme accessible au niveau 30")
	check(HeroCatalog.at_level(20).base_plates == 1, "plaque d’Ascendant")
	check(HeroCatalog.at_level(9).attack.damage > HeroCatalog.at_level(1).attack.damage, "dégâts entre les paliers")
	check(HeroCatalog.at_level(9).abilities[1].trail_damage > HeroCatalog.at_level(1).abilities[1].trail_damage, "les dégâts de la ruée suivent le niveau")
	var path := "/tmp/ael-progress-test-%d.cfg" % OS.get_process_id()
	var disk := HeroProgress.load_saved(path)
	disk.gain(900)
	disk.win(1, 1)
	var loaded := HeroProgress.load_saved(path)
	check(loaded.xp == 975 and loaded.win(1, 1) == 50, "XP et premières victoires sauvegardées")
	var transient := HeroProgress.new()
	transient.gain(100)
	check(HeroProgress.load_saved(path).xp == 1025, "progression fictive sans écriture")
	DirAccess.remove_absolute(path)
	if failures.is_empty():
		print("TOUS LES TESTS PASSENT — progression d’Aël")
	else:
		for message in failures:
			push_error(message)
	quit(0 if failures.is_empty() else 1)
