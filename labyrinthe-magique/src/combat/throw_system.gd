class_name ThrowSystem
extends RefCounted

## LES ENNEMIS QUI FRAPPENT DE LOIN.
##
## Un seul le fait aujourd'hui — le Golem de Lave et sa boule — mais la règle est
## écrite pour l'espèce, pas pour lui : toute créature dont le bestiaire déclare
## un `throw_range` tire ici.
##
## POURQUOI CE FICHIER EXISTE, ET POURQUOI IL N'EST PAS UN NŒUD
##
## Le jet a d'abord été écrit dans `Level`. Ça marchait à l'écran, et c'était
## faux : `Level` est un nœud de scène, que `tests/test_balance.gd` n'instancie
## pas. La simulation d'équilibrage n'applique de dégâts qu'au CONTACT — elle
## aurait donc mesuré, une heure durant, un jeu où le golem ne jette jamais, et
## rendu un verdict rassurant sur une menace qu'elle n'a pas vue.
##
## Décider qui est touché est une règle de JEU. Elle vit donc ici, en RefCounted,
## comme `CombatSystem` et `MazeGrid` : le Level l'appelle pour dessiner, le test
## l'appelle pour mesurer, et les deux jouent exactement le même jeu.
##
## CE QUE LA RÈGLE DIT
##
##   · EN LIGNE DROITE SEULEMENT, et sans traverser une haie. Une boule qui
##     passerait les murs ferait du stage du Golem un couloir de tir permanent,
##     sans rien à faire pour s'en protéger. Là, il suffit de sortir de l'axe —
##     et c'est un geste qu'on comprend du premier coup.
##
##   · DEUX FAÇONS DE FRAPPER. La BOULE vise une case et y tombe ; la RAFALE
##     balaie tout le couloir devant le tireur, case par case, la plus proche
##     d'abord. Reculer ne sauve pas d'une rafale — il faut sortir de l'axe,
##     comme pour la boule. C'est la même leçon, apprise deux fois.
##
##   · ELLE VISE OÙ LE MAGE EST, jamais où il sera. La boule est donc esquivable,
##     et l'esquive est le seul geste que ce monstre demande d'apprendre. Une
##     boule qui suit sa cible ne serait pas une menace mais une taxe.
##
##   · UN POINT DE VIE, comme tout le reste du jeu. Le contact coûte un point
##     quelle que soit l'espèce ; un jet ne peut pas coûter plus cher sans faire
##     mentir la seule règle de dégâts que le joueur ait apprise.

## Cases par seconde de la boule.
##
## DIX, et non cinq. À cinq, elle volait EXACTEMENT à la vitesse du mage — qui
## fait 4,5 à 5,1 cases par seconde selon le personnage. Visée là où il était,
## elle ne pouvait donc jamais rattraper quelqu'un qui court : la simulation
## d'équilibrage a rendu des chiffres identiques au chiffre près avec et sans le
## jet, parce que son bot, qui ne s'arrête jamais, ne s'est pas fait toucher une
## seule fois de toute la campagne. Une menace qu'on esquive en marchant tout
## droit n'est pas une menace.
##
## À dix, elle va deux fois plus vite que lui : rester en place ou hésiter coûte
## un point de vie, un pas de côté au bon moment sauve. C'est le geste qu'on
## voulait lui faire apprendre. Elle reste sous les quinze cases par seconde
## d'un projectile ordinaire du jeu — on doit la VOIR venir.
const SPEED_TILES := 10.0
const MIN_FLIGHT := 0.28
## Rayon d'impact, en cases. Un peu moins d'une : le mage qui a bougé d'une case
## est sauf, celui qui n'a pas réagi est touché. C'est cette marge qui rend
## l'esquive lisible — trop large, l'esquive devient un pari.
const HIT_RADIUS := 0.85

var grid: MazeGrid

## Boules en vol : {cell, time_left}.
var _flying: Array[Dictionary] = []
## Rechargement par tireur, indexé comme le tableau qu'on nous passe.
var _reload := {}


