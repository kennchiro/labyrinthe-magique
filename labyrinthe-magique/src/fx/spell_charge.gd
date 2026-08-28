class_name SpellCharge
extends Node2D

## L'INCANTATION : la bande d'images que le mage joue avant que son sort ne
## prenne effet. Une seule passe, puis le nœud disparaît.
##
## POURQUOI CE NŒUD EXISTE
##
## Convergence élémentaire porte sa charge DANS son projectile : l'orbe reste au
## point de départ le temps de se former, puis part. Ça marche parce qu'il y a un
## projectile à retenir.
##
## Les Quatre Sceaux n'en ont pas. Ses quatre zones prennent effet à l'instant
## où elles sont posées — c'est le CombatSystem qui en décide, et on ne touche
## pas à son horloge pour une raison d'affichage. La charge se joue donc À CÔTÉ,
## sur le mage, pendant que les sceaux se gravent : elle raconte d'où ils
## viennent sans rien retarder.
##
## Elle ne fait AUCUN dégât et ne décide de rien. Si elle disparaît, le sort
## fonctionne exactement pareil.

## Hauteur de la charge à l'écran, en cases.
##
## 4,5 et non 2,8 : à 2,8 elle passait inaperçue. Ses premières images sont
## quatre étincelles minuscules, et l'anneau n'arrive qu'à la moitié de la
## seconde — un effet discret ET bref ne se voit pas du tout. À 4,5 elle couvre
## le carrefour que les sceaux vont garder, ce qui est exactement ce qu'elle
## raconte. Vérifié en poussant à 9 : au-delà, elle mange l'écran et on ne voit
## plus le mage qui l'incante.
const HEIGHT_TILES := 4.5
## Hauteur effective, fixée au lancement : tous les sorts ne pèsent pas pareil.
## Les Quatre Sceaux gardent 4,5 cases ; le Jugement, qui est un ultime et ouvre
## le ciel, en prend sept. Une constante unique donnait soit une incantation
## d'ultime trop discrète, soit un sort courant qui mangeait l'écran.
var height_tiles := HEIGHT_TILES
## Elle se joue AU-DESSUS du mage, pas sur ses pieds — sinon l'anneau lui coupe
## la tête et on ne voit plus lequel des huit mages incante.
const LIFT_TILES := 0.55

var _sprite: Sprite2D = null
var _frames := 1
var _fps := 8.0
var _elapsed := 0.0


func setup(strip: Texture2D, frames: int, fps: float, tile_size: int,
		p_height_tiles: float = HEIGHT_TILES) -> void:
	height_tiles = maxf(1.0, p_height_tiles)
	_frames = maxi(1, frames)
	_fps = maxf(1.0, fps)
	_sprite = Sprite2D.new()
	_sprite.texture = strip
	_sprite.hframes = _frames
	_sprite.vframes = 1
	add_child(_sprite)
	var cell := Vector2(strip.get_size()) / Vector2(float(_frames), 1.0)
	var factor := (float(tile_size) * height_tiles) / maxf(1.0, cell.y)
	_sprite.scale = Vector2(factor, factor)
	_sprite.position = Vector2(0.0, -float(tile_size) * LIFT_TILES)
	# COMPOSITION NORMALE, et pas additive. L'additif semblait évident — la
	# charge est faite de lumière — mais il AJOUTE au fond au lieu de le
	# couvrir : sur l'herbe claire de la Forêt, les quatre traînées élémentaires
	# devenaient un voile blanchâtre qu'on ne voyait pas. C'est le même défaut,
	# et le même remède, que pour le sceau posé au sol.


func _process(delta: float) -> void:
	if _sprite == null:
		return
	_elapsed += delta
	var index := int(_elapsed * _fps)
	if index >= _frames:
		# UNE SEULE PASSE. Rejouée en boucle, la charge continuerait de tourner
		# devant le mage pendant les sept secondes des sceaux : on ne saurait
		# plus si le sort est en train d'être lancé ou déjà posé.
		queue_free()
		return
	_sprite.frame = index
	# Elle s'efface sur sa dernière image plutôt que de disparaître d'un coup :
	# l'anneau se dissout dans les sceaux qu'il vient de graver.
	var fade := 1.0 - clampf(
		(_elapsed - float(_frames - 1) / _fps) * _fps, 0.0, 1.0)
	_sprite.modulate = Color(1.0, 1.0, 1.0, fade)
