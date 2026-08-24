class_name ZoneEffect
extends Node2D

## Surface qui brûle, gèle ou empoisonne pendant quelques secondes.
##
## Elle ne fait AUCUN dégât : le CombatSystem s'en charge, à sa propre cadence.
## Ce nœud ne fait que montrer où la zone se trouve et combien de temps il
## reste — sans quoi le joueur verrait ses ennemis fondre sans savoir pourquoi.

const RING_COUNT := 3

var tile_size: int = 32
var tint: Color = Color.WHITE
var radius_tiles := 2.0

var _time := 0.0
var _duration := 5.0


var _drawn: Texture2D = null
## Brasier (haut, resserré, cerné) ou nappe (basse, étalée) ?
var _brazier := false
## Cette zone RETIENT-elle ? Si oui, son bord est une information de jeu.
var _bites := false
## Champ électrifié : rendu par shader et non par particules.
var _field: ColorRect = null
var _field_material: ShaderMaterial = null


## `p_flames` : densité des flammes ANIMÉES. Une zone qui dure trente secondes
## ne peut pas être un anneau qui pulse — au bout de cinq secondes l'œil ne le
## voit plus. Il lui faut du mouvement continu et irrégulier : des langues de
## feu qui montent, vacillent et meurent, jamais deux fois pareil.
func setup(p_tile_size: int, p_tint: Color, p_radius: float, duration: float,
		p_drawn: Texture2D = null, p_flames: float = 0.0,
		p_style: String = "nappe", p_bites: bool = false) -> void:
	_drawn = p_drawn
	_brazier = p_style == "brasier"
	_bites = p_bites
	tile_size = p_tile_size
	tint = p_tint
	radius_tiles = maxf(0.5, p_radius)
	_duration = maxf(0.1, duration)
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material
	if p_style == "champ":
		_build_field(p_tint)
	elif p_flames > 0.0:
		if _brazier:
			_build_brazier(p_flames)
		else:
			_build_sheet(p_flames)


## Deux nappes superposées : un lit de braises au ras du sol, et des langues
## qui montent par-dessus. Une seule couche donnait une fontaine d'étincelles,
## pas un brasier — c'est le CONTRASTE entre la base dense et immobile et les
## pointes qui s'échappent qui fait lire « ça brûle ».
## LE BRASIER : deux couches serrées qui montent haut. C'est une colonne, pas
## une flaque — on doit le voir de loin et comprendre qu'il tient le terrain.
## LE CHAMP ÉLECTRIFIÉ. Un quad en shader plutôt que des particules :
## l'électricité est faite de TRAITS qui relient, pas de grains qui volent. Des
## particules donnent des étincelles — jolies, mais elles ne disent pas « ce sol
## est sous tension ».
func _build_field(tint: Color) -> void:
	var span := tile_size * radius_tiles * 2.0
	_field = ColorRect.new()
	_field.size = Vector2(span, span)
	_field.position = -_field.size * 0.5
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_field_material = ShaderMaterial.new()
	_field_material.shader = load("res://assets/shaders/field.gdshader")
	_field_material.set_shader_parameter("arc_color", Color(0.92, 0.96, 1.0))
	_field_material.set_shader_parameter("glow_color", tint)
	_field.material = _field_material
	add_child(_field)


func _build_brazier(density: float) -> void:
	var radius := tile_size * radius_tiles
	# Le nombre de braises suit l'AIRE et non le rayon : à densité constante, un
	# brasier deux fois plus large paraissait deux fois plus clairsemé, parce
	# qu'on étalait le même nombre de flammes sur quatre fois la surface.
	var spread := radius_tiles * radius_tiles
	# Lit de braises : dense, resserré. C'est la MASSE — elle doit se
	# chevaucher, sinon on voit des lumières isolées et non un feu.
	_add_layer(density * spread * 1.9, radius * 0.8, 0.85, tile_size * 0.95,
		Color(1.0, 0.48, 0.08, 0.8), Color(1.0, 0.86, 0.46, 0.0), -18.0, 20.0)
	# Colonne : haute, blanche au cœur, étroite. La signature du brasier.
	_add_layer(density * spread * 1.0, radius * 0.55, 1.5, tile_size * 0.62,
		Color(1.0, 0.95, 0.72, 0.95), Color(0.95, 0.35, 0.06, 0.0), -104.0, 12.0)


