class_name MagicOrb
extends Node2D

## Le projectile du sort : une bille de lumière bleue qui remonte les couloirs
## jusqu'à sa cible.
##
## Il ne DÉCIDE de rien. Le SpellSystem a déjà fixé la cible et l'instant de
## l'impact ; l'orbe ne fait que rendre visible ce trajet, à la seconde près.
## Séparer les deux permet à la simulation d'équilibrage de jouer des parties
## entières sans jamais instancier un seul de ces nœuds.

const TEXTURE := preload("res://assets/sprites/magic_orb.png")
## Teinte par défaut ; l'élément de la compétence la remplace au lancement.
const TINT := Color("#7fd8ff")
## Longueur de la traînée, en points de trajectoire mémorisés.
const TRAIL_LENGTH := 9

@onready var sprite: Sprite2D = $Sprite2D

var tile_size: int = 32

var _points: PackedVector2Array = PackedVector2Array()
var _duration := 0.4
var _elapsed := 0.0
var _trail: Array[Vector2] = []


var tint: Color = TINT
var _drawn := false
var _frames := 1
## La bande va de la naissance du tir à sa pleine puissance : on la joue UNE
## fois et on tient la dernière image, au lieu de la répéter.
var _grows := false
var _plume: CPUParticles2D = null
## Cadence du flip-book, en images par seconde.
var _fps := 12.0
## Nombre de frames de CHARGEMENT au point de départ. Au-delà, la bande passe à
## sa dernière image — le projectile — et c'est elle seule qui voyage.
var _charge_frames := 0
## Part maximale du vol que la charge a le droit de prendre.
##
## La durée totale est fixée par le CombatSystem : elle décide de l'instant de
## l'impact, et on n'y touche pas. Une charge de 7 images à 8 img/s dure 0,875 s,
## ce qui dépasse le vol entier quand la cible est à deux cases. Sans ce
## plafond, le projectile partait après avoir déjà touché.
const CHARGE_SHARE := 0.45
## Temps que met une bande de PROGRESSION à se dérouler entièrement, en
## secondes. Court : le tir doit atteindre sa pleine puissance bien avant de
## toucher, sinon on ne voit jamais que sa naissance.
const GROW_TIME := 0.22

## LES PROJECTILES PEINTS AU SHADER, par valeur d'`Ability.projectile_visual`.
##
## Ils ne lisent aucune planche : deux tirs ne sont jamais identiques, et le dessin
## vit pendant tout le vol. `lead` recule le quad pour que la POINTE du dessin, et
## non son milieu, tombe sur la position du projectile. Les tailles sont en cases,
## avant l'échelle de la compétence.
## Le Suprême lit une matière par canal (`tools/build_noise.py`).
const SUPREME_NOISE := preload("res://assets/shaders/supreme_noise.png")
const PAINTED := {
	"trait_peint": {"shader": preload("res://assets/shaders/fire_bolt.gdshader"),
		"length": 1.6, "height": 0.45, "lead": 0.3, "sparks": 0.4},
	"boule_peinte": {"shader": preload("res://assets/shaders/fire_ball.gdshader"),
		"length": 1.5, "height": 0.94, "lead": 0.22, "sparks": 0.0},
	"orbe_ombre": {"shader": preload("res://assets/shaders/shadow_orb.gdshader"),
		"length": 1.7, "height": 1.3, "lead": 0.16, "sparks": 0.0},
	"aiguille_occulte": {"shader": preload("res://assets/shaders/arcane_needle.gdshader"),
		"length": 1.9, "height": 0.3, "lead": 0.3, "sparks": 0.0},
	"jet_eau": {"shader": preload("res://assets/shaders/water_jet.gdshader"),
		"length": 1.9, "height": 0.5, "lead": 0.3, "sparks": 0.0},
	"dard_foudre": {"shader": preload("res://assets/shaders/thunder_dart.gdshader"),
		"length": 2.0, "height": 0.62, "lead": 0.42, "sparks": 0.0},
	"trait_aube": {"shader": preload("res://assets/shaders/lumiere_bolt.gdshader"),
		"length": 1.6, "height": 0.42, "lead": 0.3, "sparks": 0.0},
	"eclat_stellaire": {"shader": preload("res://assets/shaders/etoiles_spark.gdshader"),
		"length": 1.3, "height": 0.54, "lead": 0.3, "sparks": 0.0},
	"croissant_noir": {"shader": preload("res://assets/shaders/mort_crescent.gdshader"),
		"length": 1.5, "height": 0.8, "lead": 0.3, "sparks": 0.0},
	"griffe_sang": {"shader": preload("res://assets/shaders/demon_griffe.gdshader"),
		"length": 1.45, "height": 0.82, "lead": 0.3, "sparks": 0.0},
	"onde_marteau": {"shader": preload("res://assets/shaders/acier_wave.gdshader"),
		"length": 1.7, "height": 1.05, "lead": 0.32, "sparks": 0.5},
	"goutte_venin": {"shader": preload("res://assets/shaders/peste_dart.gdshader"),
		"length": 1.5, "height": 0.46, "lead": 0.3, "sparks": 0.0},
	"aiguille_temps": {"shader": preload("res://assets/shaders/chrono_needle.gdshader"),
		"length": 1.7, "height": 0.4, "lead": 0.3, "sparks": 0.0},
	"trait_prisme": {"shader": preload("res://assets/shaders/prism_bolt.gdshader"), "noise": SUPREME_NOISE,
		"length": 2.2, "height": 0.66, "lead": 0.3, "sparks": 0.3},
	"convergence_peinte": {"shader": preload("res://assets/shaders/convergence.gdshader"), "noise": SUPREME_NOISE,
		"length": 1.45, "height": 1.45, "lead": 0.0, "sparks": 0.5},
	"goutte": {"shader": preload("res://assets/shaders/water_drop_fx.gdshader"),
		"length": 1.0, "height": 0.56, "lead": 0.18, "sparks": 0.0},
	"meteore_jugement": {"shader": preload("res://assets/shaders/judgement_meteor.gdshader"), "noise": SUPREME_NOISE,
		"length": 2.6, "height": 1.0, "lead": 0.28, "sparks": 0.0},
}
const PAINTED_NOISE := preload("res://assets/shaders/fire_noise.png")
## Le trait naît petit et atteint sa taille en un éclair, comme la bande qu'il remplace.
const PAINTED_BIRTH := 0.12
const PAINTED_BIRTH_SCALE := 0.35

