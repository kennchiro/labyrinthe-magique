class_name PlagueCrows
extends Node2D

## LES CORBEAUX DE PESTE (l'Éveil du Mage de la Peste, le Seigneur du Fléau). Deux usages :
## - la RONDE : `orbiting` corbeaux tournent au-dessus du mage pendant l'Éveil, leur ombre au sol ;
## - la VOLÉE : `flock(a, b)` lance une nuée qui file d'un point à l'autre (la Nuée de corbeaux).
##
## Les corbeaux viennent de la bande vue de DESSUS (`tools/build_corbeau.py`), tête en haut : chacun est tourné
## dans le sens de son vol. Le nœud vit dans `Entities` mais dessine en positions du monde : le `Level` remet son
## échelle à un après l'avoir ajouté, sinon le redressement de `WorldStage` étirerait tout vers le sud.

const TOP := preload("res://assets/allies/peste_corbeau_top.png")
const FRAMES := 8
const FPS := 14.0
const ORBIT := Vector2(0.95, 0.42)      # rayons de la ronde, en cases
const LIFT := 1.3                       # hauteur de la ronde au-dessus de ses pieds, en cases
const SPAN := 0.85                      # envergure d'un corbeau, en cases (à 0,62 on ne les voyait pas)
const TURN := 2.2                       # radians par seconde
const LEAVE_TIME := 0.9
const FLOCK_TIME := 0.5

var tile_size := 32
var _mage: Node2D = null
var _orbiting := 0
var _time := 0.0
var _leaving := -1.0
var _flights: Array[Dictionary] = []    # {from, to, delay, left, side}


func setup(mage: Node2D, p_tile_size: int, orbiting: int) -> void:
	_mage = mage
	tile_size = p_tile_size
	_orbiting = orbiting
	z_index = 12


## La volée : `count` corbeaux filent de `a` à `b`, en éventail, chacun un peu après l'autre.
func flock(a: Vector2, b: Vector2, count: int = 9) -> void:
	for i in count:
		_flights.append({"from": a, "to": b, "delay": float(i) * 0.025,
			"left": FLOCK_TIME, "side": (float(i) / float(maxi(1, count - 1)) - 0.5) * 2.0})


## La ronde s'achève : les corbeaux s'envolent au loin, puis le nœud s'en va.
func dismiss() -> void:
	if _leaving < 0.0:
		_leaving = 0.0


func _process(delta: float) -> void:
	_time += delta
	if _leaving >= 0.0:
		_leaving += delta
	for i in range(_flights.size() - 1, -1, -1):
		var flight: Dictionary = _flights[i]
		if float(flight["delay"]) > 0.0:
			flight["delay"] = float(flight["delay"]) - delta
			continue
		flight["left"] = float(flight["left"]) - delta
		if float(flight["left"]) <= 0.0:
			_flights.remove_at(i)
	var orbit_done := _orbiting == 0 or (_leaving >= LEAVE_TIME) or _mage == null or not is_instance_valid(_mage)
	if orbit_done and _flights.is_empty():
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var tile := float(tile_size)
	var cell := float(TOP.get_height())
	var scale_value := SPAN * tile / cell
	var frame := int(_time * FPS) % FRAMES
	if _orbiting > 0 and _mage != null and is_instance_valid(_mage) and _leaving < LEAVE_TIME:
		var away := maxf(0.0, _leaving) / LEAVE_TIME
		for i in _orbiting:
			var angle := _time * TURN + float(i) * TAU / float(_orbiting)
			var ground := Vector2(cos(angle) * ORBIT.x, sin(angle) * ORBIT.y) * tile
			var tangent := Vector2(-sin(angle) * ORBIT.x, cos(angle) * ORBIT.y)
			var bob := sin(_time * 3.0 + float(i)) * 0.08 * tile
			var at := _mage.position + ground + Vector2(0.0, -LIFT * tile + bob)
			var heading := tangent.angle()
			if away > 0.0:
				# Ils quittent la ronde en ligne droite, vers le haut et au loin.
				var out := ground.normalized() + Vector2(0.0, -0.8)
				at += out * away * away * tile * 7.0
				heading = out.angle()
			var alpha := 1.0 - away
			draw_set_transform(_mage.position + ground, 0.0, Vector2(1.0, 0.45))
			draw_circle(Vector2.ZERO, tile * 0.16, Color(0.0, 0.02, 0.0, 0.28 * alpha))
			_draw_crow(at, heading, scale_value, (frame + i * 3) % FRAMES, alpha, cell)
	for flight in _flights:
		if float(flight["delay"]) > 0.0:
			continue
		var k := 1.0 - float(flight["left"]) / FLOCK_TIME
		var a: Vector2 = flight["from"]
		var b: Vector2 = flight["to"]
		var line := b - a
		var side := Vector2(-line.y, line.x).normalized() * float(flight["side"]) * tile * 0.9
		var at := a.lerp(b, k) + side * sin(k * PI) + Vector2(0.0, -tile * (0.6 + 0.9 * sin(k * PI)))
		_draw_crow(at, line.angle(), scale_value * 0.85, (frame + int(float(flight["side"]) * 5.0 + 8.0)) % FRAMES,
			1.0 - smoothstep(0.8, 1.0, k), cell)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Un corbeau de la bande vue de dessus : tête en haut sur la planche, tourné vers `heading`.
func _draw_crow(at: Vector2, heading: float, scale_value: float, frame: int, alpha: float, cell: float) -> void:
	draw_set_transform(at, heading + PI * 0.5, Vector2.ONE * scale_value)
	draw_texture_rect_region(TOP, Rect2(-cell * 0.5, -cell * 0.5, cell, cell),
		Rect2(float(frame) * cell, 0.0, cell, cell), Color(1.0, 1.0, 1.0, alpha))
