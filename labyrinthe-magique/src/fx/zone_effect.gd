class_name ZoneEffect
extends Node2D

## Surface qui brûle, gèle ou empoisonne pendant quelques secondes.
##
## Elle ne fait AUCUN dégât : le CombatSystem s'en charge, à sa propre cadence.
## Ce nœud ne fait que montrer où la zone se trouve et combien de temps il
## reste — sans quoi le joueur verrait ses ennemis fondre sans savoir pourquoi.

const RING_COUNT := 3
## Les zones peintes au shader : pas de planche, pas d'anneaux tracés.
const PAINTED_STYLES := {
	"nappe_peinte": preload("res://assets/shaders/fire_zone.gdshader"),
	"brasier_peint": preload("res://assets/shaders/fire_zone.gdshader"),
	"rune_peinte": preload("res://assets/shaders/shadow_rune.gdshader"),
	"cercle_peint": preload("res://assets/shaders/arcane_circle.gdshader"),
	"glace_peinte": preload("res://assets/shaders/water_ice.gdshader"),
	"bulle_peinte": preload("res://assets/shaders/chrono_bubble.gdshader"),
	"gaz_peint": preload("res://assets/shaders/peste_fog.gdshader"),
	"sanctuaire_peint": preload("res://assets/shaders/lumiere_sanctuary.gdshader"),
	"glas_peint": preload("res://assets/shaders/mort_bell.gdshader"),
	"sillon_peint": preload("res://assets/shaders/demon_sillon.gdshader"),
	"toile_peinte": preload("res://assets/shaders/discorde_cercle.gdshader"),
}
## La glace lit des plaques et des fissures, pas un bruit lissé (`tools/build_noise.py`).
const ICE_NOISE := preload("res://assets/shaders/ice_noise.png")
const PAINTED_FLAMES := 0.3
## La colonne de lumière du cercle d'invocation : sa hauteur, en rayons du sort.
const PILLAR_HEIGHT := 2.6
const PILLAR_FOOT := 0.16
const PILLAR_SHADER := preload("res://assets/shaders/arcane_pillar.gdshader")

var tile_size: int = 32
var tint: Color = Color.WHITE
var radius_tiles := 2.0

var _time := 0.0
var _duration := 5.0


var _drawn: Texture2D = null
## Brasier (haut, resserré, cerné) ou nappe (basse, étalée) ?
var _brazier := false
## Flamme SOMBRE : la rune des Ténèbres. Voir `_build_dark_flames`.
var _rune := false
var _seal := false
var _painted := false
## Portail POSÉ AU SOL — le passage du mage, laissé derrière lui.
var _portal := false
## Flaque d'ombre résiduelle : elle ASSOMBRIT le sol au lieu de l'éclairer.
var _gloom := false
## Ouverture : 0 à 1 pendant les premières fractions de seconde.
var _open := 0.0
## Bande d'images dessinée, quand le sort en a une (voir `play_strip`).
##
## DEUX calques et non un seul : ils montrent deux poses consécutives et se
## fondent l'une dans l'autre. Voir `_advance_strip`.
var _strip: Sprite2D = null
var _strip_next: Sprite2D = null
var _strip_frames := 1
var _strip_fps := 9.0
var _strip_scale := 1.0
## Cette zone RETIENT-elle ? Si oui, son bord est une information de jeu.
var _bites := false
## Champ électrifié : rendu par shader et non par particules.
var _field: ColorRect = null
var _field_material: ShaderMaterial = null
var _pillar_material: ShaderMaterial = null


