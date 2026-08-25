class_name WindBlast
extends Node2D

## LE GRAND SOUFFLE : le cône devant lui, l'onde autour de lui.
##
## Deux animations dessinées jouées ensemble, et chacune dit une moitié du sort.
## Le CÔNE part droit devant le mage — c'est le geste, la direction qu'il donne
## à son souffle. L'ONDE reste centrée sur lui — c'est la portée réelle, qui est
## radiale : tout ce qui l'entoure est projeté, pas seulement ce qui est devant.
##
## Le cône est ORIENTÉ par la direction du regard ; l'onde ne pivote JAMAIS.
## Une onde qui tourne se lit comme une roue posée sur le sol, et l'ancienne
## version faisait pire — elle plantait une tornade tournoyante au centre du
## mage, là où le sort chasse vers l'extérieur.

## Le cône est dessiné pointe à GAUCHE, ouvert vers la droite : sa pointe se
## pose sur le mage et le reste part dans la direction visée.
const LIFE := 0.55

var tile_size: int = 32

var _time := 0.0
var _cone: Sprite2D = null
var _burst: Sprite2D = null
var _cone_frames: Array[Texture2D] = []
var _burst_frames: Array[Texture2D] = []


func setup(p_tile_size: int, radius: float, facing: Vector2i,
		cone_frames: Array, burst_frames: Array) -> void:
	tile_size = p_tile_size
	z_index = 13
	# ADDITIF. Le dessin est un blanc bleuté très clair : posé tel quel sur
	# l'herbe du labyrinthe, il se délave et ne se voit plus. En additif il
	# ÉCLAIRE ce qu'il couvre, ce qui est d'ailleurs ce que fait une bourrasque
	# de lumière — et c'est le même choix que pour le feu et la foudre.
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material
	# L'additif d'un dessin déjà blanc SATURE : à pleine opacité, le souffle
	# devenait une tache blanche où l'on ne distinguait plus ni les volutes ni
	# le mage. On le laisse respirer.
	modulate = Color(1, 1, 1, 0.72)
	for frame in cone_frames:
		if frame != null:
			_cone_frames.append(frame)
	for frame in burst_frames:
		if frame != null:
			_burst_frames.append(frame)

	if not _burst_frames.is_empty():
		_burst = Sprite2D.new()
		_burst.texture = _burst_frames[0]
		# L'onde couvre la portée du sort — mesuré en capture : à deux fois le
		# rayon elle avalait le quart de l'écran, et le joueur ne voyait plus
		# le labyrinthe qu'elle est censée lui faire lire.
		var wide := (tile_size * radius * 1.4) / float(_burst_frames[0].get_width())
		_burst.scale = Vector2(wide, wide)
		add_child(_burst)

	if not _cone_frames.is_empty():
		_cone = Sprite2D.new()
		_cone.texture = _cone_frames[0]
		# Pointe sur le mage : on décentre le sprite pour que son bord GAUCHE
		# tombe sur l'origine, puis on le tourne vers la direction visée.
		_cone.centered = false
		_cone.offset = Vector2(0.0, -float(_cone_frames[0].get_height()) * 0.5)
		var span := (tile_size * radius * 0.95) / float(_cone_frames[0].get_width())
		_cone.scale = Vector2(span, span)
		_cone.rotation = Vector2(facing).angle() if facing != Vector2i.ZERO else 0.0
		add_child(_cone)


func _process(delta: float) -> void:
	_time += delta
	if _time >= LIFE:
		queue_free()
		return
	var t := _time / LIFE
	if _cone != null:
		_cone.texture = _cone_frames[mini(int(t * float(_cone_frames.size())),
			_cone_frames.size() - 1)]
	if _burst != null:
		# L'onde part une fraction APRÈS le cône : le souffle sort d'abord de
		# ses mains, la déflagration suit. Jouées ensemble, les deux se
		# confondent en une seule tache.
		var late := clampf((t - 0.12) / 0.88, 0.0, 1.0)
		_burst.texture = _burst_frames[mini(int(late * float(_burst_frames.size())),
			_burst_frames.size() - 1)]
		_burst.modulate = Color(1, 1, 1, 1.0 if late > 0.0 else 0.0)
