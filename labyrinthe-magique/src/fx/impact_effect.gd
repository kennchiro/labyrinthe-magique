class_name ImpactEffect
extends Node2D

## L'éclat d'un sort qui touche. Un par élément, et ils ne se ressemblent pas.
##
## Depuis les planches d'effets, l'impact a une PIÈCE MAÎTRESSE dessinée — le
## vortex de flammes, la frappe de foudre, la galaxie du Suprême — qui grossit
## et s'éteint au centre. Les particules procédurales restent l'habillage :
## elles portent le rayon et le mouvement, le dessin porte l'identité.
##
## Le reste est DESSINÉ, pas texturé. Trois raisons :
##   - le jeu n'a aucune planche d'effets, et en générer cinq séries de PNG pour
##     des formes aussi simples qu'un éclat ou une goutte serait du gaspillage ;
##   - la couleur, la taille et le nombre de particules viennent de la
##     compétence : un sort de rayon 6 doit produire un éclat six fois plus large
##     que le tir de base, ce qu'une texture fixe ne sait pas faire ;
##   - un tracé se teinte exactement, là où une texture teintée par multiplication
##     vire au sale dès que la couleur source n'est pas neutre.
##
## Le semis est DÉTERMINISTE (graine dérivée de la case touchée) : deux fois le
## même sort au même endroit donne le même éclat. Sans ça, comparer deux captures
## d'écran serait impossible.

const DURATION := 0.55
## Envergure MAXIMALE du dessin d'impact, en cases.
##
## Il était mis à l'échelle du rayon du sort, sans plafond : l'ultime du Mage du
## Feu (rayon 5,5) affichait un vortex de huit cases de large, parfaitement
## opaque, qui effaçait le mage et le labyrinthe sous un disque orange. Un gros
## sort doit avoir un gros ANNEAU — la texture, elle, sature vite.
const CENTREPIECE_MAX_TILES := 3.4
## Opacité du dessin. En dessous de 1, on continue de voir le décor au travers,
## ce qui garde le jeu lisible pendant l'éclat.
const CENTREPIECE_ALPHA := 0.78
## Formes disponibles. Chaque élément pioche la sienne.
enum Shape { FLAME, DROP, SHARD, RUNE, SPARK }

var tile_size: int = 32
var element: Element.Kind = Element.Kind.SHADOW
var radius_tiles := 1.5

var _life := 0.0
var _duration := DURATION
var _particles: Array[Dictionary] = []
var _rings := 1
var _gravity := 0.0
var _additive := true


var _drawn: Texture2D = null
var _spin := 1.6
## La frappe ANIMÉE, quand le personnage en a une : six images qui se déroulent
## sur la vie de l'effet. Elle remplace le dessin fixe.
var _frames: Array[Texture2D] = []
## Le point d'impact DANS le dessin, en pixels de la texture. L'éclair tombe du
## haut de la case et l'éclat se produit en bas : centrer le dessin poserait la
## frappe une demi-case trop haut. Relevé au découpage sur la dernière image,
## celle où il ne reste que l'anneau au sol.
var _anchor := Vector2.ZERO


## `p_spin` : vitesse de rotation du dessin central, en tours par seconde.
##
## Elle vaut 1,6 par défaut — un vortex parfaitement immobile se lit comme un
## autocollant posé sur le sol. Mais tous les dessins d'impact n'ont pas la même
## liberté : une frappe de foudre a un HAUT et un BAS, et la faire pivoter sur
## elle-même la rend absurde. Ces dessins-là passent zéro.
func setup(p_tile_size: int, p_element: Element.Kind, p_radius: float,
		p_duration: float = DURATION, rng_seed: int = 0,
		p_drawn: Texture2D = null, p_flames: float = 0.0,
		p_spin: float = 1.6, p_frames: Array = [],
		p_anchor: Vector2 = Vector2.ZERO) -> void:
	_drawn = p_drawn
	_spin = p_spin
	for frame in p_frames:
		if frame != null:
			_frames.append(frame)
	_anchor = p_anchor
	tile_size = p_tile_size
	element = p_element
	radius_tiles = maxf(0.6, p_radius)
	_duration = maxf(0.15, p_duration)

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed if rng_seed != 0 else 7919
	# Un impact À FLAMMES ne dessine PAS ses particules géométriques : les
	# losanges et les éclats se lisaient comme des confettis jaunes posés
	# par-dessus le feu, et c'est eux qu'on voyait au lieu de l'explosion. Quand
	# il y a de vraies flammes, elles suffisent.
	if p_flames <= 0.0:
		_build(rng)
	else:
		_rings = 1

	if _additive:
		var material := CanvasItemMaterial.new()
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		self.material = material
	if p_flames > 0.0:
		_burst(p_flames)


