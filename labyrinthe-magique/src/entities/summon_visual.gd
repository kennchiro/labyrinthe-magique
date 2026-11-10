class_name SummonVisual
extends Node2D

## Le corps visible d'une invocation. Toute la CHASSE — cible, chemin, coups —
## vit dans le CombatSystem ; ce nœud ne fait qu'afficher ce qu'on lui dit.
##
## Il lit `assets/allies/allies.json`, écrit par `tools/build_invocateur.py`, et
## ne code AUCUN nombre de poses ni nom de fichier en dur — même règle que
## `Player` et `Enemy` avec leur `frames.json`.
##
## Une BANDE par créature et par direction (`hframes`), poses d'inaction
## d'abord, poses de coup ensuite. Le descripteur dit combien de chaque :
##
##   imp        4 poses d'inaction (un battement d'ailes) + 1 de morsure
##   gargouille 2 + 1 (le souffle)
##   dragon     1 + 1, mais dans les QUATRE directions
##
## Deux créatures sur trois n'ont qu'une vue de face : leur profil gauche est un
## miroir (`mirror_left`), et le haut comme la droite retombent dessus. Le
## dragon, lui, a ses quatre vues dessinées — on ne le retourne jamais.
##
## Le balancement de vol stationnaire reste procédural par-dessus : il tient le
## rôle qu'il tenait quand ces créatures n'avaient qu'une pose, et il DÉCALE les
## invocations entre elles pour que deux imps posés ensemble ne flottent pas à
## l'unisson.

const HURT_TINT := Color(2.2, 0.55, 0.5)
const HURT_TIME := 0.25
## La barre de vie : VERTE, là où celle des ennemis est rouge, pour qu'on sache d'un coup
## d'œil laquelle est à soi. En fraction de case, comme celle d'`Enemy`.
const BAR_WIDTH := 0.9
const BAR_HEIGHT := 0.11
const BAR_FILL := Color("#5ee07a")
const BAR_LOW := Color("#ffd15a")
const BAR_EMPTY := Color(0.08, 0.22, 0.12, 0.95)
const ALLIES_PATH := "res://assets/allies/"
const CATALOGUE_PATH := ALLIES_PATH + "allies.json"
## Hauteur de CASE à l'écran, en pixels. C'est la case et non le dessin qui est
## mise à l'échelle : les poses d'une même créature n'ont pas toutes la même
## taille (l'aile ouverte, le souffle, le dragon qui pique ailes rabattues) et
## c'est justement ce rapport-là qu'il faut garder.
## ⚠️ C'EST LA CASE QUI EST MISE À L'ÉCHELLE, PAS LE DESSIN — et une case n'est
## pas remplie de la même façon d'une créature à l'autre. La gargouille occupe
## 88 % de la sienne, l'ombre 67 % : sa case doit tenir le jet de gaz, qui
## descend cinquante pixels plus bas que sa fumée au repos. À hauteur de case
## égale, elle paraissait donc plus PETITE que la gargouille alors qu'elle est
## réglée plus haut. Ces nombres sont des hauteurs de CASE, pas de créature.
const HEIGHTS := {"imp": 46.0, "gargouille": 52.0, "dragon": 149.0, "ombre": 93.0,
	# Le dragon embrasé du Maître des Légions remplit mieux sa case : à 124, son corps a la taille de
	# l'autre (mesuré : 156 px contre 167 dans leurs bandes).
	"dragon_eveil": 124.0}
