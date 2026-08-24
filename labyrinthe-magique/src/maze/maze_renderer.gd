class_name MazeRenderer
extends Node2D

## Rendu du terrain : sol, haies, bordures et ombres portées.
##
## La planche d'assets ne fournit PAS de tileset autotile : elle contient des
## morceaux de haie multi-cases à tailles irrégulières, impossibles à plaquer sur
## un labyrinthe généré aléatoirement qui a besoin des 16 configurations de
## connexion.
##
## On compose donc à partir de trois pièces seulement :
##   remplissage  — un bloc de feuillage homogène, posé sur chaque case de mur
##   bordure haute — le liseré clair fleuri, sur les murs dont le voisin nord
##                   est un couloir : c'est la face visible depuis le dessus
##   ombre portée  — sous ces mêmes murs, sur la case de couloir en dessous
##
## Ces trois pièces couvrent les 16 cas, et c'est exactement l'apparence du
## concept art : une masse de feuillage uniforme surmontée d'un liseré fleuri.

const TILE_SIZE := 32

## Planches de 96x96 = 3x3 cases, générées sans couture par tools/build_assets.py.
## Chaque case échantillonne la zone correspondant à ses coordonnées modulo 3 :
## deux cases voisines lisent deux zones VOISINES d'une même texture continue.
## C'est ce qui fait disparaître la grille — une tuile indépendante par case
## laisse toujours voir ses quatre bords, quel que soit le soin du raccord.
const TILES_PATH := "res://assets/tiles/"
const FLOOR_SHEET := preload("res://assets/tiles/floor_sheet.png")
const HEDGE_SHEET := preload("res://assets/tiles/hedge_sheet.png")
## Période d'échantillonnage, en cases.
const SHEET_TILES := 3
const HEDGE_TOP := preload("res://assets/tiles/hedge_top.png")
const HEDGE_SHADOW := preload("res://assets/tiles/hedge_shadow.png")

## Terrain du stage en cours. Les constantes ci-dessus sont le terrain de la
## forêt, qui sert de repli : un stage sans planche (le 9) garde celui-là.
var floor_sheet: Texture2D = FLOOR_SHEET
var hedge_sheet: Texture2D = HEDGE_SHEET
var hedge_top: Texture2D = HEDGE_TOP
var hedge_shadow: Texture2D = HEDGE_SHADOW

## Le sol de la clairière est légèrement réchauffé pour signaler l'objectif.
const HOUSE_FLOOR_TINT := Color(1.45, 1.25, 0.95)
## Assombrissement du sol. Les tuiles de terre de la planche ont presque la même
## valeur que le feuillage : rendues telles quelles, couloirs et haies se
## confondent et le labyrinthe devient illisible. C'est le contraste de
## LUMINOSITÉ qui fait lire le chemin, pas la couleur.
## Le sol est désormais généré directement dans sa valeur finale : plus besoin
## de l'assombrir au rendu. On garde une légère variation seulement.
const FLOOR_SHADE := Color(1.0, 1.0, 1.0)
## Les haies sont légèrement désaturées et assombries : à pleine saturation
## elles vibrent et attirent l'œil plus que le mage.
const HEDGE_SHADE := Color(0.80, 0.86, 0.74)
## Les tuiles se chevauchent d'un pixel : sans ça, le filtrage laisse une couture
## claire d'un demi-pixel entre chaque case.
const OVERLAP := 1.0

var grid: MazeGrid = null
var show_distance_field := false
var show_spawn_markers := false


## Charge le terrain d'un stage. Un stage sans dossier garde celui de la forêt —
## c'est le cas du 9, dont la planche manque, et ce serait celui de tout stage
## ajouté avant que son décor n'existe.
func set_stage(index: int) -> void:
	var folder := TILES_PATH + "stage_%d/" % index
	floor_sheet = _tile_or(folder + "floor_sheet.png", FLOOR_SHEET)
	hedge_sheet = _tile_or(folder + "hedge_sheet.png", HEDGE_SHEET)
	hedge_top = _tile_or(folder + "hedge_top.png", HEDGE_TOP)
	hedge_shadow = _tile_or(folder + "hedge_shadow.png", HEDGE_SHADOW)
	queue_redraw()


func _tile_or(path: String, fallback: Texture2D) -> Texture2D:
	if not ResourceLoader.exists(path):
		return fallback
	var texture: Texture2D = load(path)
	return texture if texture != null else fallback


func set_grid(g: MazeGrid) -> void:
	grid = g
	queue_redraw()


func toggle_distance_field() -> void:
	show_distance_field = not show_distance_field
	queue_redraw()


func maze_pixel_size() -> Vector2:
	if grid == null:
		return Vector2.ZERO
	return Vector2(grid.cols * TILE_SIZE, grid.rows * TILE_SIZE)


