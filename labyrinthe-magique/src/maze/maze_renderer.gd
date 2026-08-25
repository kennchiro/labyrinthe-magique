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

## PAS de traitement particulier pour le sol de la clairière.
##
## Il était réchauffé (x1,45 en rouge) pour signaler l'objectif du temps où la
## maison était une maisonnette de bois qu'on pouvait manquer. Depuis que chaque
## stage a son ÎLOT — quatre cases de haut, son portail allumé, son sceau de
## gemmes flottant au-dessus — le signal ne sert plus à rien et se voit trop :
## il dessinait un damier de carrés clairs autour du monument, à cheval sur les
## couloirs, qu'on prenait pour un autre type de terrain.
##
## La clairière est donc du sol de labyrinthe comme le reste. Ce qui désigne
## l'objectif, c'est ce qui est POSÉ dessus.
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

## Atlas d'AUTOTILE du stage : seize pièces de mur, une par configuration de
## voisins. Nul quand le stage n'a pas de planche dessinée — on retombe alors sur
## la tuile pleine et son chapeau, qui restent le rendu de repli.
##
## C'est ce qui donne au mur une SILHOUETTE : bouts arrondis, angles, croisements.
## Avant lui, chaque case de mur était un carré plein et la masse végétale se
## lisait comme un aplat découpé aux ciseaux.
var wall_atlas: Texture2D = null
## Côté d'une pièce dans l'atlas, déduit de sa largeur : quatre colonnes.
var _wall_piece := 0.0
var _wall_variants := 1
## Période du sol, en cases, déduite de la largeur de sa planche. Elle valait 3
## en dur ; les terrains dessinés sont en 6, et coder la valeur ici aurait fait
## lire du sol voisin à la moitié des cases.
var _floor_period := SHEET_TILES

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
	_floor_period = maxi(1, floor_sheet.get_width() / TILE_SIZE)
	var atlas_path := folder + "wall_atlas.png"
	wall_atlas = load(atlas_path) if ResourceLoader.exists(atlas_path) else null
	_wall_piece = wall_atlas.get_width() / 4.0 if wall_atlas != null else 0.0
	# L'atlas empile ses VARIANTES sous les seize pièces : sa hauteur dit combien
	# il en porte. Une par défaut, deux aujourd'hui — le nombre n'est pas codé
	# ici, pour que l'outil puisse en ajouter sans toucher au moteur.
	_wall_variants = maxi(1, int(wall_atlas.get_height() / (_wall_piece * 4.0))) \
		if wall_atlas != null else 1
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
	_draw_sheet_cell(floor_sheet, cell, position, tint)

	# Ombre projetée par la haie située juste au-dessus.
	if grid.is_wall(cell.x, cell.y - 1):
		draw_texture_rect(hedge_shadow,
			Rect2(position, Vector2(TILE_SIZE + OVERLAP, hedge_shadow.get_height())), false)


func _draw_hedge(cell: Vector2i, position: Vector2) -> void:
	var noise := cell_noise(cell, 29)
	if wall_atlas != null:
		_draw_wall_piece(cell, position, noise)
		return
	_draw_sheet_cell(hedge_sheet, cell, position, _jitter(noise, 0.09) * HEDGE_SHADE)

	# Face supérieure : uniquement là où la haie est vue depuis un couloir.
	if grid.is_floor(cell.x, cell.y - 1):
		draw_texture_rect(hedge_top,
			Rect2(position, Vector2(TILE_SIZE + OVERLAP, hedge_top.get_height())), false,
			_jitter(noise + 7, 0.08) * HEDGE_SHADE * Color(1.0, 1.0, 1.0, 0.75))


## La pièce de mur qui correspond aux VOISINS de la case.
##
## Le rang dans l'atlas est le masque des quatre voisins, bit à bit — haut 1,
## droite 2, bas 4, gauche 8 — soit exactement l'ordre dans lequel
## `tools/build_terrain.py` l'a écrit. Une case entourée de quatre murs prend la
## croix, une case isolée prend le buisson, et les quatorze autres cas sont les
## bouts, les coins et les T.
##
## Hors grille compte comme MUR : sans ça, tout le pourtour du labyrinthe se
## dessinerait en bouts arrondis tournés vers l'extérieur, comme si la haie
## s'arrêtait au bord de l'écran.
func _draw_wall_piece(cell: Vector2i, position: Vector2, noise: int) -> void:
	var mask := 0
	if _is_wall_or_outside(cell.x, cell.y - 1):
		mask |= 1
	if _is_wall_or_outside(cell.x + 1, cell.y):
		mask |= 2
	if _is_wall_or_outside(cell.x, cell.y + 1):
		mask |= 4
	if _is_wall_or_outside(cell.x - 1, cell.y):
		mask |= 8

	# La variante se tire de la case, pas du hasard : rejouer la même graine doit
	# redonner exactement le même mur, sinon deux captures ne se comparent plus.
	var variant := (noise / 7) % _wall_variants
	var source := Rect2(
		Vector2(mask % 4, mask / 4 + 4 * variant) * _wall_piece,
		Vector2(_wall_piece, _wall_piece))
	var target := Rect2(position, Vector2(TILE_SIZE + OVERLAP, TILE_SIZE + OVERLAP))
	# MIROIR une case sur deux, et seulement quand la pièce est symétrique
	# gauche-droite. Les fleurs et les éclats sont dessinés une fois pour toutes
	# dans l'atlas : sur un long mur droit, ils reviennent au même endroit à
	# chaque case et le motif se met à battre. Le miroir casse ce rythme sans
	# rien coûter — et il est LICITE ici, contrairement à la rotation : la
	# lumière vient du haut, la retourner à gauche-droite ne la déplace pas.
	var symmetric := ((mask & 2) != 0) == ((mask & 8) != 0)
	if symmetric and noise % 2 == 0:
		var centre := position + Vector2(TILE_SIZE, TILE_SIZE) * 0.5
		draw_set_transform(centre, 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect_region(wall_atlas,
			Rect2(target.position - centre, target.size), source,
			_jitter(noise, 0.06), false, false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	# PAS de `HEDGE_SHADE` ici, contrairement à la tuile de repli : cette teinte
	# désaturait et assombrissait une tuile PROCÉDURALE trop vive. Appliquée à un
	# mur dessiné, elle repeint le dessin — la haie de la Forêt virait au noir —
	# et elle défait l'écart de luminance que `build_terrain.py` vient d'imposer.
	draw_texture_rect_region(wall_atlas, target, source,
		_jitter(noise, 0.06), false, false)


func _is_wall_or_outside(x: int, y: int) -> bool:
	return x < 0 or y < 0 or x >= grid.cols or y >= grid.rows or grid.is_wall(x, y)


## Légère variation de luminosité et de teinte, déterministe.
## `clip_uv = false` est le point clé : l'échantillonnage déborde volontairement
## de la zone demandée pour aller lire les pixels voisins de la planche. Avec le
## découpage strict (le défaut), le filtrage linéaire répète le texel de bord et
## trace une ligne d'un pixel entre chaque case.
func _draw_sheet_cell(sheet: Texture2D, cell: Vector2i, position: Vector2, tint: Color) -> void:
	var source := Vector2(posmod(cell.x, _floor_period),
		posmod(cell.y, _floor_period)) * TILE_SIZE
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