## Une créature de la Légion (l'Éveil de l'Invocateur) est plus grande d'autant.
const LEGION_SIZE := 1.3
## La Gargouille colossale tombe du ciel : hauteur de départ en cases, et durée de la chute.
const DROP_HEIGHT := 6.0
const DROP_TIME := 0.35
## Créature dont on emprunte les bandes tant que la planche d'une nouvelle n'est
## pas découpée, avec sa teinte de remplacement.
##
## Un `push_error` et un sprite absent seraient pire qu'un pis-aller : la
## mécanique se teste et se règle avant que le dessin n'existe, et une invocation
## invisible se lit comme un sort cassé. On emprunte donc, et on TEINTE — assez
## sombre pour qu'aucune capture ne soit prise pour l'apparence définitive.
## Vide tant qu'aucune planche ne manque, et c'est l'état normal : une entrée
## qui traîne masquerait un découpage cassé derrière un pis-aller convaincant.
const STAND_INS := {}
## Cadence du battement d'ailes, en images par seconde.
const IDLE_FPS := 7.0
## Vitesse du balancement de vol stationnaire.
const BOB_SPEED := 6.0
const BOB_HEIGHT := 2.4
## Durée d'affichage de la pose de coup.
const STRIKE_FLASH := 0.45
## Délai sans déplacement au bout duquel une bête au sol s'arrête de marcher.
const WALK_HOLD := 0.15

var kind_id := "imp"
var tile_size := 32
## L'apparence lue dans allies.json, quand ce n'est pas celle de la créature (le dragon embrasé).
var look := ""
## Taille propre à la créature (la Gargouille colossale), et celle que la Légion y ajoute.
var size_factor := 1.0
var _legion_size := 1.0
var _legion_aura: PaintedBurst = null
var _drop_left := 0.0

var _sprite: Sprite2D = null
## direction -> {"texture", "idle", "strike"} — la bande et ses deux comptes.
var _bands := {}
var _cell := Vector2(1, 1)
var _mirror_left := false
var _facing: Vector2i = Vector2i.DOWN
var _strike_left := 0.0
var _bob := 0.0
var _time := 0.0
## Le nuage de gaz de la créature, s'il y en a un dans son descripteur.
var _gas: Texture2D = null
var _gas_frames := 0
## Une bête AU SOL ne flotte pas : elle ne joue ses pas qu'en se déplaçant.
var _grounded := false
var _idle_fps := IDLE_FPS
var _walk_left := 0.0
## Ce qu'il lui reste, de 0 à 1. Pleine, la barre ne s'affiche pas : au complet elle n'apprend rien.
var _health := 1.0


func setup(p_kind: String, p_tile_size: int, p_look: String = "") -> void:
	kind_id = p_kind
	tile_size = p_tile_size
	look = p_look
	_sprite = Sprite2D.new()
	add_child(_sprite)
	_load_bands()
	_apply_frame()
	# Décalage aléatoire du balancement : deux imps invoqués ensemble ne doivent
	# pas flotter à l'unisson comme des copies.
	_bob = randf() * TAU
	_time = randf() * 10.0


