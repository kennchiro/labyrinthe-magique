class_name EarthAegis
extends Node2D

## L'ÉGIDE DE PIERRE : elle dit, tant qu'elle tourne, que rien ne peut le
## toucher.
##
## L'immunité est comme le bonus de dégâts — la seule chose d'un jeu d'action
## qu'on ne peut pas voir. Les coups ne portent plus, mais rien à l'écran ne dit
## pourquoi ni pour combien de temps. Cette égide est donc obligatoire, pas
## décorative.
##
## Deux temps, et le second est le plus important. La coque de pierre PARAÎT
## devant le mage — c'est le geste, l'instant où l'on comprend qu'il vient de se
## protéger. Puis elle se DISPERSE en cailloux et en étoiles vertes qui tournent
## autour de lui : une coque immobile plantée devant lui l'aurait caché pendant
## trente secondes, et n'aurait rien dit du temps qui reste.
##
## Elle vit ATTACHÉE au mage et le suit partout.

## Durée du temps de coque, avant la dispersion.
const SHELL := 0.55
## Opacité de la coque. Elle doit se DEVINER : ce qui compte est qu'on
## reconnaisse le mage protégé, pas qu'on admire la pierre. À pleine opacité
## elle l'effaçait complètement pendant une demi-seconde.
const SHELL_ALPHA := 0.42
## Cailloux et étoiles en orbite.
const ROCKS := 5
const SPARKS := 4
const ORBIT_TILES := 0.95
## Sous ce reste de temps, l'orbite s'accélère et se resserre : le joueur doit
## SENTIR que la protection s'achève avant qu'elle ne s'achève.
const WARNING := 4.0

var tile_size: int = 32

var _left := 0.0
var _total := 1.0
var _time := 0.0
var _shell: Sprite2D = null
var _bits: Array[Sprite2D] = []


func setup(p_tile_size: int, duration: float, aegis: Texture2D,
		rock: Texture2D, spark: Texture2D) -> void:
	tile_size = p_tile_size
	_total = maxf(0.5, duration)
	_left = _total
	z_index = 12

	if aegis != null:
		_shell = Sprite2D.new()
		_shell.texture = aegis
		var span := (tile_size * 1.9) / float(aegis.get_height())
		_shell.scale = Vector2(span, span)
		_shell.position = Vector2(0.0, -tile_size * 0.55)
		# À plein, la coque EFFACE le mage : on ne voit plus qui se protège.
		# Translucide, elle se lit comme une protection posée sur lui.
		_shell.modulate = Color(1, 1, 1, SHELL_ALPHA)
		add_child(_shell)

	# Les éclats tournent DANS LE MÊME SENS mais à des hauteurs différentes :
	# tous sur le même cercle, ils se lisent comme un anneau plat posé sur le
	# mage ; étagés, ils l'enveloppent.
	for i in ROCKS + SPARKS:
		var texture := rock if i < ROCKS else spark
		if texture == null:
			continue
		var bit := Sprite2D.new()
		bit.texture = texture
		var size := (tile_size * (0.55 if i < ROCKS else 0.5)) / float(texture.get_height())
		bit.scale = Vector2(size, size)
		bit.modulate = Color(1, 1, 1, 0)
		add_child(bit)
		_bits.append(bit)


## Relancer le sort remet l'égide à neuf plutôt que d'en empiler une seconde.
func refresh(duration: float) -> void:
	_total = maxf(0.5, duration)
	_left = _total
	_time = 0.0
	if _shell != null:
		_shell.modulate = Color(1, 1, 1, 1)


func stop() -> void:
	_left = minf(_left, 0.25)


func _process(delta: float) -> void:
	_time += delta
	_left = maxf(0.0, _left - delta)
	if _left <= 0.0:
		queue_free()
		return

	# 1. LA COQUE. Elle grandit d'un coup, tient un demi-temps, puis s'efface en
	#    se dilatant : c'est elle qui « éclate » en éclats.
	if _shell != null:
		if _time < SHELL:
			var out := clampf(_time / 0.18, 0.0, 1.0)
			var burst := 1.0 + 0.15 * sin(out * PI)
			var span := (tile_size * 1.9) / float(_shell.texture.get_height())
			_shell.scale = Vector2(span * out * burst, span * out * burst)
			_shell.modulate = Color(1, 1, 1, SHELL_ALPHA * out)
		else:
			var gone := clampf((_time - SHELL) / 0.3, 0.0, 1.0)
			var span2 := (tile_size * 1.9) / float(_shell.texture.get_height())
			var wide := span2 * (1.0 + 0.5 * gone)
			_shell.scale = Vector2(wide, wide)
			_shell.modulate = Color(1, 1, 1, SHELL_ALPHA * (1.0 - gone))
			if gone >= 1.0:
				_shell.queue_free()
				_shell = null

	# 2. LES ÉCLATS. Ils sortent de la coque au moment où elle se disperse.
	var born := clampf((_time - SHELL * 0.7) / 0.4, 0.0, 1.0)
	var hurry := 1.0 + 1.4 * (1.0 - clampf(_left / WARNING, 0.0, 1.0))
	var radius := tile_size * ORBIT_TILES * (0.35 + 0.65 * born) \
		* (1.0 - 0.18 * (hurry - 1.0))
	for i in _bits.size():
		var bit := _bits[i]
		var phase := _time * 1.9 * hurry + TAU * float(i) / float(_bits.size())
		# Écrasé à la verticale : vu de dessus, une orbite autour d'un
		# personnage est une ellipse, pas un cercle.
		# Centrés sur le TORSE et non sur les pieds : une orbite au ras du sol
		# se lit comme des cailloux qui roulent, pas comme une protection.
		bit.position = Vector2(cos(phase) * radius,
			sin(phase) * radius * 0.42 - tile_size * (0.62 + 0.16 * sin(phase)))
		# Ce qui passe DERRIÈRE lui s'assombrit et rétrécit : sans ça, les
		# éclats semblent tourner à plat devant le mage.
		var depth := 0.72 + 0.28 * (0.5 + 0.5 * sin(phase))
		bit.scale = bit.scale.normalized() * bit.scale.length() * 1.0
		bit.modulate = Color(depth, 1.0, depth * 0.9, born * (0.55 + 0.45 * depth))
		bit.z_index = 1 if sin(phase) > 0.0 else -1
		bit.rotation = phase * 0.6
