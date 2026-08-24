class_name Screenshot
extends RefCounted

## Capture d'écran en ligne de commande, partagée par le jeu ET les menus.
##
## Elle vivait dans DevTools, qui n'existe qu'à l'intérieur d'une partie : dès
## qu'un écran-titre est arrivé devant, `--screenshot` ne répondait plus et le
## processus tournait sans fin. Une capture doit marcher sur n'importe quel
## écran, sinon la vérification visuelle a des angles morts.

## `--frames N` laisse tourner N images avant la capture : indispensable pour
## photographier une animation en cours plutôt qu'un premier rendu figé.
static func requested(args: PackedStringArray) -> bool:
	return "--screenshot" in args


static func frames(args: PackedStringArray) -> int:
	var index := args.find("--frames")
	if index >= 0 and index + 1 < args.size():
		return maxi(2, int(args[index + 1]))
	return 2


static func path(args: PackedStringArray) -> String:
	var index := args.find("--screenshot")
	if index >= 0 and index + 1 < args.size():
		return args[index + 1]
	return "user://screenshot.png"


static func save(node: Node, args: PackedStringArray) -> void:
	var image := node.get_viewport().get_texture().get_image()
	var target := path(args)
	image.save_png(target)
	print("screenshot -> ", ProjectSettings.globalize_path(target))
