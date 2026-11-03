class_name Player
extends Actor

## Le mage. Traduit un vecteur d'entrée analogique (clavier, joystick tactile,
## manette) en une direction cardinale sur la grille, et joue la planche
## d'animation de SON personnage.
##
## Les mages ont chacun leurs quatre bandes — down, up, left, right. Elles portent
## six poses (IDLE, WALK 1 à 4, ATTACK) ou dix-sept sur les planches animées (IDLE,
## 8 pas, 8 images d'attaque) : les rôles se lisent dans le NOM des poses, comme
## pour `Enemy`. Le dossier et le descripteur viennent du personnage choisi, et
## redécouper une planche ne demande aucune modification de ce fichier.
##
## Contrairement à l'ancienne planche unique, la gauche n'est PLUS un miroir de
## la droite : l'illustrateur a dessiné les deux, et un mage dont la cape se
## drape du même côté quel que soit le sens de marche se remarque.

const CHARACTERS_PATH := "res://assets/characters/"
const INPUT_THRESHOLD := 0.25
## Poses par seconde pendant la marche, pour un cycle de quatre poses. À 11, un cycle
## dure 0,36 s à 5 cases/s. Le sol défile encore environ 3 fois plus vite que le pied
## dessiné (0,6 case par cycle sur le Feu), mais le coller demanderait plus de 60 images
## par seconde : au-delà de 24, l'œil lit un tremblement.
const WALK_FPS := 11.0
## Durée de la pose d'attaque. C'est un GESTE, pas un cycle : elle se joue une
## fois puis rend la main à la marche.
const ATTACK_DURATION := 0.32
## Foulée qui correspond à WALK_FPS. La cadence suit la vitesse du mage : du plus
## lent au plus rapide, 4,5 à 5,3 cases/s, le pied patinerait sinon.
const WALK_REFERENCE_SPEED := 5.0
## Le dessin de marche bouge peu d'une pose à l'autre : ce léger rebond, deux fois
## par cycle comme les appuis, donne le poids que les poses seules n'ont pas.
const WALK_BOB := 1.0
## Hauteur de la case à l'écran pour une planche à six poses.
const DEFAULT_TARGET_HEIGHT := 58.0
## Hauteur du CORPS à l'écran pour une planche animée : la même que les six poses.
## Sa case grandit avec le sort, c'est donc le corps qu'il faut fixer.
const BODY_SCREEN_HEIGHT := 38.0
## Élan du geste de sort : le corps s'étire au départ puis retombe.
const CAST_PUNCH := Vector2(0.12, -0.08)
## Le répit qui suit un coup encaissé : un éclair rouge, puis un clignotement qui
## dure exactement ce que dure l'invulnérabilité.
const HURT_FLASH := 0.14
const HURT_TINT := Color(1.9, 0.55, 0.5)
const HURT_BLINK_SPEED := 11.0
const HURT_BLINK_ALPHA := 0.42
## Rayon de l'arc de lame, rapporté à la hauteur du corps : la portée de l'épée dessinée.
const SLASH_RADIUS := 0.8

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
## Poses rangées par rôle, remplies au chargement.
var _walk_poses: Array[int] = [1, 2, 3, 4]
var _attack_poses: Array[int] = [5]
var _display_height := DEFAULT_TARGET_HEIGHT
var _attack_left := 0.0
## Vers où part le sort en cours. La pose ne suit donc pas la course : un mage qui
## fuit vers le bas et tire sur ce qui le suit doit se retourner pour le faire.
var _cast_facing := Vector2i.ZERO
var _hurt_left := 0.0
var _hurt_total := 1.0
## Le gabarit d'animation du personnage, null s'il n'en déclare pas (voir `MotionProfile`).
var _motion: MotionProfile = null
## Ressorts visuels du gabarit : la penchée, et l'à-coup du départ et de l'arrêt.
var _lean := 0.0
var _lean_speed := 0.0
var _jolt := 0.0
var _jolt_speed := 0.0
var _was_moving := false
var _last_direction := Vector2i.ZERO
var _last_step := -1
var _struck := false
var _slashed := false
var _dust: FootDust = null
## L'Envol de l'Archange du Ciel : de combien de pixels le dessin s'élève, et de combien il grandit.
## Seul le DESSIN monte : l'origine du nœud, son ombre et ses collisions restent au sol.
var lift := 0.0
var lift_scale := 1.0
var _hover := 0.0


## Appelée par le Level AVANT setup() : la planche à charger dépend du mage.
func set_character(stats: CharacterStats) -> void:
	character_id = stats.id if stats != null else CharacterCatalog.default_id()
	_load_character()


