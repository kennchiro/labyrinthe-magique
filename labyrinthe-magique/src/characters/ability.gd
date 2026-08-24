class_name Ability
extends Resource

## Une compétence : attaque de base, sort, ou ultime.
##
## Tout est DONNÉE. Aucune compétence n'a de code à elle : c'est le CombatSystem
## qui sait exécuter chacune des sept formes ci-dessous. Ajouter un sort revient
## donc à écrire une ligne dans le catalogue, jamais une nouvelle classe — c'est
## ce qui rend cinq personnages réellement différents tenables.

enum Kind {
	PROJECTILE,   ## part vers une cible et lui fait des dégâts à l'impact
	BLAST,        ## explosion immédiate autour du lanceur ou d'un point
	ZONE,         ## surface qui blesse tant qu'on y reste (durée)
	SHIELD,       ## absorbe des dégâts pendant une durée
	HEAL,         ## rend des points de vie
	WALL,         ## bloque un couloir pendant une durée
	BLINK,        ## déplacement instantané
	SUMMON,       ## invoque des créatures qui chassent les ennemis (durée)
}

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var kind: Kind = Kind.PROJECTILE
@export var element: Element.Kind = Element.Kind.SHADOW

## Dégâts au centre de l'effet. Une ZONE les inflige PAR SECONDE, les autres en
## une fois — la distinction est portée par `kind`, pas par un second champ.
@export var damage: int = 0
## Rayon d'effet, en cases. 0 = cible unique.
@export var radius: float = 0.0
## Portée maximale, en distance de CHEMIN (les couloirs, pas le vol d'oiseau).
@export var range: int = 0
@export var cooldown: float = 1.0
## Durée pour ZONE, SHIELD, WALL et SUMMON. Ignorée par les autres.
@export var duration: float = 0.0
@export var is_ultimate: bool = false
## SUMMON : quelle créature (voir CombatSystem.SUMMON_KINDS), et combien.
@export var summon_id: String = ""
@export var summon_count: int = 1


## Fabrique lisible : `Ability.make({"id": "fireball", "damage": 30, …})`.
## Un _init à douze paramètres positionnels serait illisible au point d'être
## dangereux — une valeur décalée d'un cran passerait inaperçue.
static func make(values: Dictionary) -> Ability:
	var ability := Ability.new()
	for key in values:
		ability.set(key, values[key])
	return ability


## Texte court affiché sous l'icône dans l'écran de sélection.
func summary() -> String:
	match kind:
		Kind.PROJECTILE:
			return "%d dégâts · portée %d" % [damage, range]
		Kind.BLAST:
			return "%d dégâts · rayon %.1f" % [damage, radius]
		Kind.ZONE:
			return "%d dégâts/s · rayon %.1f · %.0f s" % [damage, radius, duration]
		Kind.SHIELD:
			return "absorbe %d · %.0f s" % [damage, duration]
		Kind.HEAL:
			return "rend %d PV" % damage
		Kind.WALL:
			return "bloque %.0f s" % duration
		Kind.BLINK:
			return "saut de %d cases" % range
		Kind.SUMMON:
			return "%d créature(s) · %.0f s" % [summon_count, duration]
	return ""
