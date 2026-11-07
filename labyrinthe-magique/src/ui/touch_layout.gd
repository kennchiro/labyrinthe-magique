class_name TouchLayout
extends RefCounted

## La disposition des commandes tactiles choisie par le joueur : où, quelle taille,
## quelle opacité. RefCounted sans un seul Node, comme le reste des règles, pour que
## `tests/test_touch_layout.gd` éprouve sa géométrie sans afficher d'écran.
##
## ⚠️ ELLE NE STOCKE QUE CE QUE LE JOUEUR A CHANGÉ. Tout ce qui n'y figure pas garde
## sa place déduite (`CombatPad._fan`, `TouchStick._origin`) : la géométrie continue
## de se calculer pour l'écran courant, et une disposition vide est exactement le jeu
## d'avant.
##
## Les positions sont en FRACTIONS de l'écran : l'interface se compte en unités de
## mise en page, et leur nombre change selon l'appareil.
##
## ⚠️ UN PLACEMENT LIBRE PEUT RECRÉER LE DÉFAUT DE LA FUITE ET DU TROISIÈME SORT : deux
## boutons l'un sur l'autre, on vise l'un et on déclenche l'autre. `settle` refuse
## donc tout chevauchement, quel que soit le geste qui y mène.

const MOVE := "move"
const MIN_SCALE := 0.6
const MAX_SCALE := 1.5
## En dessous, un bouton ne se voit plus du tout pendant une poursuite.
const MIN_ALPHA := 0.25
## Jeu minimal entre deux commandes. Le même que `tests/test_pad.gd` exige de l'éventail.
const GAP := 8.0
## Marge au bord de l'écran, comme l'éventail en garde une.
const EDGE := 4.0
## La pause et le carnet, côte à côte en haut de l'écran. Ils se pressent : une commande
## posée dessus se déclencherait en même temps qu'eux.
##
## ⚠️ PAS DANS LE COIN. Ils y couvraient l'ultime, le bouton le plus haut de l'éventail,
## sur tous les écrans mesurés : l'éventail par défaut ne passe pas par `settle`. Ils se
## rangent donc à sa gauche, en mode tactile. Combien à gauche dépend de l'écran : sur un
## petit téléphone l'éventail se resserre et un deuxième bouton monte dans la bande.
const CORNER_SIZE := Vector2(124.0, 76.0)
## Distance de la zone au bord droit, que `fit_corner` déduit de l'éventail réel.
static var corner_right := 204.0
## La barre du mage (`HUD`). Elle ne se presse pas, mais elle dit combien de vie il
## reste : un bouton opaque par-dessus coûterait une partie sans qu'on sache pourquoi.
const TOP_LEFT := Vector2(HUD.FRAME_WIDTH + 18.0, 104.0)
const SETTLE_PASSES := 64

## id -> {"at": Vector2 en fractions, "scale": float, "alpha": float}. Chaque clé est
## facultative, et une commande sans réglage n'a pas d'entrée.
var custom := {}


static func button_id(index: int) -> String:
	return "b%d" % index


## Les zones qu'une commande déplacée n'a pas le droit de recouvrir.
static func reserved(view: Vector2) -> Array[Rect2]:
	return [Rect2(Vector2.ZERO, TOP_LEFT), corner(view)]


## La place de la pause et du carnet en mode tactile, que l'UIManager leur donne.
static func corner(view: Vector2) -> Rect2:
	return Rect2(Vector2(view.x - corner_right - CORNER_SIZE.x, 0.0), CORNER_SIZE)


## Range la zone à gauche de ce que l'éventail par défaut occupe en haut de l'écran.
static func fit_corner(pad: CombatPad) -> void:
	corner_right = pad.reach_from_right(CORNER_SIZE.y + GAP) + GAP


## Relit ce qu'a écrit le disque. Un fichier abîmé ou une valeur hors bornes ne doit
## jamais donner un bouton invisible ou introuvable : ce qui ne convient pas tombe.
static func from_data(data: Variant) -> TouchLayout:
	var layout := TouchLayout.new()
	if not data is Dictionary:
		return layout
	for id: Variant in data:
		var source: Variant = data[id]
		if not source is Dictionary:
			continue
		if source.get("at") is Vector2:
			var at: Vector2 = source["at"]
			if at.is_finite():
				layout._write(str(id), "at", at.clamp(Vector2.ZERO, Vector2.ONE))
		if _is_number(source.get("scale")):
			layout.set_scale(str(id), float(source["scale"]))
		if _is_number(source.get("alpha")):
			layout.set_alpha(str(id), float(source["alpha"]))
	return layout


static func _is_number(value: Variant) -> bool:
	return (value is float and is_finite(value)) or value is int


func to_data() -> Dictionary:
	return custom.duplicate(true)


func is_default() -> bool:
	return custom.is_empty()


func has_position(id: String) -> bool:
	return custom.has(id) and custom[id].has("at")


func centre_of(id: String, view: Vector2, fallback: Vector2, extent: float) -> Vector2:
	if not has_position(id):
		return fallback
	return kept_on_screen(custom[id]["at"] * view, view, extent)