## Taille pleine du quad peint, ou zéro pour un projectile dessiné.
var _painted_size := Vector2.ZERO
var _embers: CPUParticles2D = null


## Le pixel blanc qui porte un shader peint : c'est le matériau qui dessine tout.
static func painted_quad() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)


static func painted_material(visual: String, seed_value: float) -> ShaderMaterial:
	var shaded := ShaderMaterial.new()
	shaded.shader = PAINTED[visual]["shader"]
	shaded.set_shader_parameter("noise", PAINTED[visual].get("noise", PAINTED_NOISE))
	shaded.set_shader_parameter("seed", seed_value)
	return shaded


## Remplace le dessin du projectile par son shader. À appeler après `setup`.
func paint(visual: String, p_scale: float) -> void:
	if not PAINTED.has(visual):
		return
	var look: Dictionary = PAINTED[visual]
	_drawn = true
	_frames = 1
	sprite.hframes = 1
	sprite.frame = 0
	sprite.modulate = Color.WHITE
	sprite.texture = painted_quad()
	sprite.offset = Vector2(-float(look["lead"]), 0.0)
	sprite.material = painted_material(visual, float(Time.get_ticks_usec() % 1000) * 0.001)
	_painted_size = Vector2(float(look["length"]), float(look["height"])) \
		* float(tile_size) * maxf(0.2, p_scale)
	sprite.scale = _painted_size * PAINTED_BIRTH_SCALE
	# La traînée est dans le dessin : le panache de blobs additifs le délaverait.
	if _plume != null:
		_plume.queue_free()
		_plume = null
	if float(look["sparks"]) > 0.0:
		_build_trail(float(look["sparks"]), p_scale)
	_round_embers()


## Sans texture, une particule est un CARRÉ : invisible sur un petit trait, mais la
## boule en sème d'assez gros pour couvrir sa propre flamme. Rondes, plus fines et
## DERRIÈRE le dessin, ce sont des braises qui s'échappent.
func _round_embers() -> void:
	if _embers == null:
		return
	var blob := FxTextures.soft_blob()
	var unit := float(tile_size) / float(blob.get_width())
	_embers.texture = blob
	_embers.scale_amount_min = unit * 0.14
	_embers.scale_amount_max = unit * 0.3
	_embers.spread = 180.0
	move_child(_embers, 0)