func _load_bands() -> void:
	var text := FileAccess.get_file_as_string(CATALOGUE_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("Descripteur des invocations introuvable (%s)" % CATALOGUE_PATH)
		return
	var catalogue: Dictionary = parsed
	var read_id := look if look != "" and catalogue.has(look) else kind_id
	if not catalogue.has(read_id) and STAND_INS.has(read_id):
		var stand_in: Dictionary = STAND_INS[read_id]
		read_id = str(stand_in["borrow"])
		_sprite.modulate = stand_in["tint"] as Color
		push_warning("« %s » n'a pas encore de planche : bandes de « %s » empruntées."
			% [kind_id, read_id])
	if not catalogue.has(read_id):
		push_error("Invocation inconnue dans allies.json : « %s »" % kind_id)
		return
	var entry: Dictionary = catalogue[read_id]
	_mirror_left = bool(entry.get("mirror_left", false))
	_grounded = bool(entry.get("grounded", false))
	_idle_fps = float(entry.get("walk_fps", entry.get("idle_fps", IDLE_FPS)))
	var cell: Array = entry["cell"]
	_cell = Vector2(float(cell[0]), float(cell[1]))
	if entry.has("gas"):
		var gas: Dictionary = entry["gas"]
		_gas = load(ALLIES_PATH + str(gas["file"]))
		_gas_frames = maxi(1, int(gas.get("frames", 1)))
	for direction in (entry["directions"] as Dictionary):
		var band: Dictionary = entry["directions"][direction]
		var texture: Texture2D = load(ALLIES_PATH + str(band["file"]))
		if texture == null:
			continue
		_bands[str(direction)] = {
			"texture": texture,
			"idle": maxi(1, int(band.get("idle", 1))),
			"strike": maxi(0, int(band.get("strike", 0))),
		}


## LE SOUFFLE DE LA CRÉATURE, quand sa planche en fournit un.
##
## Rendu ici plutôt que chargé par le Level : c'est une pièce de la planche de
## l'invocation, elle est décrite dans le même descripteur, et le Level n'a pas
## à savoir quel fichier appartient à quelle créature.
func gas_texture() -> Texture2D:
	return _gas


func gas_frames() -> int:
	return _gas_frames


func set_facing(facing: Vector2i) -> void:
	_walk_left = WALK_HOLD
	if facing != Vector2i.ZERO:
		_facing = facing
	_apply_frame()


## LA LÉGION : la créature grandit, et un sceau tourne sous ses pieds tant qu'elle en est.
func set_legion(on: bool, seconds: float = 60.0) -> void:
	var tween := create_tween()
	tween.tween_property(self, "_legion_size", LEGION_SIZE if on else 1.0, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _legion_aura != null and is_instance_valid(_legion_aura):
		_legion_aura.queue_free()
	_legion_aura = null
	if on:
		_legion_aura = PaintedBurst.new()
		add_child(_legion_aura)
		_legion_aura.setup(tile_size, 0.62 * size_factor, seconds, randf(), "legion_aura")
		_legion_aura.z_index = -1
		_legion_aura.show_behind_parent = true


## La Gargouille colossale tombe du ciel au lieu de naître au sol.
func drop_in() -> void:
	_drop_left = DROP_TIME


## Frappée par un ennemi : elle rougit un instant, comme le mage touché, et sa barre baisse.
func flash_hurt(health_ratio: float = 1.0) -> void:
	_health = clampf(health_ratio, 0.0, 1.0)
	queue_redraw()
	modulate = HURT_TINT
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, HURT_TIME)


func flash_strike() -> void:
	_strike_left = STRIKE_FLASH
	_apply_frame()


func _process(delta: float) -> void:
	_time += delta
	_strike_left = maxf(0.0, _strike_left - delta)
	_bob += delta * BOB_SPEED
	_walk_left = maxf(0.0, _walk_left - delta)
	_drop_left = maxf(0.0, _drop_left - delta)
	if kind_id == "dragon":
		queue_redraw()
	if _sprite == null:
		return
	_sprite.position.y = 0.0 if _grounded else -sin(_bob) * BOB_HEIGHT
	if _drop_left > 0.0:
		var k := _drop_left / DROP_TIME
		_sprite.position.y -= DROP_HEIGHT * float(tile_size) * k * k
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
	if _sprite == null or _bands.is_empty():
		return
	var wanted := _direction_key()
	# Direction non dessinée : on retombe sur la vue de face, retournée pour la
	# gauche quand la créature s'y prête. Le dragon a ses quatre vues, il ne
	# passe jamais par ici.
	var key := wanted if _bands.has(wanted) else "down"
	var band: Dictionary = _bands[key]
	var texture: Texture2D = band["texture"]
	var idle: int = band["idle"]
	var strike: int = band["strike"]
	var total := idle + strike
	if _sprite.texture != texture:
		_sprite.texture = texture
	_sprite.hframes = maxi(1, total)
	_sprite.vframes = 1
	if _strike_left > 0.0 and strike > 0:
		# La pose de coup s'égrène elle aussi quand il y en a plusieurs, mais
		# sans boucler : on la joue une fois et on tient la dernière.
		var step := int((STRIKE_FLASH - _strike_left) / STRIKE_FLASH * float(strike))
		_sprite.frame = idle + mini(strike - 1, step)
	else:
		var walking := not _grounded or _walk_left > 0.0
		_sprite.frame = int(_time * _idle_fps) % idle if walking else 0
	_sprite.flip_h = _mirror_left and wanted == "left" and not _bands.has("left")

	var height: float = HEIGHTS.get(look, HEIGHTS.get(kind_id, 44.0))
	var factor: float = height / _cell.y * size_factor * _legion_size
	_sprite.scale = Vector2(factor, factor)
	# Le dragon est centre dans sa case par le decoupage : son noeud peut donc
	# rester sur le centre de la case, sans appliquer le decalage reserve aux
	# creature ancrees par les pieds.
	_sprite.offset = Vector2.ZERO if kind_id == "dragon" else Vector2(0.0, -_cell.y * 0.5)


func _draw() -> void:
	if kind_id == "dragon":
		_draw_flight_effect()
	# Ombre de contact, comme les acteurs : sans elle, une créature volante ne
	# se situe plus — on ne sait pas au-dessus de QUELLE case elle est.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, tile_size * (0.34 if kind_id == "dragon" else 0.24) * size_factor * _legion_size,
		Color(0.0, 0.0, 0.0, 0.32))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_health()