func set_centre(id: String, point: Vector2, view: Vector2) -> void:
	_write(id, "at", (point / view).clamp(Vector2.ZERO, Vector2.ONE))


func scale_of(id: String) -> float:
	return float(custom[id].get("scale", 1.0)) if custom.has(id) else 1.0


func set_scale(id: String, value: float) -> void:
	_write(id, "scale", clampf(value, MIN_SCALE, MAX_SCALE))


func alpha_of(id: String) -> float:
	return float(custom[id].get("alpha", 1.0)) if custom.has(id) else 1.0


func set_alpha(id: String, value: float) -> void:
	_write(id, "alpha", clampf(value, MIN_ALPHA, 1.0))


func _write(id: String, key: String, value: Variant) -> void:
	if not custom.has(id):
		custom[id] = {}
	custom[id][key] = value


static func kept_on_screen(point: Vector2, view: Vector2, extent: float) -> Vector2:
	var margin := extent + EDGE
	return Vector2(
		view.x * 0.5 if view.x < margin * 2.0 else clampf(point.x, margin, view.x - margin),
		view.y * 0.5 if view.y < margin * 2.0 else clampf(point.y, margin, view.y - margin))


## Écarte les commandes de `movable` jusqu'à ce qu'elles ne gênent plus rien, et dit si
## c'est fait. Les autres ne bougent pas : poser un bouton ne doit pas déranger ce que
## le joueur a déjà placé.
##
## `items` : [{id, at, radius, extent}]. `radius` est la portée au TOUCHER, celle qui ne
## doit rien recouvrir ; `extent` est le dessin, celui qui doit tenir à l'écran.
static func settle(items: Array[Dictionary], view: Vector2, movable: Array[String]) -> bool:
	for pass_index in SETTLE_PASSES:
		if conflicts(items, view, movable).is_empty():
			return true
		for i in items.size():
			for j in range(i + 1, items.size()):
				_separate(items[i], items[j], movable, pass_index)
		for item in items:
			if item["id"] in movable:
				_leave_reserved(item, view)
				item["at"] = kept_on_screen(item["at"], view, item["extent"])
	return conflicts(items, view, movable).is_empty()


## Ce qui gêne encore, pour les commandes de `movable`. Deux commandes qui ne bougent
## pas ne se reprochent rien : la place déduite d'un très petit écran n'est pas un
## choix du joueur, et elle a son propre test.
static func conflicts(items: Array[Dictionary], view: Vector2, movable: Array[String]) -> Array[String]:
	var found: Array[String] = []
	for i in items.size():
		var item := items[i]
		var moves: bool = item["id"] in movable
		if moves:
			var kept := kept_on_screen(item["at"], view, item["extent"])
			if kept.distance_to(item["at"]) > 0.5 or not _fits(item, view):
				found.append(item["id"])
			for zone in reserved(view):
				if _reaches(zone, item["at"], item["extent"] + GAP):
					found.append(item["id"])
		for j in range(i + 1, items.size()):
			var other := items[j]
			if not moves and not other["id"] in movable:
				continue
			var need: float = item["radius"] + other["radius"] + GAP
			if Vector2(item["at"]).distance_to(other["at"]) < need - 0.01:
				if moves:
					found.append(item["id"])
				if other["id"] in movable:
					found.append(other["id"])
	return found


static func _fits(item: Dictionary, view: Vector2) -> bool:
	var span: float = (float(item["extent"]) + EDGE) * 2.0
	return span <= view.x and span <= view.y


static func _reaches(zone: Rect2, point: Vector2, reach: float) -> bool:
	return point.distance_to(point.clamp(zone.position, zone.end)) < reach - 0.01


static func _separate(a: Dictionary, b: Dictionary, movable: Array[String], salt: int) -> void:
	var a_moves: bool = a["id"] in movable
	var b_moves: bool = b["id"] in movable
	if not a_moves and not b_moves:
		return
	var between := Vector2(b["at"]) - Vector2(a["at"])
	var missing: float = float(a["radius"]) + float(b["radius"]) + GAP - between.length()
	if missing <= 0.0:
		return
	# Deux centres confondus n'ont pas de direction : on en prend une, changeante pour
	# ne pas repousser dix fois de suite contre le même bord.
	var away := between.normalized() if between.length() > 0.01 \
		else Vector2.RIGHT.rotated(float(salt) * 2.399)
	var share := 0.5 if a_moves and b_moves else 1.0
	if a_moves:
		a["at"] = Vector2(a["at"]) - away * missing * share
	if b_moves:
		b["at"] = Vector2(b["at"]) + away * missing * share


static func _leave_reserved(item: Dictionary, view: Vector2) -> void:
	var reach: float = float(item["extent"]) + GAP
	var at: Vector2 = item["at"]
	for zone in reserved(view):
		var nearest := at.clamp(zone.position, zone.end)
		var outside := at - nearest
		if outside.length() >= reach:
			continue
		if outside.length() > 0.01:
			at = nearest + outside.normalized() * reach
		else:
			# Le centre est DANS la zone. On sort par le dessous, le seul côté qui ramène
			# toujours vers l'écran : les deux zones sont collées au bord du haut.
			at.y = zone.end.y + reach
	item["at"] = at