## `p_flames` : densité des flammes ANIMÉES. Une zone qui dure trente secondes
## ne peut pas être un anneau qui pulse — au bout de cinq secondes l'œil ne le
## voit plus. Il lui faut du mouvement continu et irrégulier : des langues de
## feu qui montent, vacillent et meurent, jamais deux fois pareil.
func setup(p_tile_size: int, p_tint: Color, p_radius: float, duration: float,
		p_drawn: Texture2D = null, p_flames: float = 0.0,
		p_style: String = "nappe", p_bites: bool = false) -> void:
	_drawn = p_drawn
	# LE SCEAU EST DESSINÉ EN GRIS, exprès. C'est la seule zone du jeu dont le
	# dessin ne porte pas sa propre couleur : le Suprême en pose QUATRE d'un
	# coup, une par élément, et les quatre sortent de la MÊME image. C'est donc
	# ici qu'ils prennent leur teinte — sans quoi on aurait quatre sceaux
	# identiques, et le joueur ne saurait pas lequel garde quel couloir.
	_seal = p_style == "sceau"
	_painted = PAINTED_STYLES.has(p_style)
	_brazier = p_style == "brasier" or p_style == "brasier_peint"
	_rune = p_style == "rune"
	_portal = p_style == "portail"
	_gloom = p_style == "ombre"
	_bites = p_bites
	tile_size = p_tile_size
	tint = p_tint
	radius_tiles = maxf(0.5, p_radius)
	_duration = maxf(0.1, duration)
	# ON NE PEUT PAS DESSINER DU NOIR EN ADDITIF. L'additif AJOUTE de la lumière :
	# une cendre noire n'y change rien, et un violet vif y sature en rose. Les
	# zones de feu, de glace et de foudre veulent justement cette lumière — la
	# flamme SOMBRE, non. Elle est donc la seule à se composer normalement,
	# c'est-à-dire à pouvoir ASSOMBRIR le sol qu'elle consume.
	var material := CanvasItemMaterial.new()
	# LE SCEAU SE COMPOSE NORMALEMENT, comme la rune et la flaque d'ombre. En
	# additif, une gravure GRISE teintée n'ajoute que de la lumière : sur l'herbe
	# claire de la Forêt les quatre sceaux se délavaient en un halo blanchâtre, et
	# leur couleur — la seule chose qui dit quel élément garde quel couloir —
	# disparaissait. Composé normalement, l'or reste de l'or et le rouge du rouge.
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX if _rune or _gloom \
		or _seal or _painted else CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material
	if _painted:
		_build_painted(p_style)
		# Quelques flammes sur le Sol embrasé, aucune ailleurs : leur additif faisait
		# des taches floues dans l'aura, et le reste ne brûle pas.
		p_flames = p_flames * PAINTED_FLAMES if p_style == "nappe_peinte" else 0.0
	if p_style == "champ":
		_build_field()
	elif _rune and p_flames > 0.0:
		_build_dark_flames(p_flames)
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
func _build_field() -> void:
	var span := tile_size * radius_tiles * 2.0
	_field = ColorRect.new()
	_field.size = Vector2(span, span)
	_field.position = -_field.size * 0.5
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_field_material = ShaderMaterial.new()
	_field_material.shader = load("res://assets/shaders/field.gdshader")
	_field_material.set_shader_parameter("noise", PaintedFx.THUNDER_NOISE)
	_field.material = _field_material
	add_child(_field)


## LE SOL OU L'AURA DU FEU, peints au shader. Même porteur que le champ électrifié :
## un quad large de deux rayons, pour que le dessin s'arrête où le sort s'arrête.
func _build_painted(style: String) -> void:
	var span := tile_size * radius_tiles * 2.0
	_field = ColorRect.new()
	_field.size = Vector2(span, span)
	_field.position = -_field.size * 0.5
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_field_material = painted_material(style, radius_tiles,
		float(Time.get_ticks_usec() % 1000) * 0.001)
	_field.material = _field_material
	add_child(_field)
	if style == "cercle_peint":
		_build_pillar(span)


func _build_pillar(span: float) -> void:
	var pillar := ColorRect.new()
	pillar.size = Vector2(span, span * 0.5 * PILLAR_HEIGHT)
	# Son pied descend sous le centre du cercle : voir `FOOT` dans le shader.
	pillar.position = Vector2(-span * 0.5, -pillar.size.y * (1.0 - PILLAR_FOOT))
	pillar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pillar_material = ShaderMaterial.new()
	_pillar_material.shader = PILLAR_SHADER
	_pillar_material.set_shader_parameter("seed", float(Time.get_ticks_usec() % 1000) * 0.001)
	pillar.material = _pillar_material
	add_child(pillar)


static func painted_material(style: String, radius: float, seed_value: float) -> ShaderMaterial:
	var shaded := ShaderMaterial.new()
	shaded.shader = PAINTED_STYLES[style]
	shaded.set_shader_parameter("noise",
		ICE_NOISE if style == "glace_peinte" else MagicOrb.PAINTED_NOISE)
	shaded.set_shader_parameter("aura", 1.0 if style == "brasier_peint" else 0.0)
	shaded.set_shader_parameter("radius_tiles", radius)
	shaded.set_shader_parameter("seed", seed_value)
	return shaded


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