## `p_texture` : le projectile DESSINÉ du mage, découpé de sa planche. Sans lui
## (repli), la bille générique — mais teintée seulement dans ce cas : le trait
## de flamme du Mage du Feu porte déjà ses couleurs, le reteindre le salirait.
## `p_frames` > 1 : la bande est un FLIP-BOOK — les quatre comètes du Feu se
## relaient en vol, et le trait vit au lieu de glisser figé.
## `p_scale` et `p_trail` viennent de la COMPÉTENCE : c'est ce qui fait qu'une
## boule de feu ne ressemble pas à une flèche de feu.
##
## La traînée est en CPUParticles2D et non en GPUParticles2D : le jeu tourne en
## `gl_compatibility` pour couvrir iOS, Android et le Web avec un seul code, et
## les particules CPU s'y comportent à l'identique partout. Pour une poignée
## d'émetteurs, le coût est nul et le risque de rendu divergent disparaît.
func setup(points: PackedVector2Array, duration: float, p_tile_size: int,
		p_tint: Color = TINT, p_texture: Texture2D = null, p_frames: int = 1,
		p_scale: float = 1.0, p_trail: float = 0.0, p_flames: float = 0.0,
		p_grows: bool = false, p_fps: float = 12.0, p_charge_frames: int = 0) -> void:
	_grows = p_grows
	_fps = p_fps
	_charge_frames = p_charge_frames
	tile_size = p_tile_size
	tint = p_tint
	_drawn = p_texture != null
	_frames = maxi(1, p_frames)
	sprite.modulate = Color(1, 1, 1) if _drawn else tint
	_points = points
	_duration = maxf(0.05, duration)
	var texture := p_texture if _drawn else TEXTURE
	sprite.texture = texture
	sprite.hframes = _frames
	var cell_width := float(texture.get_width()) / float(_frames)
	var extent := maxf(cell_width, float(texture.get_height()))
	var factor := (tile_size * 0.95 * maxf(0.2, p_scale)) / extent
	sprite.scale = Vector2(factor, factor)
	if p_trail > 0.0:
		_build_trail(p_trail, p_scale)
	if p_flames > 0.0:
		_build_plume(p_flames, p_scale)

	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	sprite.material = material
	self.material = material
	if _points.size() > 0:
		position = _points[0]
		# Orientation initiale basée sur le premier segment de vol.
		if _points.size() >= 2:
			sprite.rotation = (_points[1] - _points[0]).angle()


## Le PANACHE : un cône de flammes derrière la boule, qui pointe toujours à
## l'opposé du vol — la forme triangulaire d'une comète.
##
## Le cône est obtenu par la DISPERSION et non par une forme d'émission : les
## particules partent vers l'arrière dans un angle de 24°, s'écartent en
## vieillissant, et dessinent d'elles-mêmes le triangle. Une forme d'émission
## triangulaire aurait donné un triangle figé, qui tourne comme un panneau ;
## celui-ci se déforme avec la trajectoire, comme du feu.
func _build_plume(density: float, scale_hint: float) -> void:
	# Peu de flammes, et PÂLES. En blending additif, une trentaine de blobs qui
	# se chevauchent saturent en blanc pur : le panache devenait une boule de
	# lumière sans forme, et la boule de feu disparaissait dedans. C'est la
	# rareté qui laisse voir le triangle.
	_plume = FxTextures.flame_emitter(int(30.0 * density), 0.5,
		tile_size * 0.42 * scale_hint,
		Color(1.0, 0.78, 0.34, 0.55), Color(0.92, 0.22, 0.03, 0.0), 0.0, 21.0)
	add_child(_plume)
	# Les flammes RESTENT où elles sont nées : sans ça le panache colle à la
	# boule et se lit comme une aura, pas comme une traînée qu'on laisse.
	_plume.local_coords = false
	# Vitesses très ÉTALÉES : les rapides fuient loin derrière, les lentes
	# restent près de la boule. C'est cet écart qui creuse le triangle — à
	# vitesse égale, toutes les flammes resteraient sur un même arc.
	_plume.initial_velocity_min = tile_size * 0.15
	_plume.initial_velocity_max = tile_size * 2.2
	_plume.emitting = true


## Braises semées derrière le projectile. Elles TOMBENT légèrement et
## s'éteignent : une traînée qui suit exactement la trajectoire ressemble à un
## trait de crayon, une traînée qui se disperse ressemble à du feu.
func _build_trail(density: float, scale_hint: float) -> void:
	var embers := CPUParticles2D.new()
	_embers = embers
	add_child(embers)
	embers.amount = clampi(int(28.0 * density), 6, 64)
	embers.lifetime = 0.55
	embers.local_coords = false          # les braises RESTENT où elles sont nées
	embers.spread = 32.0
	embers.gravity = Vector2(0.0, 34.0)
	embers.initial_velocity_min = 6.0
	embers.initial_velocity_max = 26.0
	embers.scale_amount_min = tile_size * 0.05 * scale_hint
	embers.scale_amount_max = tile_size * 0.13 * scale_hint
	embers.color = Color(tint.r, tint.g, tint.b, 0.85)
	# `color_ramp` attend un Gradient, pas une GradientTexture1D — la braise
	# passe du blanc chaud à la couleur de l'élément, puis s'éteint.
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.95, 0.7, 0.9))
	ramp.set_color(1, Color(tint.r, tint.g * 0.5, tint.b * 0.2, 0.0))
	embers.color_ramp = ramp
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	embers.material = material
	embers.emitting = true


