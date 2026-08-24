class_name Player
extends Actor

## Le mage. Traduit un vecteur d'entrée analogique (clavier, joystick tactile,
## manette) en une direction cardinale sur la grille, et joue la planche
## d'animation de SON personnage.
##
## Les sept mages ont chacun leurs quatre bandes — down, up, left, right — de six
## poses : IDLE, WALK 1 à 4, ATTACK. Rien n'est écrit en dur ici : le dossier et
## le descripteur viennent du personnage choisi, et redécouper une planche ne
## demande aucune modification de ce fichier.
##
## Contrairement à l'ancienne planche unique, la gauche n'est PLUS un miroir de
## la droite : l'illustrateur a dessiné les deux, et un mage dont la cape se
## drape du même côté quel que soit le sens de marche se remarque.

const CHARACTERS_PATH := "res://assets/characters/"
const INPUT_THRESHOLD := 0.25
## Poses par seconde pendant la marche. Quatre poses par cycle : à 9, une foulée
## dure un peu moins d'une demi-seconde, ce qui colle à 5 cases/s sans patiner.
const WALK_FPS := 9.0
## Durée de la pose d'attaque. C'est un GESTE, pas un cycle : elle se joue une
## fois puis rend la main à la marche.
const ATTACK_DURATION := 0.32

## Rempli chaque frame par le manche tactile (voir TouchStick).
var touch_direction: Vector2 = Vector2.ZERO
## Pilotage par les outils de développement (--auto-walk). PRIORITAIRE sur les
## entrées : le GameManager réécrit `touch_direction` à chaque frame avant que
## le joueur ne la lise, une direction posée là serait donc toujours effacée.
var debug_direction: Vector2 = Vector2.ZERO

var character_id := CharacterCatalog.default_id()

## Ordre de marche « toucher le chemin » : champ de distances BFS depuis la case
## visée, que l'on descend pas à pas — exactement le mécanisme des ennemis, mais
## à l'envers. Vide quand aucun ordre n'est en cours. Toute entrée MANUELLE
## (clavier, manche, manette) annule l'ordre : le pouce a toujours raison.
var _path_field := PackedInt32Array()
var _path_goal := Vector2i(-1, -1)

var _textures := {}
var _cell := Vector2(128.0, 112.0)
var _feet_y := 108.0
var _poses: Array = ["idle", "walk_1", "walk_2", "walk_3", "walk_4", "attack"]
## Dernière direction non nulle : le mage garde sa pose quand il s'arrête.
var _facing: Vector2i = Vector2i.DOWN
var _walk_phase := 0.0
var _attack_left := 0.0


## Appelée par le Level AVANT setup() : la planche à charger dépend du mage.
func set_character(stats: CharacterStats) -> void:
	character_id = stats.id if stats != null else CharacterCatalog.default_id()
	_load_character()


func _ready() -> void:
	if _textures.is_empty():
		_load_character()
	# Le mage occupe environ deux cases de haut : assez pour qu'on lise le
	# dessin, pas au point de masquer le couloir devant lui.
	target_height = 58.0
	# Les pieds tombent sur l'origine : l'ombre se pose donc là, et non plus
	# sous le ventre comme pour les ennemis.
	shadow_offset = 0.02
	shadow_radius = 0.26


## Direction regardée, même à l'arrêt. Les sorts directionnels (mur de pierre,
## translation) en dépendent : sans elle, un mage immobile ne saurait pas où
## poser sa pierre.
func facing() -> Vector2i:
	return _facing


## Déclenché par le Level au départ d'un sort. La pose prime sur la marche : on
## voit le mage lancer son sort même s'il continue de courir.
func play_cast() -> void:
	_attack_left = ATTACK_DURATION


## Réapparition après une translation : le mage revient en fondu plutôt qu'en
## surgissant. Court — 0,26 s — parce qu'un mage invisible pendant une poursuite
## est un mage qu'on ne peut pas piloter.
func play_warp() -> void:
	_warp_left = WARP_FADE


## Fondu de réapparition, en secondes.
const WARP_FADE := 0.26

var _warp_left := 0.0


func _load_character() -> void:
	var folder := CHARACTERS_PATH + character_id + "/"
	var text := FileAccess.get_file_as_string(folder + "frames.json")
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("Descripteur d'animation introuvable pour « %s »" % character_id)
		return
	var data: Dictionary = parsed
	var cell: Array = data["cell"]
	_cell = Vector2(float(cell[0]), float(cell[1]))
	_feet_y = float(data["feet_y"])
	_poses = data["poses"]

	_textures.clear()
	for direction in data["directions"]:
		var texture: Texture2D = load(folder + str(direction) + ".png")
		if texture != null:
			_textures[str(direction)] = texture
	if sprite != null:
		_apply_visual()


