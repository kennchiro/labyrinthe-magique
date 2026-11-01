class_name PaintedFx
extends RefCounted

## LE REGISTRE DES EFFETS PEINTS AU SHADER, tous mages confondus.
##
## ⚠️ La règle : un dessin par sort, tiré de ce que le sort FAIT. Le partage d'une clé
## entre deux sorts, c'est le défaut que `test_animation` refuse : une palette fait une
## teinte, pas un mage. Les planches ne sont plus lues : elles restent chargées par les
## nœuds, qui en ont besoin pour exister, mais `cover` les rend invisibles.

const NOISE := preload("res://assets/shaders/fire_noise.png")

const SHADERS := {
	"fire_burst": preload("res://assets/shaders/fire_burst.gdshader"),
	"shadow_collapse": preload("res://assets/shaders/shadow_collapse.gdshader"),
	"arcane_sigil": preload("res://assets/shaders/arcane_sigil.gdshader"),
	"water_splash": preload("res://assets/shaders/water_splash.gdshader"),
	"water_swirl": preload("res://assets/shaders/water_swirl.gdshader"),
	"water_geyser": preload("res://assets/shaders/water_geyser.gdshader"),
	"water_bubble": preload("res://assets/shaders/water_bubble.gdshader"),
	"thunder_star": preload("res://assets/shaders/thunder_star.gdshader"),
	"thunder_strike": preload("res://assets/shaders/thunder_strike.gdshader"),
	"thunder_cloud": preload("res://assets/shaders/thunder_cloud.gdshader"),
	"thunder_crest": preload("res://assets/shaders/thunder_crest.gdshader"),
	"air_slash": preload("res://assets/shaders/air_slash.gdshader"),
	"air_streaks": preload("res://assets/shaders/air_streaks.gdshader"),
	"air_gust": preload("res://assets/shaders/air_gust.gdshader"),
	"air_veil": preload("res://assets/shaders/air_veil.gdshader"),
	"earth_crack": preload("res://assets/shaders/earth_crack.gdshader"),
	"earth_fissure": preload("res://assets/shaders/earth_fissure.gdshader"),
	"earth_quake": preload("res://assets/shaders/earth_quake.gdshader"),
	"rebirth_aura": preload("res://assets/shaders/rebirth_aura.gdshader"),
	"seal_flame": preload("res://assets/shaders/seal_flame.gdshader"),
	"prism_star": preload("res://assets/shaders/prism_star.gdshader"),
	"prism_shift": preload("res://assets/shaders/prism_shift.gdshader"),
	"convergence_burst": preload("res://assets/shaders/convergence_burst.gdshader"),
	"judgement_burst": preload("res://assets/shaders/judgement_burst.gdshader"),
	"chrono_tick": preload("res://assets/shaders/chrono_tick.gdshader"),
	"chrono_rewind": preload("res://assets/shaders/chrono_rewind.gdshader"),
	"chrono_sand": preload("res://assets/shaders/chrono_sand.gdshader"),
	"chrono_stop": preload("res://assets/shaders/chrono_stop.gdshader"),
}

## L'éclat au toucher, et la fuite, de chaque mage.
const IMPACT := {
	"fire": "fire_burst", "shadow": "shadow_collapse", "invocateur": "arcane_sigil",
	"water": "water_splash", "thunder": "thunder_star", "air": "air_slash",
	"earth": "earth_crack", "supreme": "prism_star", "chrono": "chrono_tick",
}
const ESCAPE := {
	"invocateur": "arcane_sigil", "water": "water_swirl", "thunder": "thunder_strike",
	"air": "air_streaks", "earth": "earth_fissure", "supreme": "prism_shift",
	"chrono": "chrono_rewind",
}
## La couleur de la flamme de chaque sceau du Suprême. Tout autre élément prend l'air.
const SEAL_KINDS := {
	Element.Kind.FIRE: 0, Element.Kind.WATER: 1, Element.Kind.EARTH: 2, Element.Kind.AIR: 3,
}
## Les autres effets de chaque mage, à compiler avec le niveau.
const EXTRAS := {
	"water": ["water_geyser", "water_bubble"],
	"thunder": ["thunder_cloud", "thunder_crest"],
	"air": ["air_gust", "air_veil"],
	"earth": ["earth_quake"],
	"supreme": ["rebirth_aura", "seal_flame", "convergence_burst", "judgement_burst"],
	"chrono": ["chrono_sand", "chrono_stop"],
}


static func make_material(key: String, seed_value: float = 0.0) -> ShaderMaterial:
	var shaded := ShaderMaterial.new()
	shaded.shader = SHADERS[key]
	shaded.set_shader_parameter("noise", NOISE)
	shaded.set_shader_parameter("seed", seed_value)
	return shaded


## Les matériaux d'un mage, pour les compiler avant le premier sort.
static func materials_of(mage: String) -> Array[ShaderMaterial]:
	var out: Array[ShaderMaterial] = []
	var keys: Array = [IMPACT.get(mage, "fire_burst")]
	if ESCAPE.has(mage):
		keys.append(ESCAPE[mage])
	keys.append_array(EXTRAS.get(mage, []))
	for key: String in keys:
		out.append(make_material(key))
	return out


## Remplace le dessin d'un nœud d'effet par un shader, sans toucher à sa logique.
##
## `self_modulate` éteint ses images et son `_draw` sans éteindre ses enfants : ses
## particules continuent, et le fondu que le nœud s'applique touche aussi le dessin.
static func cover(node: Node2D, key: String, size: Vector2,
		offset: Vector2 = Vector2.ZERO) -> Sprite2D:
	node.self_modulate.a = 0.0
	for child in node.get_children():
		if child is Sprite2D:
			(child as Sprite2D).self_modulate.a = 0.0
	return add(node, key, size, offset)


## Pose un shader SUR le dessin d'un nœud, sans rien lui retirer.
static func add(node: Node2D, key: String, size: Vector2,
		offset: Vector2 = Vector2.ZERO) -> Sprite2D:
	var quad := Sprite2D.new()
	quad.texture = MagicOrb.painted_quad()
	quad.material = make_material(key, float(Time.get_ticks_usec() % 1000) * 0.001)
	quad.scale = size
	quad.position = offset
	node.add_child(quad)
	return quad