func _init(p_grid: MazeGrid) -> void:
	grid = p_grid


## Un tour de jeu. `shooters` décrit les créatures capables de lancer :
##     {"cell": Vector2i, "range": int, "reload": float}
## `range` à zéro = frappe au contact, on l'ignore.
##
## Renvoie les jets OUVERTS ce tour-ci — {from, to, flight} — pour que l'appelant
## qui a un écran puisse les dessiner. Celui qui n'en a pas les jette.
func aim(delta: float, shooters: Array, player_cell: Vector2i) -> Array:
	var opened: Array = []
	for index in shooters.size():
		var shooter: Dictionary = shooters[index]
		var reach := int(shooter.get("range", 0))
		var left := float(_reload.get(index, 0.0)) - delta
		if reach <= 0:
			continue
		if left > 0.0:
			_reload[index] = left
			continue
		var from: Vector2i = shooter["cell"]
		if not has_shot(from, player_cell, reach):
			_reload[index] = 0.0
			continue
		if bool(shooter.get("sweep", false)):
			# LA RAFALE. Elle ne vise pas une case mais BALAIE le couloir devant
			# lui, case par case, la plus proche d'abord.
			#
			# Chaque case est un projectile à part, avec son propre instant
			# d'arrivée : la vague avance donc toute seule, et celui qui se
			# trouve au bout du couloir a le temps de s'écarter pendant qu'elle
			# vient. C'est ce qui la sépare d'un dégât de zone, qui tomberait
			# partout en même temps et ne laisserait rien à faire.
			var step := Vector2i(signi(player_cell.x - from.x),
				signi(player_cell.y - from.y))
			var walk := from + step
			var swept: Array[Vector2i] = []
			for i in reach:
				if not grid.is_floor_v(walk):
					break
				_flying.append({"cell": walk,
					"time_left": MIN_FLIGHT + float(i) / SPEED_TILES})
				swept.append(walk)
				walk += step
			opened.append({"from": from, "sweep": true, "cells": swept})
			_reload[index] = maxf(0.05, float(shooter.get("reload", 1.0)))
			continue
		var flight := maxf(MIN_FLIGHT,
			(Vector2(player_cell - from).length()) / SPEED_TILES)
		_flying.append({"cell": player_cell, "time_left": flight})
		opened.append({"from": from, "to": player_cell, "flight": flight})
		_reload[index] = maxf(0.05, float(shooter.get("reload", 1.0)))
	return opened


## Avance les boules. Renvoie les cases où l'une vient de tomber.
func advance(delta: float) -> Array[Vector2i]:
	var landed: Array[Vector2i] = []
	for i in range(_flying.size() - 1, -1, -1):
		_flying[i]["time_left"] = float(_flying[i]["time_left"]) - delta
		if float(_flying[i]["time_left"]) > 0.0:
			continue
		landed.append(_flying[i]["cell"])
		_flying.remove_at(i)
	return landed


## Le mage est-il dans le souffle d'une boule tombée sur `cell` ?
static func touches(cell: Vector2i, player_position: Vector2) -> bool:
	return player_position.distance_to(Vector2(cell)) < HIT_RADIUS


## Y a-t-il un couloir DROIT et dégagé entre les deux cases, à portée ?
func has_shot(from: Vector2i, to: Vector2i, reach: int) -> bool:
	if from == to:
		return false
	var step := Vector2i(signi(to.x - from.x), signi(to.y - from.y))
	# Ni même ligne ni même colonne : pas de tir. La diagonale est exclue
	# volontairement — dans un labyrinthe à couloirs orthogonaux, elle ne
	# correspond à aucun chemin que le joueur puisse lire.
	if step.x != 0 and step.y != 0:
		return false
	var walk := from + step
	for i in reach:
		if not grid.is_floor_v(walk):
			return false
		if walk == to:
			return true
		walk += step
	return false