## Redéfinit la mise en place d'Actor : une seule image découpée en poses
## (hframes), pas de pieds séparés — ils sont dessinés dans la planche.
func _apply_visual() -> void:
	if sprite == null or _textures.is_empty():
		return
	foot_left.visible = false
	foot_right.visible = false
	var factor := target_height / _cell.y
	sprite.scale = Vector2(factor, factor)
	sprite.region_enabled = false
	sprite.vframes = 1
	sprite.hframes = maxi(1, _poses.size())
	sprite.flip_h = false
	# Les pieds tombent sur l'origine du nœud, là où le Level pose le mage et
	# où Actor dessine son ombre de contact.
	sprite.offset = Vector2(0.0, _cell.y * 0.5 - _feet_y)
	_apply_frame()


func _direction_key() -> String:
	if _facing == Vector2i.UP:
		return "up"
	if _facing == Vector2i.LEFT:
		return "left"
	if _facing == Vector2i.RIGHT:
		return "right"
	return "down"


func _apply_frame() -> void:
	var texture: Texture2D = _textures.get(_direction_key())
	if texture == null:
		return
	if sprite.texture != texture:
		sprite.texture = texture
	var index := _poses.find("attack") if _attack_left > 0.0 else -1
	if index < 0:
		if mover != null and mover.is_moving():
			# Quatre poses de marche, en boucle.
			index = 1 + (int(_walk_phase) % maxi(1, _poses.size() - 2))
		else:
			index = 0
	sprite.frame = clampi(index, 0, _poses.size() - 1)


## Redéfinit l'animation procédurale d'Actor.
func _animate(delta: float) -> void:
	if sprite == null:
		return
	_attack_left = maxf(0.0, _attack_left - delta)
	if _warp_left > 0.0:
		_warp_left = maxf(0.0, _warp_left - delta)
		# Réapparition : le mage revient du transparent, et blanchi — c'est ce
		# qui fait lire une arrivée plutôt qu'un simple fondu d'opacité.
		var back := 1.0 - _warp_left / WARP_FADE
		sprite.modulate = Color(1.0 + 1.6 * (1.0 - back), 1.0 + 1.6 * (1.0 - back),
			1.0 + 1.6 * (1.0 - back), 0.25 + 0.75 * back)
	elif sprite.modulate != Color(1, 1, 1, 1):
		sprite.modulate = Color(1, 1, 1, 1)

	if mover.direction != Vector2i.ZERO:
		_facing = mover.direction
		_walk_phase += delta * WALK_FPS
	else:
		# À l'arrêt, on revient à la pose de repos plutôt que de figer un pas en
		# l'air : un personnage immobile jambe levée se remarque immédiatement.
		_walk_phase = 0.0
	_apply_frame()


## Le Level a validé la case (sol, atteignable) : ici on ne fait qu'obéir.
func walk_to(goal: Vector2i, field: PackedInt32Array) -> void:
	_path_field = field
	_path_goal = goal


func cancel_path() -> void:
	_path_field = PackedInt32Array()
	_path_goal = Vector2i(-1, -1)


func has_path() -> bool:
	return not _path_field.is_empty()


func path_goal() -> Vector2i:
	return _path_goal


func _update_desired(_delta: float) -> void:
	var input_vector := debug_direction
	if input_vector.length() < INPUT_THRESHOLD:
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector.length() < INPUT_THRESHOLD:
		input_vector = touch_direction

	if input_vector.length() < INPUT_THRESHOLD:
		if has_path():
			_follow_path()
			return
		mover.desired_direction = Vector2i.ZERO
		return
	# Une entrée manuelle reprend la main : deux pilotes qui se disputent le
	# mage donneraient un personnage qui « revient tout seul » vers la marque.
	cancel_path()

	# Axe dominant d'abord, axe secondaire en repli. C'est ce repli qui empêche
	# le personnage de "coller" à une intersection quand le stick est poussé en
	# diagonale : si le virage souhaité est bouché, on prend l'autre composante
	# plutôt que de s'arrêter.
	var primary: Vector2i
	var secondary := Vector2i.ZERO
	if absf(input_vector.x) >= absf(input_vector.y):
		primary = Vector2i(int(signf(input_vector.x)), 0)
		if absf(input_vector.y) > INPUT_THRESHOLD:
			secondary = Vector2i(0, int(signf(input_vector.y)))
	else:
		primary = Vector2i(0, int(signf(input_vector.y)))
		if absf(input_vector.x) > INPUT_THRESHOLD:
			secondary = Vector2i(int(signf(input_vector.x)), 0)

	var decision := mover.decision_cell()
	if mover.can_walk(decision + primary):
		mover.desired_direction = primary
	elif secondary != Vector2i.ZERO and mover.can_walk(decision + secondary):
		mover.desired_direction = secondary
	else:
		mover.desired_direction = primary


func _follow_path() -> void:
	var from := mover.decision_cell()
	if from == _path_goal:
		cancel_path()
		mover.desired_direction = Vector2i.ZERO
		return
	var step := Pathfinder.step_toward(mover.grid, _path_field, from)
	# Pas de descente possible, ou couloir bouché depuis l'ordre (un mur de
	# pierre a pu se lever sur le trajet) : on s'arrête plutôt que de pousser
	# contre le mur — un mage qui piétine sur place se lit comme un bug.
	if step == Vector2i.ZERO or not mover.can_walk(from + step):
		cancel_path()
		mover.desired_direction = Vector2i.ZERO
		return
	mover.desired_direction = step
