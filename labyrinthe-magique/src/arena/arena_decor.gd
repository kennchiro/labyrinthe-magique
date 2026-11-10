class_name ArenaDecor
extends RefCounted

## LES DÉCORS DU COLISÉE, posés debout (`assets/arena/decor/`, `tools/build_arena.py`).
##
## Ils ne vont QUE sur des murs : l'enceinte, les piliers et les bornes de la gemme. Une case où l'on se
## bat ne porte jamais rien — un brasero au milieu d'un couloir cacherait un héros sans le gêner, et le
## combat, qui ne connaît que la grille, ne le verrait pas. Les piliers et les bornes ont la forme des
## murs que `ArenaRules.LAYOUT` pose déjà : le dessin habille l'obstacle, il n'en crée pas.
##
## Chaque décor est posé par ses PIEDS, au bas de sa case, dans les `Entities` triées par hauteur :
## un héros qui passe devant une statue la cache, un héros derrière elle est caché.

const FOLDER := "res://assets/arena/decor/"
## Hauteur à l'écran, en cases.
const HEIGHTS := {
	"pilier": 1.9, "pilier_brise": 1.25, "brasero_feu": 1.15, "brasero_bleu": 1.15,
	"etendard_bleu": 1.8, "etendard_rouge": 1.8, "statue": 1.9, "boucliers": 0.95,
	"tonneaux": 1.15, "cristal": 1.0, "haie": 0.9, "muret": 0.9,
}
## [nom, case]. Bleus à gauche, rouges à droite, comme les camps.
const PLACES := [
	["etendard_bleu", Vector2i(3, 0)], ["etendard_bleu", Vector2i(7, 0)],
	["etendard_rouge", Vector2i(13, 0)], ["etendard_rouge", Vector2i(17, 0)],
	["brasero_bleu", Vector2i(1, 0)], ["brasero_feu", Vector2i(19, 0)],
	["brasero_bleu", Vector2i(1, 12)], ["brasero_feu", Vector2i(19, 12)],
	["statue", Vector2i(5, 12)], ["statue", Vector2i(15, 12)],
	["boucliers", Vector2i(8, 12)], ["tonneaux", Vector2i(12, 12)],
	["cristal", Vector2i(0, 6)], ["cristal", Vector2i(20, 6)],
	["pilier", Vector2i(0, 3)], ["pilier", Vector2i(0, 9)],
	["pilier", Vector2i(20, 3)], ["pilier", Vector2i(20, 9)],
	# Les colonnades : un pilier par case des quatre blocs de deux.
	["pilier", Vector2i(4, 3)], ["pilier", Vector2i(5, 3)], ["pilier", Vector2i(15, 3)], ["pilier", Vector2i(16, 3)],
	["pilier", Vector2i(4, 9)], ["pilier", Vector2i(5, 9)], ["pilier", Vector2i(15, 9)], ["pilier", Vector2i(16, 9)],
	# Les quatre bornes de la place de la gemme.
	["pilier_brise", Vector2i(8, 5)], ["pilier_brise", Vector2i(12, 5)],
	["pilier_brise", Vector2i(8, 7)], ["pilier_brise", Vector2i(12, 7)],
]


## Pose les décors dans `parent`. Ne pose que sur des murs : un décor sur une case de sol est refusé.
static func place(parent: Node2D, grid: MazeGrid, tile: int) -> int:
	var placed := 0
	for entry in PLACES:
		var name: String = entry[0]
		var cell: Vector2i = entry[1]
		var path := FOLDER + name + ".png"
		if not grid.in_bounds(cell.x, cell.y) or grid.is_floor_v(cell) or not ResourceLoader.exists(path):
			continue
		var texture: Texture2D = load(path)
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.centered = false
		sprite.offset = Vector2(-texture.get_width() * 0.5, -texture.get_height())
		var factor := float(HEIGHTS.get(name, 1.0)) * float(tile) / float(texture.get_height())
		sprite.scale = Vector2(factor, factor)
		# Les pieds au bas de la case, un peu remontés : le socle du dessin a son épaisseur.
		sprite.position = (Vector2(cell) + Vector2(0.5, 0.92)) * float(tile)
		sprite.z_index = 10
		parent.add_child(sprite)
		placed += 1
	return placed