## La cible bouge pendant le vol : le dernier point du trajet la suit, sinon
## l'orbe irait exploser là où l'ennemi se trouvait à l'instant du tir.
func retarget(world_position: Vector2) -> void:
	if _points.size() >= 2:
		_points[_points.size() - 1] = world_position


func _process(delta: float) -> void:
	_elapsed += delta
	if _points.size() < 2:
		queue_free()
		return
	if _painted_size != Vector2.ZERO:
		var born := minf(1.0, _elapsed / PAINTED_BIRTH)
		sprite.scale = _painted_size * lerpf(PAINTED_BIRTH_SCALE, 1.0, born)

	# DEUX TEMPS : on charge sur place, puis on part. Le vol se déroule sur ce
	# qui RESTE de la durée, jamais sur la durée entière — sinon le projectile
	# arrive une charge trop tard, c'est-à-dire après son propre impact.
	var charge_time := minf(float(_charge_frames) / _fps, _duration * CHARGE_SHARE)
	if _charge_frames > 0 and _elapsed < charge_time:
		position = _points[0]
	else:
		var flight := maxf(0.05, _duration - charge_time)
		var t := clampf((_elapsed - charge_time) / flight, 0.0, 1.0)
		position = _sample(t)

	# Pendant la charge l'orbe ne bouge pas : mémoriser sa position remplirait la
	# traînée de points identiques, et le panache s'allumerait sur place comme
	# une flaque. On n'enregistre donc la trace qu'une fois parti.
	if _charge_frames == 0 or _elapsed >= charge_time:
		_trail.push_front(position)
		while _trail.size() > TRAIL_LENGTH:
			_trail.pop_back()

	# Un dessin s'ORIENTE le long du vol — une comète qui tournoie sur
	# elle-même se lit comme un débris, pas comme un tir. La bille générique,
	# ronde, garde sa rotation d'origine : sur elle c'est un scintillement.
	if _drawn and _trail.size() >= 2 and _trail[0] != _trail[1]:
		sprite.rotation = (_trail[0] - _trail[1]).angle()
	elif not _drawn:
		sprite.rotation += delta * 6.0
		
	if _frames > 1:
		if _charge_frames > 0:
			# La charge se joue sur son propre temps — écrasé quand la cible est
			# proche — puis on TIENT la frame du projectile jusqu'à l'impact.
			# La rejouer en boucle ferait clignoter la comète en plein vol.
			if _elapsed < charge_time:
				# La cadence est FIXE — huit images par seconde, la même à toute
				# distance. Étirer la charge sur le temps disponible a été
				# essayé : à deux cases de la cible elle se jouait à 27 img/s,
				# et les quatre éléments qui s'assemblent devenaient un
				# clignotement. On préfère jouer MOINS d'images que de les jouer
				# plus vite : le sort a simplement moins de temps pour se charger.
				sprite.frame = mini(int(_elapsed * _fps), _charge_frames - 1)
			else:
				sprite.frame = mini(_charge_frames, _frames - 1)
		elif _grows:
			# Une seule passe, puis la dernière image tient jusqu'à l'impact.
			sprite.frame = mini(int((_elapsed / GROW_TIME) * float(_frames)),
				_frames - 1)
		else:
			sprite.frame = int(_elapsed * _fps) % _frames
			
	# Le panache pointe à l'OPPOSÉ du vol, remis à jour à chaque image : c'est
	# ce qui le fait pivoter dans les virages du labyrinthe au lieu de traîner
	# derrière comme une écharpe raide.
	if _plume != null and _trail.size() >= 2 and _trail[0] != _trail[1]:
		_plume.direction = (_trail[1] - _trail[0]).normalized()
	queue_redraw()


## Point à l'avancement `t` le long de la polyligne, à vitesse constante.
func _sample(t: float) -> Vector2:
	var segments := _points.size() - 1
	var scaled := t * float(segments)
	var index := mini(int(scaled), segments - 1)
	return _points[index].lerp(_points[index + 1], scaled - float(index))


## Impact : l'orbe s'efface, l'éclat est joué par le Level (même effet que les
## téléportations, pour que le jeu n'ait qu'un seul vocabulaire visuel).
func burst() -> void:
	queue_free()


func _draw() -> void:
	if _painted_size != Vector2.ZERO:
		return
	for i in _trail.size():
		var fade := 1.0 - float(i) / float(TRAIL_LENGTH)
		draw_circle(to_local(_trail[i]), tile_size * 0.16 * fade,
			Color(tint.r, tint.g, tint.b, 0.28 * fade))