## LA FLAMME SOMBRE. Une flamme de feu est chaude au cœur et pâle en montant ;
## celle-ci fait l'INVERSE — cœur violet vif, cendre NOIRE au sommet. C'est ce
## renversement qui la fait lire comme une brûlure d'ombre et non comme un feu
## repeint en violet : la couleur seule ne suffit pas, c'est le sens du dégradé
## qui porte l'idée.
##
## Deux couches, et la seconde compte autant que la première :
##   flammes  hautes et resserrées, violet ardent vers le noir
##   cendres  rares, lentes, NOIRES et opaques, qui montent plus haut que les
##            flammes et s'éteignent — sans elles la zone brille comme une
##            lampe, avec elles elle a l'air de consumer quelque chose.
func _build_dark_flames(density: float) -> void:
	var radius := tile_size * radius_tiles
	var spread := radius_tiles * radius_tiles
	# Langues fines et non blobs : à 0,34 case, une flamme se lit comme une
	# LANGUE ; au-delà elle devient une fumée ronde qui masque le sol.
	_add_layer(density * spread * 1.5, radius * 0.80, 0.55, tile_size * 0.34,
		Color(0.52, 0.13, 0.86, 0.85), Color(0.08, 0.01, 0.14, 0.0),
		-38.0, 22.0, false)
	# Les cendres montent PLUS HAUT et plus lentement que les flammes : c'est ce
	# décalage qui donne l'impression que quelque chose se consume, et non que
	# la zone brille.
	_add_layer(density * spread * 0.55, radius * 0.58, 1.05, tile_size * 0.26,
		Color(0.06, 0.02, 0.10, 0.80), Color(0.0, 0.0, 0.0, 0.0),
		-58.0, 14.0, false)


func _add_layer(density: float, radius: float, life: float,
		size: float, hot: Color, cold: Color, rise: float,
		spread_angle: float = 22.0, additive: bool = true) -> void:
	# L'émetteur vient de l'atelier commun (`FxTextures`) : le brasier, le
	# panache de la boule de feu et l'explosion partagent la même fabrique, donc
	# la même matière. Trois copies du même réglage auraient dérivé.
	var flames := FxTextures.flame_emitter(int(46.0 * density), life, size,
		hot, cold, rise, spread_angle, additive)
	add_child(flames)
	flames.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	flames.emission_sphere_radius = radius
	flames.direction = Vector2(0.0, -1.0)
	flames.emitting = true


## Joue une BANDE D'IMAGES dessinée à la place du dessin procédural.
##
## Six images valent mieux que deux anneaux qui tournent : le portail a des
## runes gravées, un puits qui se creuse et des éclats qui montent, toutes
## choses qu'on ne trace pas à l'`draw_arc`. Le procédural reste pour ce que la
## bande ne peut pas faire — l'ouverture, qui doit durer ce que le sort décide.
func play_strip(texture: Texture2D, frames: int, fps: float = 9.0) -> void:
	if texture == null or frames < 1:
		return
	_strip_frames = frames
	_strip_fps = fps
	var frame_width := float(texture.get_width()) / float(frames)
	# Calé sur la LARGEUR : le portail est une ellipse, sa hauteur ne dit rien
	# de son emprise au sol. Un calage sur la hauteur le ferait déborder.
	var factor := (tile_size * radius_tiles * 2.0) / frame_width
	for i in 2:
		var layer := Sprite2D.new()
		layer.texture = texture
		layer.hframes = frames
		layer.vframes = 1
		layer.scale = Vector2(factor, factor)
		add_child(layer)
		_strip_scale = factor
		if i == 0:
			_strip = layer
		else:
			_strip_next = layer
	_build_embers()


