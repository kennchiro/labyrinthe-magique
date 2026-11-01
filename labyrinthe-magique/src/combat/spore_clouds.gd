class_name SporeClouds
extends RefCounted

## Les nuages de la Vesse-de-Loup. Ils ne font aucun dégât : ils ralentissent le mage tant
## qu'il est dedans, et le poursuivant qui le suit fait le reste.
##
## Pas un nœud, pour que la simulation d'équilibrage joue la même règle que le jeu : voir
## `ThrowSystem`, qui explique ce que coûte l'oubli.

const DURATION := 5.0
const SPEED_FACTOR := 0.65

var _waiting: Array[Dictionary] = []
## Case -> temps restant. Un second nuage sur la même case la remet à neuf sans cumuler.
var _lying := {}


## Le crachat part à l'armement et n'est un nuage qu'à l'impact : le joueur a le temps de
## voir gonfler la Vesse et de passer avant.
func spit(cells: Array[Vector2i], delay: float) -> void:
	_waiting.append({"cells": cells, "left": delay})


## Avance le temps et rend les cases qui viennent de recevoir leur nuage, pour les dessiner.
func advance(delta: float) -> Array[Vector2i]:
	for cell in _lying.keys():
		var left: float = _lying[cell] - delta
		if left <= 0.0:
			_lying.erase(cell)
		else:
			_lying[cell] = left
	var landed: Array[Vector2i] = []
	for i in range(_waiting.size() - 1, -1, -1):
		_waiting[i]["left"] = float(_waiting[i]["left"]) - delta
		if float(_waiting[i]["left"]) > 0.0:
			continue
		for cell: Vector2i in _waiting[i]["cells"]:
			_lying[cell] = DURATION
			landed.append(cell)
		_waiting.remove_at(i)
	return landed


func speed_factor(cell: Vector2i) -> float:
	return SPEED_FACTOR if _lying.has(cell) else 1.0