## LA NAPPE : basse et ÉTALÉE, elle rampe au sol. Flammes couchées, largement
## dispersées, courtes — l'inverse exact de la colonne du brasier.
func _build_sheet(density: float) -> void:
	var radius := tile_size * radius_tiles
	var spread := radius_tiles * radius_tiles
	# Une seule couche, mais large et rasante : la nappe n'a pas de hauteur.
	_add_layer(density * spread * 2.4, radius * 1.05, 0.55, tile_size * 0.72,
		Color(1.0, 0.34, 0.05, 0.85), Color(0.95, 0.72, 0.20, 0.0), -6.0, 96.0)


func _build_flames(density: float) -> void:
	var radius := tile_size * radius_tiles


func _add_layer(density: float, radius: float, life: float,
		size: float, hot: Color, cold: Color, rise: float,
		spread_angle: float = 22.0) -> void:
	# L'émetteur vient de l'atelier commun (`FxTextures`) : le brasier, le
	# panache de la boule de feu et l'explosion partagent la même fabrique, donc
	# la même matière. Trois copies du même réglage auraient dérivé.
	var flames := FxTextures.flame_emitter(int(46.0 * density), life, size,
		hot, cold, rise, spread_angle)
	add_child(flames)
	flames.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	flames.emission_sphere_radius = radius
	flames.direction = Vector2(0.0, -1.0)
	flames.emitting = true


func _process(delta: float) -> void:
	_time += delta
	if _field_material != null:
		_field_material.set_shader_parameter("phase", _time)
		_field_material.set_shader_parameter("life", 1.0 - _time / _duration)
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var life := 1.0 - _time / _duration
	# La zone PÂLIT en s'épuisant : c'est le seul indice qui dit au joueur
	# combien de temps il peut encore compter dessus.
	var pulse := 0.5 + 0.5 * sin(_time * 5.0)
	var radius := tile_size * radius_tiles
	# Le cercle DESSINÉ de la planche — l'anneau de feu, le cercle de pierres.
	# Il pulse et pâlit avec la zone : lui aussi doit dire le temps qui reste.
	if _drawn != null:
		var extent := maxf(float(_drawn.get_width()), float(_drawn.get_height()))
		var span := (radius * 2.0 / extent) * (0.94 + 0.06 * pulse)
		# La NAPPE est écrasée à l'horizontale : vue de dessus, une flaque qui
		# s'étale n'est pas un disque parfait, et c'est ce qui la distingue du
		# brasier au premier coup d'œil, avant même de compter les flammes.
		var squash := Vector2(span * 1.12, span * 0.74) if not _brazier \
			else Vector2(span, span)
		draw_set_transform(Vector2.ZERO, 0.0, squash)
		draw_texture(_drawn, -Vector2(_drawn.get_width(), _drawn.get_height()) * 0.5,
			Color(1, 1, 1, (0.55 + 0.25 * pulse) * life))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if _bites:
		_draw_bite_ring(radius, life, pulse)
	draw_circle(Vector2.ZERO, radius, Color(tint.r, tint.g, tint.b, 0.07 * life))
	for i in RING_COUNT:
		var phase := fposmod(_time * 0.6 + float(i) / float(RING_COUNT), 1.0)
		draw_arc(Vector2.ZERO, radius * (0.25 + 0.75 * phase), 0.0, TAU, 36,
			Color(tint.r, tint.g, tint.b, (0.30 + 0.15 * pulse) * life * (1.0 - phase)), 2.0)


## L'anneau de MORSURE : le bord exact où le piège se referme.
##
## Ce n'est pas de la décoration, c'est une information de jeu. Un brasier qui
## cloue sur place pendant cinq secondes doit dire OÙ il mord — sinon le joueur
## le frôle, se fait prendre, et ne comprend pas pourquoi. Les flammes, larges
## et floues, ne peuvent pas porter cette limite ; un trait net, si.
##
## Il bat plus vite que la zone elle-même : un bord immobile se lit comme un
## décor, un bord qui palpite se lit comme une mâchoire.
func _draw_bite_ring(radius: float, life: float, pulse: float) -> void:
	var beat := 0.5 + 0.5 * sin(_time * 9.0)
	var edge := Color(1.0, 0.88, 0.55, (0.45 + 0.35 * beat) * life)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, edge, 2.0 + 1.5 * beat)
	# Des crocs : de courts traits vers l'intérieur, tout autour. Ils disent le
	# SENS de la menace — ça attrape vers le centre, ça ne repousse pas.
	var teeth := 12
	for i in teeth:
		var angle := TAU * float(i) / float(teeth) + _time * 0.6
		var direction := Vector2(cos(angle), sin(angle))
		draw_line(direction * radius, direction * (radius - tile_size * 0.22 * (0.6 + 0.4 * beat)),
			Color(1.0, 0.72, 0.30, 0.55 * life), 2.0)