## LA ROTATION CONTINUE.
##
## Les six poses de la planche sont chacune un sixième de tour. Les enchaîner
## sèchement — une pose, puis la suivante — donne six saccades par tour : l'œil
## voit le SAUT, pas la rotation. On affiche donc DEUX poses consécutives l'une
## sur l'autre et on les fond selon la partie fractionnaire du temps. Entre la
## pose 2 et la 3, on voit littéralement l'entre-deux.
##
## C'est aussi ce qui permet de tourner LENTEMENT sans que ça devienne un
## diaporama : à 4,5 images par seconde, un tour dure une seconde et un tiers,
## et la fondu comble les intervalles.
func _advance_strip() -> void:
	var position: float = _time * _strip_fps
	var index: int = int(floor(position))
	var blend: float = position - floor(position)
	var life := 1.0 - _time / _duration
	# Le portail s'éteint sur sa dernière seconde, pas d'un coup.
	var alpha := _open * clampf(life * 3.0, 0.0, 1.0)
	_strip.frame = index % _strip_frames
	_strip_next.frame = (index + 1) % _strip_frames
	_strip.self_modulate = Color(1.0, 1.0, 1.0, alpha * (1.0 - blend))
	_strip_next.self_modulate = Color(1.0, 1.0, 1.0, alpha * blend)
	# L'ouverture n'est pas qu'un fondu : le passage s'ÉCARTE depuis le centre.
	var grow: float = 0.55 + 0.45 * _open
	_strip.scale = Vector2(_strip_scale * grow, _strip_scale * grow)
	_strip_next.scale = _strip.scale


## Les braises du puits : rares, lentes, elles montent et s'éteignent.
##
## Elles ne décorent pas — elles donnent au portail un mouvement CONTINU entre
## deux poses dessinées. Sans elles, l'œil n'a que le fondu pour croire que
## quelque chose tourne ; avec elles, il y a toujours quelque chose qui bouge.
func _build_embers() -> void:
	var embers := FxTextures.flame_emitter(14, 1.3, tile_size * 0.20,
		Color(0.78, 0.42, 1.0, 0.85), Color(0.28, 0.06, 0.48, 0.0), -30.0, 34.0)
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	embers.emission_sphere_radius = tile_size * radius_tiles * 0.62
	embers.direction = Vector2(0.0, -1.0)
	embers.emitting = true
	add_child(embers)


## Durée de l'ouverture. Une zone qui APPARAÎT d'un coup se lit comme un défaut
## d'affichage ; un portail qui s'ouvre se lit comme un sort.
const OPEN_TIME := 0.42


func _process(delta: float) -> void:
	_time += delta
	# Courbe d'ouverture ADOUCIE AUX DEUX BOUTS (lissage de Hermite) : un
	# fondu linéaire démarre et s'arrête brutalement, et c'est justement aux
	# deux extrémités que l'œil le remarque.
	var t := clampf(_time / OPEN_TIME, 0.0, 1.0)
	_open = t * t * (3.0 - 2.0 * t)
	if _strip != null:
		_advance_strip()
	if _field_material != null:
		_field_material.set_shader_parameter("phase", _time)
		_field_material.set_shader_parameter("life", 1.0 - _time / _duration)
	if _pillar_material != null:
		_pillar_material.set_shader_parameter("phase", _time)
		_pillar_material.set_shader_parameter("life", 1.0 - _time / _duration)
	if _time >= _duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	# Le champ non plus : ses anneaux jaunes par-dessus son shader lui rendaient l'aspect
	# d'un disque brûlé.
	if _painted or _field != null:
		return
	var life := 1.0 - _time / _duration
	# La zone PÂLIT en s'épuisant : c'est le seul indice qui dit au joueur
	# combien de temps il peut encore compter dessus.
	var pulse := 0.5 + 0.5 * sin(_time * 5.0)
	var radius := tile_size * radius_tiles
	# Le cercle DESSINÉ de la planche — l'anneau de feu, le cercle de pierres.
	# Il pulse et pâlit avec la zone : lui aussi doit dire le temps qui reste.
	if _drawn != null:
		var extent := maxf(float(_drawn.get_width()), float(_drawn.get_height()))
		var span := (radius * 2.0 / extent) * (0.94 + 0.06 * pulse) \
			* (0.35 + 0.65 * _open if _portal else 1.0)
		# La NAPPE est écrasée à l'horizontale : vue de dessus, une flaque qui
		# s'étale n'est pas un disque parfait, et c'est ce qui la distingue du
		# brasier au premier coup d'œil, avant même de compter les flammes.
		var squash := Vector2(span * 1.12, span * 0.74) if not _brazier \
			else Vector2(span, span)
		if _portal:
			squash = Vector2(span * 1.02, span * 0.66)
		draw_set_transform(Vector2.ZERO, 0.0, squash)
		# Le portail est dessiné pour une COLONNE VERTICALE, vu de face et très
		# lumineux. Posé à plat et composé en additif, il noyait le mage debout
		# dessus. On l'assombrit et on l'écrase : au sol, un passage est une
		# ellipse basse, pas un soleil.
		var drawn_alpha := (0.55 + 0.25 * pulse) * life
		# LE SCEAU EST UNE GRAVURE, pas une lueur. Composé normalement, il lui
		# faut de l'opacité pour se lire sur le sol : à 0,55 il restait un
		# fantôme. Il pâlit quand même avec le temps qui reste, comme toute
		# zone — c'est le seul indice qui dit combien de temps elle tient encore.
		if _seal:
			drawn_alpha = (0.88 + 0.12 * pulse) * life
		if _portal:
			drawn_alpha = (0.26 + 0.10 * pulse) * life * _open
		draw_texture(_drawn, -Vector2(_drawn.get_width(), _drawn.get_height()) * 0.5,
			Color(0.80, 0.62, 1.0, drawn_alpha) if _portal
			else (Color(tint.r, tint.g, tint.b, drawn_alpha) if _seal
			else Color(1, 1, 1, drawn_alpha)))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# PAS D'ANNEAU DE MORSURE SUR UN SCEAU, même quand il englue.
	#
	# L'anneau à crocs tournants est une bonne information de jeu — il dit où le
	# piège se referme — mais il n'est dessiné que sur les zones qui ENGLUENT, et
	# des quatre sceaux du Suprême, seul celui de la TERRE englue. Il se
	# retrouvait donc cerné d'un anneau qui tourne quand les trois autres n'en
	# avaient pas : les quatre ne se lisaient plus comme un même sort à quatre
	# couleurs. Chaque sceau annonce déjà son effet par sa propre animation.
	if _bites and not _seal:
		_draw_bite_ring(radius, life, pulse)
	if _portal:
		_draw_portal(radius, life, pulse)
		return
	if _rune:
		_draw_scorch(radius, life, pulse)
		return
	if _gloom:
		_draw_gloom(radius, life, pulse)
		return
	draw_circle(Vector2.ZERO, radius, Color(tint.r, tint.g, tint.b, 0.07 * life))
	for i in RING_COUNT:
		var phase := fposmod(_time * 0.6 + float(i) / float(RING_COUNT), 1.0)
		draw_arc(Vector2.ZERO, radius * (0.25 + 0.75 * phase), 0.0, TAU, 36,
			Color(tint.r, tint.g, tint.b, (0.30 + 0.15 * pulse) * life * (1.0 - phase)), 2.0)



