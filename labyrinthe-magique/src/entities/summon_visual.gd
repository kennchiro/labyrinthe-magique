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
const HEIGHTS := {"imp": 44.0, "gargouille": 52.0, "dragon": 88.0, "ombre": 93.0}
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

var kind_id := "imp"
var tile_size := 32

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


func setup(p_kind: String, p_tile_size: int) -> void:
	kind_id = p_kind
	tile_size = p_tile_size
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
	var read_id := kind_id
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
	if facing != Vector2i.ZERO:
		_facing = facing
	_apply_frame()


func flash_strike() -> void:
	_strike_left = STRIKE_FLASH
	_apply_frame()


func _process(delta: float) -> void:
	_time += delta
	_strike_left = maxf(0.0, _strike_left - delta)
	_bob += delta * BOB_SPEED
	if _sprite == null:
		return
	_sprite.position.y = -sin(_bob) * BOB_HEIGHT
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
		var step := int((STRIKE_FLASH - _strike_left) * IDLE_FPS)
		_sprite.frame = idle + mini(strike - 1, step)
	else:
		_sprite.frame = int(_time * IDLE_FPS) % idle
	_sprite.flip_h = _mirror_left and wanted == "left" and not _bands.has("left")

	var factor: float = HEIGHTS.get(kind_id, 44.0) / _cell.y
	_sprite.scale = Vector2(factor, factor)
	# L'origine du nœud est l'OMBRE AU SOL, et c'est le BAS DE LA CASE qui s'y
	# pose. Les marcheurs y ont leurs pieds — la case les y cale au découpage ;
	# le dragon, centré dans la sienne, plane au-dessus grâce à la marge basse.
	_sprite.offset = Vector2(0.0, -_cell.y * 0.5)


func _draw() -> void:
	# Ombre de contact, comme les acteurs : sans elle, une créature volante ne
	# se situe plus — on ne sait pas au-dessus de QUELLE case elle est.
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, tile_size * (0.34 if kind_id == "dragon" else 0.24),
		Color(0.0, 0.0, 0.0, 0.32))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