## Chaque élément a sa gestuelle : le feu MONTE, l'eau RETOMBE, la terre est
## projetée et pèse, les ténèbres tournent. C'est ce mouvement, plus que la couleur,
## qui rend les cinq mages reconnaissables une fois en jeu.
func _build(rng: RandomNumberGenerator) -> void:
	var count := 14
	var shape := Shape.SPARK
	var palette: Array[Color] = [Element.color(element)]
	var upward := 0.0

	match element:
		Element.Kind.FIRE:
			count = 18
			shape = Shape.FLAME
			palette = [Color("#ff7a1e"), Color("#ffb03a"), Color("#ffe6a0")]
			upward = -0.55          # les flammes s'élèvent
			_gravity = -0.35
			_rings = 1
		Element.Kind.WATER:
			count = 20
			shape = Shape.DROP
			palette = [Color("#4fd8ff"), Color("#9df0ff"), Color("#ffffff")]
			_gravity = 1.15         # les gouttes retombent
			_rings = 2
		Element.Kind.EARTH:
			count = 13
			shape = Shape.SHARD
			palette = [Color("#8f6b3c"), Color("#6faa3c"), Color("#c9b58a")]
			_gravity = 1.6          # la roche pèse
			_rings = 1
			# La poussière et les cailloux ne sont pas lumineux : en additif ils
			# donneraient un feu d'artifice beige au lieu d'un éboulement.
			_additive = false
		Element.Kind.SHADOW:
			count = 12
			shape = Shape.RUNE
			palette = [Color("#b06cff"), Color("#e0c4ff"), Color("#7f5cff")]
			_gravity = -0.1
			_rings = 2
		Element.Kind.SUPREME:
			count = 26
			palette = [Color("#ff7a1e"), Color("#4fd8ff"), Color("#6faa3c"), Color("#b06cff")]
			_gravity = 0.2
			_rings = 3

	for i in count:
		var angle := rng.randf_range(0.0, TAU)
		var speed := rng.randf_range(0.55, 1.25) * radius_tiles * tile_size
		var particle_shape := shape
		if element == Element.Kind.SUPREME:
			# Le Suprême emprunte les quatre gestes à la fois : c'est sa signature.
			particle_shape = [Shape.FLAME, Shape.DROP, Shape.SHARD, Shape.RUNE][i % 4]
		_particles.append({
			"velocity": Vector2(cos(angle), sin(angle) + upward) * speed,
			"size": tile_size * rng.randf_range(0.10, 0.22) * clampf(radius_tiles, 0.8, 2.2),
			"color": palette[i % palette.size()],
			"spin": rng.randf_range(-6.0, 6.0),
			"phase": rng.randf_range(0.0, 0.25),
			"shape": particle_shape,
		})