## LA FLAQUE D'OMBRE laissée par une implosion.
##
## Elle est le contraire d'une zone ordinaire : celles-ci s'allument, celle-ci
## ÉTEINT. Rien n'y brille, rien n'y pulse vite — une nappe qui bat au rythme
## d'un brasier dirait « attention, c'est chaud », alors qu'ici il faut dire
## « il ne se passe rien, et c'est bien le problème ».
##
## Le bord est FRANGÉ et non net. Une flaque à contour régulier se lit comme un
## élément d'interface — un marqueur de portée — et le joueur cesse de la voir
## comme une matière posée sur le sol.
func _draw_gloom(radius: float, life: float, pulse: float) -> void:
	# Le corps : trois disques de plus en plus sombres, en composition normale,
	# donc capables d'assombrir vraiment. L'additif ne saurait pas le faire. Ils
	# gardent une pointe de la teinte du mage — un noir pur aurait l'air d'un
	# trou dans le rendu plutôt que d'une matière posée sur le sol.
	var ink := Color(0.05 + tint.r * 0.05, 0.02 + tint.g * 0.03, 0.10 + tint.b * 0.06)
	for i in 3:
		var span := radius * (1.0 - 0.22 * float(i))
		draw_circle(Vector2.ZERO, span,
			Color(ink.r, ink.g, ink.b, (0.15 + 0.09 * float(i)) * life))

	# La frange. Les lobes n'ont PAS tous le même rayon : à taille égale et alpha
	# suffisant, ils se lisaient comme une rosace de cercles empilés — une
	# figure, exactement ce qu'une flaque ne doit pas être. Irréguliers et très
	# pâles, c'est leur superposition qui fait le bord.
	var lobes := 17
	for i in lobes:
		var angle := TAU * float(i) / float(lobes)
		var jitter := 0.78 + 0.22 * sin(float(i) * 2.399)
		var breath := 0.90 + 0.10 * sin(_time * 1.3 + float(i) * 1.7)
		draw_circle(Vector2(cos(angle), sin(angle)) * radius * 0.80 * breath,
			radius * 0.30 * jitter, Color(ink.r, ink.g, ink.b, 0.085 * life))

	# Les remontées de poison : des bulles qui crèvent la surface. Elles sont le
	# SEUL mouvement de la flaque, et elles disent qu'elle est vivante sans
	# jamais l'éclairer — une lueur ici trahirait la nature du sort.
	for i in 9:
		var phase := fposmod(_time * 0.45 + float(i) / 9.0, 1.0)
		var angle := float(i) * 2.399 + _time * 0.12
		var spot := Vector2(cos(angle), sin(angle)) * radius * (0.12 + 0.58 * phase)
		var swell := 1.4 + 3.6 * (1.0 - phase)
		draw_circle(spot, swell, Color(tint.r * 0.75, tint.g * 0.35, tint.b * 0.85,
			0.60 * life * (1.0 - phase)))
		draw_arc(spot, swell * 1.6, 0.0, TAU, 12,
			Color(tint.r, tint.g * 0.5, tint.b, 0.24 * life * (1.0 - phase)), 1.0)

	# L'anneau, à peine marqué : il donne la portée sans faire de la flaque un
	# cercle dessiné. Il pulse LENTEMENT — c'est ce qui reste d'une zone.
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48,
		Color(tint.r * 0.6, tint.g * 0.3, tint.b * 0.7,
			(0.16 + 0.08 * pulse) * life), 2.0)


