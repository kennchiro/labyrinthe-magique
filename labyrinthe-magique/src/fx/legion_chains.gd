class_name LegionChains
extends Node2D

## LES CHAÎNES DE LA LÉGION (l'Éveil de l'Invocateur) : une chaîne de lumière violette relie le mage à
## chacune de ses créatures éveillées, au sol. Une lueur la parcourt sans cesse, et une étincelle dorée
## remonte jusqu'à lui quand la créature frappe.
##
## Le nœud vit dans `Entities` mais dessine en positions du sol : le `Level` remet son échelle à un après
## l'avoir ajouté, sinon le redressement de `WorldStage` étirerait tout vers le sud.

const LINK_GAP := 0.24          # en cases, entre deux maillons
const LINK_SIZE := 0.075        # rayon d'un maillon, en cases
const SAG := 0.18               # la chaîne pend un peu, en cases
const SPARK_TIME := 0.45
const VIOLET := Color("#c77dff")
const DEEP := Color("#2e1450")
const GOLD := Color("#d4a640")

var tile_size := 32
var _mage: Node2D = null
var _ends: Array[Node2D] = []
var _sparks := []               # {node, left}
var _time := 0.0
var _fade := 0.0


func setup(mage: Node2D, p_tile_size: int) -> void:
	_mage = mage
	tile_size = p_tile_size
	z_index = 3


func attach(node: Node2D) -> void:
	if node != null and not _ends.has(node):
		_ends.append(node)


func detach(node: Node2D) -> void:
	_ends.erase(node)


## L'étincelle de commandement : elle remonte la chaîne de la créature jusqu'au mage.
func spark(node: Node2D) -> void:
	if _ends.has(node):
		_sparks.append({"node": node, "left": SPARK_TIME})


func _process(delta: float) -> void:
	_time += delta
	_fade = minf(1.0, _fade + delta * 3.0)
	for i in range(_ends.size() - 1, -1, -1):
		if not is_instance_valid(_ends[i]):
			_ends.remove_at(i)
	for i in range(_sparks.size() - 1, -1, -1):
		_sparks[i]["left"] = float(_sparks[i]["left"]) - delta
		if float(_sparks[i]["left"]) <= 0.0 or not is_instance_valid(_sparks[i]["node"]):
			_sparks.remove_at(i)
	queue_redraw()


func _point(a: Vector2, b: Vector2, k: float) -> Vector2:
	return a.lerp(b, k) + Vector2(0.0, sin(k * PI) * SAG * float(tile_size))


func _draw() -> void:
	if _mage == null or not is_instance_valid(_mage):
		return
	var from := _mage.position
	var tile := float(tile_size)
	for node in _ends:
		var to := node.position
		var length := from.distance_to(to)
		if length < tile * 0.6:
			continue
		var count := maxi(2, int(length / (LINK_GAP * tile)))
		var previous := _point(from, to, 0.0)
		for i in range(1, count + 1):
			var k := float(i) / float(count)
			var at := _point(from, to, k)
			draw_line(previous, at, Color(VIOLET.r, VIOLET.g, VIOLET.b, 0.22 * _fade), tile * 0.16)
			previous = at
		# Les maillons, et la lueur qui court de la créature vers le mage.
		var glow := fmod(_time * 0.8, 1.0)
		for i in count:
			var k := (float(i) + 0.5) / float(count)
			var at := _point(from, to, k)
			var lit := clampf(1.0 - absf((1.0 - k) - glow) * 6.0, 0.0, 1.0)
			var color := DEEP.lerp(VIOLET, 0.55 + 0.45 * lit)
			color.a = _fade
			draw_arc(at, LINK_SIZE * tile, 0.0, TAU, 10, Color(0.04, 0.02, 0.07, _fade), 3.2)
			draw_arc(at, LINK_SIZE * tile, 0.0, TAU, 10, color, 1.8)
	for spark in _sparks:
		var node: Node2D = spark["node"]
		var k := 1.0 - float(spark["left"]) / SPARK_TIME
		var at := _point(from, node.position, 1.0 - k)
		draw_circle(at, tile * 0.16, Color(GOLD.r, GOLD.g, GOLD.b, 0.45))
		draw_circle(at, tile * 0.08, Color(1.0, 0.95, 0.8, 1.0))