## L'EXPLOSION : une bouffée de flammes qui part dans toutes les directions et
## RETOMBE. Les particules dessinées de la classe partent en ligne droite et
## s'amortissent — élégant pour un éclat, trop propre pour une explosion. Le
## feu, lui, doit monter puis redescendre.
##
## En une seule salve (`one_shot`) : une explosion qui continue d'émettre une
## demi-seconde après le coup se lit comme un incendie, pas comme un impact.
func _burst(density: float) -> void:
	var reach := tile_size * maxf(1.0, radius_tiles)
	# 1. LE CŒUR : une boule de feu dense qui s'ouvre d'un coup. Courte —
	#    c'est le flash, pas l'incendie.
	var core := FxTextures.flame_emitter(int(34.0 * density * maxf(1.0, radius_tiles)),
		0.34, tile_size * 1.25, Color(1.0, 0.95, 0.74, 0.9),
		Color(1.0, 0.45, 0.08, 0.0), 0.0, 180.0)
	add_child(core)
	core.one_shot = true
	core.explosiveness = 0.98            # tout part sur la même image
	core.local_coords = false
	core.initial_velocity_min = reach * 0.2
	core.initial_velocity_max = reach * 0.9
	core.damping_min = 60.0
	core.damping_max = 120.0             # la boule s'ouvre puis se fige
	core.emitting = true

	# 2. LES PROJECTIONS : des langues qui fusent plus loin et RETOMBENT.
	#    Sans elles l'explosion est une sphère propre, sans éclaboussure.
	var spray := FxTextures.flame_emitter(int(26.0 * density * maxf(1.0, radius_tiles)),
		0.62, tile_size * 0.62, Color(1.0, 0.78, 0.32, 0.8),
		Color(0.88, 0.18, 0.02, 0.0), 90.0, 180.0)
	add_child(spray)
	spray.one_shot = true
	spray.explosiveness = 0.9
	spray.local_coords = false
	spray.initial_velocity_min = reach * 0.8
	spray.initial_velocity_max = reach * 2.1
	spray.emitting = true

	# 3. LA FUMÉE : elle survit au feu et monte. C'est elle qui donne un APRÈS à
	#    l'explosion — sans elle, le feu s'éteint et il ne s'est rien passé.
	var smoke := FxTextures.smoke_emitter(int(18.0 * density * maxf(1.0, radius_tiles)),
		_duration * 1.5, tile_size * 1.5, -34.0)
	add_child(smoke)
	smoke.one_shot = true
	smoke.explosiveness = 0.55           # elle sort en gerbe, pas d'un bloc
	smoke.local_coords = false
	smoke.initial_velocity_min = reach * 0.15
	smoke.initial_velocity_max = reach * 0.8
	smoke.emitting = true


func _process(delta: float) -> void:
	_life += delta
	if _life >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := clampf(_life / _duration, 0.0, 1.0)
	_draw_centrepiece(t)
	_draw_rings(t)
	for particle in _particles:
		var age := t - float(particle["phase"])
		if age <= 0.0:
			continue
		age = clampf(age / (1.0 - float(particle["phase"])), 0.0, 1.0)
		var velocity: Vector2 = particle["velocity"]
		# Amortissement : la particule part vite puis s'essouffle. Un déplacement
		# linéaire donnerait une étoile qui s'écarte à vitesse constante — ça ne
		# ressemble à aucun impact.
		var travel := velocity * (1.0 - pow(1.0 - age, 2.2))
		travel.y += _gravity * age * age * tile_size * radius_tiles * 0.9
		var fade := 1.0 - age
		var color: Color = particle["color"]
		_draw_shape(int(particle["shape"]), travel,
			float(particle["size"]) * (1.0 - age * 0.55),
			float(particle["spin"]) * age,
			Color(color.r, color.g, color.b, fade * (0.95 if _additive else 1.0)))