func _draw_health() -> void:
	if _health >= 1.0:
		return
	var height: float = HEIGHTS.get(look, HEIGHTS.get(kind_id, 44.0))
	# Au-dessus de la tête : la case de l'Ombre est plus haute que son corps (son jet de gaz).
	var top := minf(height * size_factor * _legion_size, tile_size * 2.2) * 0.82
	var width := tile_size * BAR_WIDTH
	var bar := Rect2(Vector2(-width * 0.5, -top - tile_size * BAR_HEIGHT),
		Vector2(width, tile_size * BAR_HEIGHT))
	draw_rect(bar.grow(1.0), Color(0.02, 0.05, 0.03, 0.85))
	draw_rect(bar, BAR_EMPTY)
	draw_rect(Rect2(bar.position, Vector2(width * _health, bar.size.y)),
		BAR_FILL.lerp(BAR_LOW, clampf(1.0 - _health * 2.0, 0.0, 1.0)))
	draw_rect(bar, Color(0.85, 1.0, 0.9, 0.35), false, 1.0)


func _draw_flight_effect() -> void:
	# Trainees d'air derriere le dragon : l'effet indique la direction du vol
	# sans ajouter de feu au sprite, reserve a son projectile d'attaque.
	var direction := Vector2(_facing)
	if direction == Vector2.ZERO:
		direction = Vector2.DOWN
	var behind := -direction.normalized()
	var side := Vector2(-behind.y, behind.x)
	var pulse := 0.5 + 0.5 * sin(_bob)
	# Le dragon est centre dans sa grande case puis decale au-dessus de son ombre.
	# Les trainee doivent suivre son corps, pas rester au niveau du sol.
	var centre := Vector2(0.0, -_cell.y * 0.5 * HEIGHTS["dragon"] / _cell.y)
	# Le dragon embrasé laisse des braises, pas de l'air.
	var burning := look == "dragon_eveil"
	var tint := Color(1.0, 0.55, 0.15, 0.45) if burning else Color(0.48, 0.78, 1.0, 0.30)
	for i in 3:
		var distance := tile_size * (0.48 + float(i) * 0.30 + pulse * 0.10)
		var width := tile_size * (0.25 + float(i) * 0.08)
		var at := centre + behind * distance
		draw_arc(at, width, side.angle() - 0.75, side.angle() + 0.75,
			12, Color(tint.r, tint.g, tint.b, tint.a * (1.0 - float(i) * 0.22)),
			2.0)
	for i in 4:
		var phase := _time * 2.8 + float(i) * 1.7
		var distance := tile_size * (0.35 + fmod(phase, 1.25))
		var lateral := sin(phase) * tile_size * 0.34
		var at := centre + behind * distance + side * lateral
		var radius := tile_size * (0.035 + 0.018 * pulse)
		draw_circle(at, radius * (1.6 if burning else 1.0),
			Color(1.0, 0.8, 0.3, 0.6) if burning else Color(0.70, 0.90, 1.0, 0.32))