func _ready() -> void:
	if _textures.is_empty():
		_load_character()
	# Le mage occupe environ deux cases de haut : assez pour qu'on lise le
	# dessin, pas au point de masquer le couloir devant lui.
	target_height = _display_height
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
##
## `target` est la position visée, s'il y en a une. Le profil passe avant la face
## et le dos dès que la cible est sur le côté : ce sont les poses où le geste se
## lit, et sur les planches le bras de face part toujours vers la droite.
func play_cast(target: Variant = null) -> void:
	_attack_left = _attack_duration()
	_struck = false
	_slashed = false
	_cast_facing = Vector2i.ZERO
	if target is Vector2:
		var toward: Vector2 = target - position
		if absf(toward.x) >= tile_size * 0.5:
			_cast_facing = Vector2i(int(signf(toward.x)), 0)
		elif absf(toward.y) >= tile_size * 0.5:
			_cast_facing = Vector2i(0, int(signf(toward.y)))


## Le coup vient d'être encaissé, et l'invulnérabilité dure `seconds`.
func play_hurt(seconds: float) -> void:
	_hurt_total = maxf(0.01, seconds)
	_hurt_left = _hurt_total


## Réapparition après une translation : le mage revient en fondu plutôt qu'en
## surgissant. Court — 0,26 s — parce qu'un mage invisible pendant une poursuite
## est un mage qu'on ne peut pas piloter.
func walk_textures() -> Dictionary:
	return _textures


func walk_poses() -> Array[int]:
	return _walk_poses


func pose_count() -> int:
	return _poses.size()


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
	_motion = MotionProfile.from_data(data.get("motion"))
	_display_height = DEFAULT_TARGET_HEIGHT
	if data.has("body_height"):
		_display_height = BODY_SCREEN_HEIGHT * _cell.y / float(data["body_height"])
	# Le Geôlier n'a qu'une flamme sous la taille : à hauteur égale, son armure paraissait petite.
	_display_height *= float(data.get("body_scale", 1.0))
	target_height = _display_height
	_walk_poses.clear()
	_attack_poses.clear()
	for i in _poses.size():
		var pose := str(_poses[i])
		if pose.begins_with("walk"):
			_walk_poses.append(i)
		elif pose.begins_with("attack"):
			_attack_poses.append(i)

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
	_sprite_scale = Vector2(factor, factor)
	sprite.scale = _sprite_scale
	sprite.region_enabled = false
	sprite.vframes = 1
	sprite.hframes = maxi(1, _poses.size())
	sprite.flip_h = false
	# Les pieds tombent sur l'origine du nœud, là où le Level pose le mage et
	# où Actor dessine son ombre de contact.
	sprite.offset = Vector2(0.0, _cell.y * 0.5 - _feet_y)
	_apply_frame()


func _direction_key() -> String:
	var shown := _cast_facing if _attack_left > 0.0 and _cast_facing != Vector2i.ZERO else _facing
	if shown == Vector2i.UP:
		return "up"
	if shown == Vector2i.LEFT:
		return "left"
	if shown == Vector2i.RIGHT:
		return "right"
	return "down"


func _apply_frame() -> void:
	var texture: Texture2D = _textures.get(_direction_key())
	if texture == null:
		return
	if sprite.texture != texture:
		sprite.texture = texture
	var index := 0
	if _attack_left > 0.0 and not _attack_poses.is_empty():
		# Le geste se déroule UNE fois sur sa durée. Il faut garder l'image du tir
		# tôt dans la bande : le projectile part à la pression de la touche.
		var done := 1.0 - _attack_left / ATTACK_DURATION
		var step := int(done * float(_attack_poses.size()))
		if _motion != null:
			step = _motion.attack_pose(_attack_elapsed())
		index = _attack_poses[mini(step, _attack_poses.size() - 1)]
	elif mover != null and mover.is_moving() and not _walk_poses.is_empty():
		index = _walk_poses[int(_walk_phase) % _walk_poses.size()]
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
	elif _hurt_left > 0.0:
		_hurt_left = maxf(0.0, _hurt_left - delta)
		var elapsed := _hurt_total - _hurt_left
		if elapsed < HURT_FLASH:
			sprite.modulate = HURT_TINT
		else:
			var hidden := fmod(elapsed * HURT_BLINK_SPEED, 1.0) < 0.5
			sprite.modulate = Color(1, 1, 1, HURT_BLINK_ALPHA if hidden else 1.0)
	elif sprite.modulate != Color(1, 1, 1, 1):
		sprite.modulate = Color(1, 1, 1, 1)

	if mover.direction != Vector2i.ZERO:
		_facing = mover.direction
		_walk_phase += delta * _walk_cadence()
	else:
		# À l'arrêt, on revient à la pose de repos plutôt que de figer un pas en
		# l'air : un personnage immobile jambe levée se remarque immédiatement.
		_walk_phase = 0.0
	_apply_frame()
	_animate_body(delta)


## Poses par seconde : le même nombre de foulées, quel que soit le nombre de poses.
##
## ⚠️ Pas de `foot_travel` ici, contrairement à `Enemy` : sous une robe, la mesure
## voit l'ourlet et non le pied. Mesuré à 0,07 sur le Feu, elle l'aurait fait
## pédaler à trois cycles par seconde.
func _walk_cadence() -> float:
	return WALK_FPS * float(_walk_poses.size()) / 4.0 * mover.speed / WALK_REFERENCE_SPEED


