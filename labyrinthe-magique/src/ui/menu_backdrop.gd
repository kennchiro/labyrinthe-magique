class_name MenuBackdrop
extends Control

## Fond des menus : une forêt de nuit, un vrai labyrinthe et des portails.
##
## Le labyrinthe n'est PAS un dessin : c'est un labyrinthe réellement généré par
## MazeGenerator, avec la même graine à chaque lancement. Le fond du menu montre
## donc exactement ce que le joueur va traverser — et il suivra automatiquement
## toute évolution du générateur, ce qu'une illustration ne ferait jamais.

const SKY_TOP := Color(0.04, 0.06, 0.12)
const SKY_BOTTOM := Color(0.09, 0.13, 0.10)
const WALL := Color(0.11, 0.21, 0.13, 0.85)
const FLOOR := Color(0.05, 0.08, 0.09, 0.55)

var _grid: MazeGrid = null
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Graine fixe : le menu doit avoir le même visage à chaque lancement, sinon
	# l'écran d'accueil clignote d'une partie à l'autre.
	_grid = MazeGenerator.generate(LevelConfig.for_stage(2), 20260823)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, SKY_TOP)
	# Dégradé vertical en bandes : Godot n'a pas de draw_rect dégradé, et un
	# shader pour six bandes serait disproportionné.
	var bands := 22
	for i in bands:
		var t := float(i) / float(bands - 1)
		draw_rect(Rect2(0.0, size.y * t, size.x, size.y / float(bands) + 1.0),
			SKY_TOP.lerp(SKY_BOTTOM, t * t))

	if _grid == null:
		return
	# Cases CARRÉES : en étirant la grille sur toute la hauteur restante, les
	# couloirs devenaient des bandes horizontales et le labyrinthe ne se lisait
	# plus comme un labyrinthe. On garde donc une case carrée et on n'affiche
	# que le nombre de rangées qui tiennent.
	var cell := size.x / float(_grid.cols)
	var top := size.y * 0.30
	var rows: int = mini(_grid.rows, int((size.y - top) / cell) + 1)
	for r in rows:
		var y := top + cell * r
		# Les rangées du fond sont plus sombres : c'est ce qui donne la
		# profondeur, sans calcul de perspective.
		var depth := float(r) / float(maxi(1, rows - 1))
		for c in _grid.cols:
			var color := WALL if _grid.is_wall(c, r) else FLOOR
			draw_rect(Rect2(c * cell, y, cell + 1.0, cell + 1.0),
				color.darkened(0.5 * (1.0 - depth)))

	for i in _grid.portals.size():
		var portal: Vector2i = _grid.portals[i]
		if portal.y >= rows:
			continue
		var centre := Vector2((portal.x + 0.5) * cell, top + cell * (portal.y + 0.5))
		var pulse := 0.5 + 0.5 * sin(_time * 1.8 + float(i))
		var radius := cell * (0.62 + 0.16 * pulse)
		draw_circle(centre, radius, Color(0.35, 0.72, 1.0, 0.16 + 0.08 * pulse))
		draw_circle(centre, radius * 0.42, Color(0.72, 0.94, 1.0, 0.30 + 0.12 * pulse))

	# Voile sombre en haut : le titre doit rester lisible par-dessus.
	for i in 16:
		var t := float(i) / 15.0
		draw_rect(Rect2(0.0, size.y * 0.46 * t, size.x, size.y * 0.46 / 16.0 + 1.0),
			Color(0.02, 0.03, 0.07, 0.55 * (1.0 - t)))