## La pièce maîtresse : elle JAILLIT (0,55 -> 1,15 de taille en s'amortissant)
## puis s'éteint. Une légère rotation la garde vivante — un vortex parfaitement
## immobile se lit comme un autocollant posé sur le sol.
func _draw_centrepiece(t: float) -> void:
	# LA FRAPPE ANIMÉE PASSE DEVANT. Elle porte sa propre extinction — la
	# dernière image n'est qu'un anneau mourant — donc on ne lui impose ni
	# fondu prononcé ni rotation : elle sait ce qu'elle a à faire.
	if not _frames.is_empty():
		var index := mini(int(t * float(_frames.size())), _frames.size() - 1)
		var texture := _frames[index]
		# Mise à l'échelle sur la LARGEUR : c'est l'anneau au sol qui doit
		# couvrir la zone touchée. Sur la hauteur, le trait qui tombe du ciel
		# écraserait l'anneau à rien.
		var reach := minf(radius_tiles * 1.2, CENTREPIECE_MAX_TILES)
		var factor := (tile_size * reach) / float(texture.get_width())
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(factor, factor))
		draw_texture(texture, -_anchor, Color(1, 1, 1, minf(1.0, 1.4 * (1.0 - t))))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	if _drawn == null:
		return
	var grow := 0.55 + 0.60 * (1.0 - pow(1.0 - t, 2.4))
	var alpha := pow(1.0 - t, 0.8) * CENTREPIECE_ALPHA
	var extent := maxf(float(_drawn.get_width()), float(_drawn.get_height()))
	var span := minf(radius_tiles * 1.5, CENTREPIECE_MAX_TILES)
	var scale_factor := (tile_size * span / extent) * grow
	draw_set_transform(Vector2.ZERO, t * _spin, Vector2(scale_factor, scale_factor))
	draw_texture(_drawn, -Vector2(_drawn.get_width(), _drawn.get_height()) * 0.5,
		Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Onde de choc : elle dit l'ENVERGURE du sort, ce que les particules seules ne
## disent pas — vingt étincelles serrées ou étalées se ressemblent trop.
func _draw_rings(t: float) -> void:
	for i in _rings:
		var offset := float(i) * 0.16
		var age := clampf((t - offset) / maxf(0.05, 1.0 - offset), 0.0, 1.0)
		if age <= 0.0:
			continue
		var color := Element.color(element)
		draw_arc(Vector2.ZERO, tile_size * radius_tiles * (0.12 + 0.95 * age), 0.0, TAU, 44,
			Color(color.r, color.g, color.b, (1.0 - age) * 0.55), 1.5 + 4.0 * (1.0 - age))


func _draw_shape(shape: int, at: Vector2, size: float, rotation: float, color: Color) -> void:
	match shape:
		Shape.FLAME:
			# Goutte pointue vers le haut : la langue de feu.
			draw_colored_polygon(_rotated([
				Vector2(0.0, -size * 1.9), Vector2(size * 0.72, size * 0.35),
				Vector2(0.0, size * 0.85), Vector2(-size * 0.72, size * 0.35),
			], at, rotation * 0.25), color)
		Shape.DROP:
			draw_circle(at, size * 0.75, color)
			draw_colored_polygon(_rotated([
				Vector2(0.0, -size * 1.5), Vector2(size * 0.55, size * 0.2),
				Vector2(-size * 0.55, size * 0.2),
			], at, rotation * 0.2), Color(color.r, color.g, color.b, color.a * 0.7))
		Shape.SHARD:
			draw_colored_polygon(_rotated([
				Vector2(0.0, -size * 1.2), Vector2(size * 1.05, size * 0.45),
				Vector2(-size * 0.55, size * 1.0),
			], at, rotation), color)
		Shape.RUNE:
			# Losange à quatre branches — la forme des runes du jeu.
			draw_colored_polygon(_rotated([
				Vector2(0.0, -size * 1.7), Vector2(size * 0.5, 0.0),
				Vector2(0.0, size * 1.7), Vector2(-size * 0.5, 0.0),
			], at, rotation), color)
			draw_colored_polygon(_rotated([
				Vector2(-size * 1.7, 0.0), Vector2(0.0, -size * 0.5),
				Vector2(size * 1.7, 0.0), Vector2(0.0, size * 0.5),
			], at, rotation), Color(color.r, color.g, color.b, color.a * 0.8))
		_:
			draw_circle(at, size * 0.9, color)


func _rotated(points: Array, at: Vector2, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for point in points:
		out.append(at + (point as Vector2).rotated(angle))
	return out