## Ce que le dessin ne donne pas : le rebond des appuis, la respiration, l'élan du
## sort. Purement visuel, l'origine du nœud et donc les collisions n'en savent rien.
func _animate_body(delta: float) -> void:
	if _motion != null:
		_animate_motion(delta)
		return
	sprite.position.y = 0.0
	if mover.is_moving():
		sprite.scale = _sprite_scale
		# Deux appuis par cycle, donc deux rebonds.
		var cycle := _walk_phase / float(maxi(1, _walk_poses.size()))
		sprite.position.y = -absf(sin(cycle * TAU)) * WALK_BOB
	else:
		_breathe(delta)
	if _attack_left > 0.0:
		var punch: float = pow(_attack_left / ATTACK_DURATION, 3.0)
		sprite.scale = _sprite_scale * (Vector2.ONE + CAST_PUNCH * punch)
	if lift > 0.0:
		# En vol, il plane : un lent balancement, sans le rebond des appuis.
		_hover += delta
		sprite.position.y = -lift + sin(_hover * 4.2) * lift * 0.08
		sprite.scale = sprite.scale * lift_scale


func _attack_duration() -> float:
	return _motion.attack_duration() if _motion != null else ATTACK_DURATION


func _attack_elapsed() -> float:
	return _attack_duration() - _attack_left


## Vers où regarde le geste en cours.
func _strike_facing() -> Vector2i:
	return _cast_facing if _cast_facing != Vector2i.ZERO else _facing


## Ce que le gabarit ajoute à la planche. L'origine du sprite est sous les pieds : écraser
## et pencher ne les déplacent donc pas.
func _animate_motion(delta: float) -> void:
	var moving := mover.is_moving()
	var direction := mover.direction
	# LES À-COUPS naissent des changements de marche, et le ressort les fait déborder.
	if moving != _was_moving or (moving and direction != _last_direction and _was_moving):
		_jolt_speed += _motion.kick if moving else -_motion.kick
		_step_dust(1.0)
	_was_moving = moving
	_last_direction = direction

	var lean_goal := 0.0
	var body_y := 0.0
	var squash := 0.0
	if moving:
		var cycle := _walk_phase / float(maxi(1, _walk_poses.size()))
		var sideways := direction.x != 0
		body_y = -_motion.bob_at(cycle, sideways)
		squash = _motion.squash_at(cycle, sideways)
		# Un appui toutes les quatre images, là où le pied touche le sol.
		var step := int(_walk_phase) / maxi(1, _walk_poses.size() / 2)
		if step != _last_step:
			_last_step = step
			_step_dust(0.7)
		sprite.scale = _sprite_scale
	else:
		_last_step = -1
		_breathe(delta)

	var offset := Vector2(0.0, body_y)
	if _attack_left > 0.0:
		var elapsed := _attack_elapsed()
		if not _slashed and elapsed >= _motion.slash_time():
			_slashed = true
			_spawn_slash()
		if not _struck and elapsed >= _motion.impact_time():
			_struck = true
			_jolt_speed += _motion.kick * 1.4
		var strike := Vector2(_strike_facing())
		offset += strike * _motion.lunge_at(elapsed) * _motion.lunge * float(tile_size)
		lean_goal = strike.x * _motion.strike_lean * (1.0 if _struck else -1.0)
		if _struck and _hurt_left <= 0.0 and _warp_left <= 0.0 \
				and elapsed < _motion.impact_time() + 0.07:
			sprite.modulate = Color(1.35, 1.35, 1.35)

	# Deux ressorts amortis, qui franchissent leur cible avant de s'y poser.
	_lean_speed += (lean_goal - _lean) * 170.0 * delta - _lean_speed * 17.0 * delta
	_lean += _lean_speed * delta
	_jolt_speed += -_jolt * 240.0 * delta - _jolt_speed * 15.0 * delta
	_jolt += _jolt_speed * delta

	sprite.position = offset
	sprite.skew = _lean
	var press := squash + _jolt
	sprite.scale *= Vector2(1.0 + press, 1.0 - press)


func _spawn_slash() -> void:
	if _motion.slash_color.a <= 0.0:
		return
	var arc := SlashArc.new()
	add_child(arc)
	# À hauteur de poitrine, et assez large pour dépasser la silhouette.
	arc.position = Vector2(0.0, -BODY_SCREEN_HEIGHT * 0.5)
	arc.setup(_strike_facing(), BODY_SCREEN_HEIGHT * SLASH_RADIUS, _motion.slash_color)
	arc.z_index = 1


func _step_dust(strength: float) -> void:
	if not _motion.dust:
		return
	if _dust == null:
		_dust = FootDust.new()
		add_child(_dust)
	_dust.puff(global_position, -Vector2(_facing), float(tile_size) * 0.2 * strength)


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