## Grille -> monde. Le centre de la case, pour que les entités soient centrées.
func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * TILE_SIZE + TILE_SIZE * 0.5, cell.y * TILE_SIZE + TILE_SIZE * 0.5)


func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / TILE_SIZE), floori(pos.y / TILE_SIZE))


## Bruit déterministe par case : choisit la variante de tuile et sa nuance.
## Deux tuiles suffisent tant qu'on fait varier leur teinte — sans cette
## variation, les couloirs affichent un damier régulier très visible.
static func cell_noise(cell: Vector2i, salt: int) -> int:
	var h: int = cell.x * 73856093 + cell.y * 19349663 + salt * 83492791
	h = (h ^ (h >> 13)) * 1274126177
	return absi(h ^ (h >> 16))


func _draw() -> void:
	if grid == null:
		return
	if show_distance_field:
		_draw_distance_field()
		return

	for r in grid.rows:
		for c in grid.cols:
			var cell := Vector2i(c, r)
			var position := Vector2(c * TILE_SIZE, r * TILE_SIZE)
			if grid.is_wall(c, r):
				_draw_hedge(cell, position)
			else:
				_draw_floor(cell, position)

	if show_spawn_markers:
		_draw_spawn_markers()


func _draw_floor(cell: Vector2i, position: Vector2) -> void:
	var noise := cell_noise(cell, 11)
	# La tuile d'herbe est rare : semée partout elle ferait des taches claires
	# qu'on prend pour un chemin praticable.
	var tint := _jitter(noise, 0.07) * FLOOR_SHADE
	if grid.is_house(cell):
		tint *= HOUSE_FLOOR_TINT
	_draw_sheet_cell(floor_sheet, cell, position, tint)

	# Ombre projetée par la haie située juste au-dessus.
	if grid.is_wall(cell.x, cell.y - 1):
		draw_texture_rect(hedge_shadow,
			Rect2(position, Vector2(TILE_SIZE + OVERLAP, hedge_shadow.get_height())), false)


func _draw_hedge(cell: Vector2i, position: Vector2) -> void:
	var noise := cell_noise(cell, 29)
	_draw_sheet_cell(hedge_sheet, cell, position, _jitter(noise, 0.09) * HEDGE_SHADE)

	# Face supérieure : uniquement là où la haie est vue depuis un couloir.
	if grid.is_floor(cell.x, cell.y - 1):
		draw_texture_rect(hedge_top,
			Rect2(position, Vector2(TILE_SIZE + OVERLAP, hedge_top.get_height())), false,
			_jitter(noise + 7, 0.08) * HEDGE_SHADE * Color(1.0, 1.0, 1.0, 0.75))


## Légère variation de luminosité et de teinte, déterministe.
## `clip_uv = false` est le point clé : l'échantillonnage déborde volontairement
## de la zone demandée pour aller lire les pixels voisins de la planche. Avec le
## découpage strict (le défaut), le filtrage linéaire répète le texel de bord et
## trace une ligne d'un pixel entre chaque case.
func _draw_sheet_cell(sheet: Texture2D, cell: Vector2i, position: Vector2, tint: Color) -> void:
	var source := Vector2(posmod(cell.x, SHEET_TILES), posmod(cell.y, SHEET_TILES)) * TILE_SIZE
	draw_texture_rect_region(sheet,
		Rect2(position, Vector2(TILE_SIZE, TILE_SIZE)),
		Rect2(source, Vector2(TILE_SIZE, TILE_SIZE)),
		tint, false, false)


static func _tile_rect(position: Vector2) -> Rect2:
	return Rect2(position, Vector2(TILE_SIZE + OVERLAP, TILE_SIZE + OVERLAP))


static func _jitter(noise: int, amount: float) -> Color:
	var value := 1.0 + (float(noise % 100) / 100.0 - 0.5) * 2.0 * amount
	var warmth := 1.0 + (float((noise / 100) % 100) / 100.0 - 0.5) * amount
	return Color(value * warmth, value, value * (2.0 - warmth))


# --- Vues de debug ---------------------------------------------------------------

func _draw_distance_field() -> void:
	var max_d: float = maxf(1.0, float(grid.max_distance()))
	for r in grid.rows:
		for c in grid.cols:
			var rect := Rect2(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			if grid.is_wall(c, r):
				draw_rect(rect, Color("#16281b"))
			else:
				var t: float = float(grid.distance_at(Vector2i(c, r))) / max_d
				draw_rect(rect, Color.from_hsv(0.75 - 0.75 * t, 0.65, 0.55))


func _draw_spawn_markers() -> void:
	draw_circle(cell_to_world(grid.player_spawn), TILE_SIZE * 0.3, Color("#f4f7ff"))
	for e in grid.enemy_spawns:
		draw_circle(cell_to_world(e), TILE_SIZE * 0.3, Color("#d94a3d"))
