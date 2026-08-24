class_name Platform
extends RefCounted

## Détection de l'interface tactile, en UN seul endroit.
##
## Trois écrans en avaient besoin (le manche directionnel, la barre de combat,
## les menus) et chacun avait sa propre version. Une règle dupliquée trois fois
## est une règle qui finit par diverger — et ici la divergence donne un jeu
## injouable au doigt sur une moitié des écrans.

## Taille visée d'une touche tactile, en POINTS (l'unité
## d'Apple, indépendante de la densité de l'écran). Apple demande 44 points
## minimum pour une cible tactile ; 62 laisse de la marge pour un pouce en
## mouvement, ce qui est le cas ici — on ne vise pas, on court.
const TARGET_KEY_POINTS := 62.0
## Module de la mise en page tactile : côté nominal d'une touche, et rayon du
## manche directionnel (TouchStick.radius), qui fait donc deux touches de large.
const KEY_SIZE := 96.0
## Base de conception de l'interface.
const DESIGN_SIZE := Vector2(1280.0, 720.0)


static func touch_ui() -> bool:
	if "--touch" in OS.get_cmdline_user_args():
		return true
	if OS.has_feature("mobile"):
		return true
	# Attention : is_touchscreen_available() renvoie true sur desktop dès que
	# emulate_touch_from_mouse est activé. On ne s'y fie donc que sur le Web.
	return OS.has_feature("web") and DisplayServer.is_touchscreen_available()


## Grossissement de l'interface sur écran tactile, CALCULÉ et non constant.
##
## Une constante ne peut pas marcher : le mode d'étirement `canvas_items` réduit
## la mise en page de ~58 % sur un iPhone en portrait, mais de ~163 % en
## paysage. Le facteur 2,4 qui donnait de bonnes touches en portrait produisait
## en paysage un bandeau occupant la moitié de l'écran.
##
## On part donc de l'inverse : quelle taille PHYSIQUE doit faire une touche, et
## quel facteur y mène sur cet écran-ci.
##
## À appeler une fois au démarrage. Idempotent : deux appels ne cumulent pas.
static func apply_ui_scale(window: Window) -> void:
	if not touch_ui():
		return
	var size := Vector2(window.size)
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var stretch: float = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var density: float = maxf(1.0, DisplayServer.screen_get_scale())
	# 96 px de mise en page x étirement x facteur / densité = points visés.
	var factor := TARGET_KEY_POINTS * density / (KEY_SIZE * maxf(0.01, stretch))
	window.content_scale_factor = clampf(factor, 0.9, 3.0)