## LE PORTAIL POSÉ AU SOL.
##
## Il s'ouvre au lieu d'apparaître : le disque s'écarte depuis le centre et
## l'anneau prend son ampleur, en un peu moins d'une demi-seconde. C'est ce qui
## le distingue d'une zone qui s'allume — un passage s'OUVRE.
##
## Il tourne lentement et sans à-coup, dans un seul sens. Un portail immobile
## est un décal posé sur le sol ; un portail qui bat comme une zone serait un
## piège. Celui-ci tourne, donc il est ouvert et il aspire.
func _draw_portal(radius: float, life: float, pulse: float) -> void:
	# Quand la bande dessinée joue, elle porte TOUT le portail : anneaux, puits,
	# éclats. Le procédural ne doit rien redessiner par-dessus, sinon deux
	# anneaux se superposent et l'un tourne moins vite que l'autre.
	if _strip != null:
		return
	var span := radius * (0.35 + 0.65 * _open)
	draw_circle(Vector2.ZERO, span * 0.92,
		Color(0.05, 0.0, 0.10, 0.45 * life * _open))
	# Deux anneaux tournant en SENS INVERSE : c'est ce qui donne la profondeur
	# du puits sans avoir à dessiner un puits.
	for i in 2:
		var way := 1.0 if i == 0 else -1.0
		var wobble := 0.94 + 0.06 * sin(_time * 3.0 + float(i) * PI)
		draw_arc(Vector2.ZERO, span * wobble * (1.0 - 0.18 * float(i)),
			_time * 1.6 * way, _time * 1.6 * way + TAU * 0.86, 40,
			Color(0.62, 0.24, 1.0, (0.55 + 0.25 * pulse) * life * _open),
			2.6 - 0.9 * float(i))
	# Un œil sombre au centre, et non un cœur brillant : c'est un trou, pas une
	# lampe. C'est aussi ce qui garde le mage lisible quand il se tient dessus.
	draw_circle(Vector2.ZERO, span * 0.34,
		Color(0.10, 0.02, 0.18, 0.34 * life * _open))


## La BRÛLURE au sol de la flamme sombre.
##
## Un disque NOIR — c'est lui qui dit « ici, le sol est consumé », et c'est
## seulement possible parce que la rune se compose normalement. Par-dessus, un
## unique anneau violet qui respire : deux anneaux concentriques feraient un
## portail, or ce sort n'emmène nulle part.
func _draw_scorch(radius: float, life: float, pulse: float) -> void:
	draw_circle(Vector2.ZERO, radius * 0.96, Color(0.03, 0.0, 0.06, 0.62 * life))
	draw_circle(Vector2.ZERO, radius * 0.62, Color(0.09, 0.01, 0.16, 0.55 * life))
	draw_arc(Vector2.ZERO, radius * (0.90 + 0.05 * pulse), 0.0, TAU, 44,
		Color(0.68, 0.22, 1.0, (0.55 + 0.30 * pulse) * life), 2.5)


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
