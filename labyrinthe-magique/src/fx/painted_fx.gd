class_name PaintedFx
extends RefCounted

## LE REGISTRE DES EFFETS PEINTS AU SHADER, tous mages confondus.
##
## ⚠️ La règle : un dessin par sort, tiré de ce que le sort FAIT. Le partage d'une clé
## entre deux sorts, c'est le défaut que `test_animation` refuse : une palette fait une
## teinte, pas un mage. Les planches ne sont plus lues : elles restent chargées par les
## nœuds, qui en ont besoin pour exister, mais `cover` les rend invisibles.

const NOISE := preload("res://assets/shaders/fire_noise.png")
## Un éclair lit des tracés et des veines, pas un bruit lissé (`tools/build_noise.py`).
const THUNDER_NOISE := preload("res://assets/shaders/thunder_noise.png")
## ⚠️ Essayé puis rendu au bruit commun : le dard, trop petit pour porter une fourche,
## et l'étoile, qui n'y gagnait rien. Seuls ces deux-là y trouvent un meilleur dessin.
## Le Suprême : chaque matière lit son canal (`shaders/elements.gdshaderinc`).
const SUPREME_NOISE := preload("res://assets/shaders/supreme_noise.png")
const NOISES := {
	"prism_star": SUPREME_NOISE, "prism_shift": SUPREME_NOISE, "rebirth_aura": SUPREME_NOISE,
	"convergence_burst": SUPREME_NOISE, "judgement_burst": SUPREME_NOISE,
	"thunder_strike": THUNDER_NOISE, "thunder_cloud": THUNDER_NOISE,
	"thunder_storm": THUNDER_NOISE, "thunder_crest": THUNDER_NOISE,
}

const SHADERS := {
	"fire_burst": preload("res://assets/shaders/fire_burst.gdshader"),
	"shadow_collapse": preload("res://assets/shaders/shadow_collapse.gdshader"),
	"arcane_sigil": preload("res://assets/shaders/arcane_sigil.gdshader"),
	"arcane_void_step": preload("res://assets/shaders/arcane_void_step.gdshader"),
	"water_splash": preload("res://assets/shaders/water_splash.gdshader"),
	"water_swirl": preload("res://assets/shaders/water_swirl.gdshader"),
	"water_geyser": preload("res://assets/shaders/water_geyser.gdshader"),
	"water_bubble": preload("res://assets/shaders/water_bubble.gdshader"),
	"thunder_star": preload("res://assets/shaders/thunder_star.gdshader"),
	"thunder_strike": preload("res://assets/shaders/thunder_strike.gdshader"),
	"thunder_cloud": preload("res://assets/shaders/thunder_cloud.gdshader"),
	"thunder_storm": preload("res://assets/shaders/thunder_storm.gdshader"),
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
	"peste_splash": preload("res://assets/shaders/peste_splash.gdshader"),
	"peste_mist": preload("res://assets/shaders/peste_mist.gdshader"),
	"peste_puddle": preload("res://assets/shaders/peste_puddle.gdshader"),
	"peste_heal": preload("res://assets/shaders/peste_heal.gdshader"),
	"peste_wave": preload("res://assets/shaders/peste_wave.gdshader"),
	"peste_dissolve": preload("res://assets/shaders/peste_dissolve.gdshader"),
	"lumiere_star": preload("res://assets/shaders/lumiere_star.gdshader"),
	"lumiere_feathers": preload("res://assets/shaders/lumiere_feathers.gdshader"),
	"lumiere_wings": preload("res://assets/shaders/lumiere_wings.gdshader"),
	"lumiere_ring": preload("res://assets/shaders/lumiere_ring.gdshader"),
	"lumiere_dawn": preload("res://assets/shaders/lumiere_dawn.gdshader"),
	"lumiere_column": preload("res://assets/shaders/lumiere_column.gdshader"),
	"etoiles_impact": preload("res://assets/shaders/etoiles_impact.gdshader"),
	"etoiles_dash": preload("res://assets/shaders/etoiles_dash.gdshader"),
	"etoiles_ring": preload("res://assets/shaders/etoiles_ring.gdshader"),
	"etoiles_veil": preload("res://assets/shaders/etoiles_veil.gdshader"),
	"etoiles_comet": preload("res://assets/shaders/etoiles_comet.gdshader"),
	"etoiles_night": preload("res://assets/shaders/etoiles_night.gdshader"),
	"demon_griffure": preload("res://assets/shaders/demon_griffure.gdshader"),
	"geolier_choc": preload("res://assets/shaders/geolier_choc.gdshader"),
	"geolier_traversee": preload("res://assets/shaders/geolier_traversee.gdshader"),
	"geolier_eclat": preload("res://assets/shaders/geolier_eclat.gdshader"),
	"geolier_nova": preload("res://assets/shaders/geolier_nova.gdshader"),
	"geolier_gangue": preload("res://assets/shaders/geolier_gangue.gdshader"),
	"geolier_cercle": preload("res://assets/shaders/geolier_cercle.gdshader"),
	"dragon_choc": preload("res://assets/shaders/dragon_choc.gdshader"),
	"dragon_explosion": preload("res://assets/shaders/dragon_explosion.gdshader"),
	"dragon_colonne": preload("res://assets/shaders/dragon_colonne.gdshader"),
	"dragon_fissure": preload("res://assets/shaders/dragon_fissure.gdshader"),
	"dragon_onde": preload("res://assets/shaders/dragon_onde.gdshader"),
	"dragon_voile": preload("res://assets/shaders/dragon_voile.gdshader"),
	"dragon_saut": preload("res://assets/shaders/dragon_saut.gdshader"),
	"dragon_nova": preload("res://assets/shaders/dragon_nova.gdshader"),
	"dragon_gangue": preload("res://assets/shaders/dragon_gangue.gdshader"),
	"dragon_brasier": preload("res://assets/shaders/dragon_brasier.gdshader"),
	"croupier_choc": preload("res://assets/shaders/croupier_choc.gdshader"),
	"avide_choc": preload("res://assets/shaders/avide_choc.gdshader"),
	"avide_saut": preload("res://assets/shaders/avide_saut.gdshader"),
	"avide_onde": preload("res://assets/shaders/avide_onde.gdshader"),
	"avide_voile": preload("res://assets/shaders/avide_voile.gdshader"),
	"avide_fissure": preload("res://assets/shaders/avide_fissure.gdshader"),
	"avide_explosion": preload("res://assets/shaders/avide_explosion.gdshader"),
	"avide_eclat": preload("res://assets/shaders/avide_eclat.gdshader"),
	"avide_nova": preload("res://assets/shaders/avide_nova.gdshader"),
	"croupier_saut": preload("res://assets/shaders/croupier_saut.gdshader"),
	"croupier_voile": preload("res://assets/shaders/croupier_voile.gdshader"),
	"croupier_onde": preload("res://assets/shaders/croupier_onde.gdshader"),
	"croupier_explosion": preload("res://assets/shaders/croupier_explosion.gdshader"),
	"croupier_eclat": preload("res://assets/shaders/croupier_eclat.gdshader"),
	"croupier_noir": preload("res://assets/shaders/croupier_noir.gdshader"),
	"croupier_gangue": preload("res://assets/shaders/croupier_gangue.gdshader"),
	"geolier_onde": preload("res://assets/shaders/geolier_onde.gdshader"),
	"geolier_givre": preload("res://assets/shaders/geolier_givre.gdshader"),
	"geolier_voile": preload("res://assets/shaders/geolier_voile.gdshader"),
	"geolier_colonne": preload("res://assets/shaders/geolier_colonne.gdshader"),
	"ecarlate_trait": preload("res://assets/shaders/ecarlate_trait.gdshader"),
	"ecarlate_volte": preload("res://assets/shaders/ecarlate_volte.gdshader"),
	"ecarlate_garde": preload("res://assets/shaders/ecarlate_garde.gdshader"),
	"ecarlate_parade": preload("res://assets/shaders/ecarlate_parade.gdshader"),
	"ecarlate_eclat": preload("res://assets/shaders/ecarlate_eclat.gdshader"),
	"ecarlate_fourreau": preload("res://assets/shaders/ecarlate_fourreau.gdshader"),
	"braise_choc": preload("res://assets/shaders/braise_choc.gdshader"),
	"braise_saut": preload("res://assets/shaders/braise_saut.gdshader"),
	"braise_fissure": preload("res://assets/shaders/braise_fissure.gdshader"),
	"braise_gueule": preload("res://assets/shaders/braise_gueule.gdshader"),
	"braise_rappel": preload("res://assets/shaders/braise_rappel.gdshader"),
	"braise_explosion": preload("res://assets/shaders/braise_explosion.gdshader"),
	"braise_sceau": preload("res://assets/shaders/braise_sceau.gdshader"),
	"braise_colonne": preload("res://assets/shaders/braise_colonne.gdshader"),
	"braise_voile": preload("res://assets/shaders/braise_voile.gdshader"),
	"braise_onde": preload("res://assets/shaders/braise_onde.gdshader"),
	"ciel_choc": preload("res://assets/shaders/ciel_choc.gdshader"),
	"ciel_sceau": preload("res://assets/shaders/ciel_sceau.gdshader"),
	"ciel_lance": preload("res://assets/shaders/ciel_lance.gdshader"),
	"ciel_cercle": preload("res://assets/shaders/ciel_cercle.gdshader"),
	"ciel_colonne": preload("res://assets/shaders/ciel_colonne.gdshader"),
	"ciel_tinte": preload("res://assets/shaders/ciel_tinte.gdshader"),
	"ciel_onde": preload("res://assets/shaders/ciel_onde.gdshader"),
	"ciel_notes": preload("res://assets/shaders/ciel_notes.gdshader"),
	"ciel_clou": preload("res://assets/shaders/ciel_clou.gdshader"),
	"ciel_envol": preload("res://assets/shaders/ciel_envol.gdshader"),
	"ciel_atterrissage": preload("res://assets/shaders/ciel_atterrissage.gdshader"),
	"ciel_plume": preload("res://assets/shaders/ciel_plume.gdshader"),
	"ciel_ailes": preload("res://assets/shaders/ciel_ailes.gdshader"),
	"ciel_voile": preload("res://assets/shaders/ciel_voile.gdshader"),
	"ciel_epee": preload("res://assets/shaders/ciel_epee.gdshader"),
	"ciel_sceau_or": preload("res://assets/shaders/ciel_sceau_or.gdshader"),
	"ciel_entaille": preload("res://assets/shaders/ciel_entaille.gdshader"),
	"cherubin_choc": preload("res://assets/shaders/cherubin_choc.gdshader"),
	"cherubin_eclair": preload("res://assets/shaders/cherubin_eclair.gdshader"),
	"cherubin_trainee": preload("res://assets/shaders/cherubin_trainee.gdshader"),
	"cherubin_oeil": preload("res://assets/shaders/cherubin_oeil.gdshader"),
	"cherubin_embrasement": preload("res://assets/shaders/cherubin_embrasement.gdshader"),
	"cherubin_tournoyant": preload("res://assets/shaders/cherubin_tournoyant.gdshader"),
	"cherubin_coupe": preload("res://assets/shaders/cherubin_coupe.gdshader"),
	"cherubin_roue": preload("res://assets/shaders/cherubin_roue.gdshader"),
	"cherubin_voile": preload("res://assets/shaders/cherubin_voile.gdshader"),
	"cherubin_rejet": preload("res://assets/shaders/cherubin_rejet.gdshader"),
	"cherubin_jardin": preload("res://assets/shaders/cherubin_jardin.gdshader"),
	"cherubin_epee": preload("res://assets/shaders/cherubin_epee.gdshader"),
	"cherubin_nuit": preload("res://assets/shaders/cherubin_nuit.gdshader"),
	"discorde_noeud": preload("res://assets/shaders/discorde_noeud.gdshader"),
	"discorde_oeil": preload("res://assets/shaders/discorde_oeil.gdshader"),
	"discorde_echange": preload("res://assets/shaders/discorde_echange.gdshader"),
	"discorde_grande": preload("res://assets/shaders/discorde_grande.gdshader"),
	"demon_bond": preload("res://assets/shaders/demon_bond.gdshader"),
	"demon_pacte": preload("res://assets/shaders/demon_pacte.gdshader"),
	"demon_festin": preload("res://assets/shaders/demon_festin.gdshader"),
	"demon_dernier": preload("res://assets/shaders/demon_dernier.gdshader"),
	"demon_veil": preload("res://assets/shaders/demon_veil.gdshader"),
	"acier_impact": preload("res://assets/shaders/acier_impact.gdshader"),
	"acier_dash": preload("res://assets/shaders/acier_dash.gdshader"),
	"acier_ring": preload("res://assets/shaders/acier_ring.gdshader"),
	"acier_anvil": preload("res://assets/shaders/acier_anvil.gdshader"),
	"acier_rampart": preload("res://assets/shaders/acier_rampart.gdshader"),
	"acier_molten": preload("res://assets/shaders/acier_molten.gdshader"),
	"mort_cut": preload("res://assets/shaders/mort_cut.gdshader"),
	"mort_feathers": preload("res://assets/shaders/mort_feathers.gdshader"),
	"mort_sweep": preload("res://assets/shaders/mort_sweep.gdshader"),
	"mort_hour": preload("res://assets/shaders/mort_hour.gdshader"),
}

## L'éclat au toucher, et la fuite, de chaque mage.
const IMPACT := {
	"fire": "fire_burst", "shadow": "shadow_collapse", "invocateur": "arcane_sigil",
	"water": "water_splash", "thunder": "thunder_star", "air": "air_slash",
	"earth": "earth_crack", "supreme": "prism_star", "chrono": "chrono_tick",
	"peste": "peste_splash", "lumiere": "lumiere_star", "mort": "mort_cut", "etoiles": "etoiles_impact",
	"acier": "acier_impact", "demon": "demon_griffure", "discorde": "discorde_noeud", "braise": "braise_choc", "ecarlate": "ecarlate_trait", "geolier": "geolier_choc",
	"ciel": "ciel_choc",
	"cherubin": "cherubin_choc",
	"dragon": "dragon_choc",
	"croupier": "croupier_choc",
	"avide": "avide_choc",
}
const ESCAPE := {
	"invocateur": "arcane_void_step", "water": "water_swirl", "thunder": "thunder_strike",
	"air": "air_streaks", "earth": "earth_fissure", "supreme": "prism_shift",
	"chrono": "chrono_rewind", "peste": "peste_mist", "lumiere": "lumiere_feathers", "mort": "mort_feathers", "etoiles": "etoiles_dash",
	"acier": "acier_dash", "demon": "demon_bond", "discorde": "discorde_echange", "braise": "braise_saut", "ecarlate": "ecarlate_volte", "geolier": "geolier_traversee",
	"ciel": "ciel_envol",
	"cherubin": "cherubin_eclair",
	"dragon": "dragon_saut",
	"croupier": "croupier_saut",
	"avide": "avide_saut",
}
## La couleur de la flamme de chaque sceau du Suprême. Tout autre élément prend l'air.
const SEAL_KINDS := {
	Element.Kind.FIRE: 0, Element.Kind.WATER: 1, Element.Kind.EARTH: 2, Element.Kind.AIR: 3,
}
## Les autres effets de chaque mage, à compiler avec le niveau.
const EXTRAS := {
	"water": ["water_geyser", "water_bubble"],
	"thunder": ["thunder_cloud", "thunder_storm", "thunder_crest"],
	"air": ["air_gust", "air_veil"],
	"earth": ["earth_quake"],
	"supreme": ["rebirth_aura", "seal_flame", "convergence_burst", "judgement_burst"],
	"chrono": ["chrono_sand", "chrono_stop"],
	"peste": ["peste_puddle", "peste_heal", "peste_wave", "peste_dissolve"],
	"lumiere": ["lumiere_wings", "lumiere_ring", "lumiere_dawn", "lumiere_column"],
	"mort": ["mort_sweep", "mort_hour"],
	"etoiles": ["etoiles_ring", "etoiles_veil", "etoiles_comet", "etoiles_night"],
	"acier": ["acier_ring", "acier_anvil", "acier_rampart", "acier_molten"],
	"demon": ["demon_pacte", "demon_festin", "demon_dernier", "demon_veil"],
	"discorde": ["discorde_oeil", "discorde_grande"],
	"geolier": ["geolier_eclat", "geolier_nova", "geolier_gangue", "geolier_cercle", "geolier_onde",
		"geolier_givre", "geolier_voile", "geolier_colonne"],
	"ecarlate": ["ecarlate_garde", "ecarlate_parade", "ecarlate_eclat", "ecarlate_fourreau"],
	"cherubin": ["cherubin_trainee", "cherubin_oeil", "cherubin_embrasement", "cherubin_tournoyant", "cherubin_coupe", "cherubin_roue",
		"cherubin_voile", "cherubin_rejet", "cherubin_jardin", "cherubin_epee", "cherubin_nuit"],
	"ciel": ["ciel_sceau", "ciel_lance", "ciel_cercle", "ciel_colonne", "ciel_tinte", "ciel_onde", "ciel_notes", "ciel_clou",
		"ciel_atterrissage", "ciel_plume", "ciel_ailes", "ciel_voile", "ciel_epee", "ciel_sceau_or", "ciel_entaille"],
	"avide": ["avide_onde", "avide_voile", "avide_fissure", "avide_explosion", "avide_eclat", "avide_nova"],
	"croupier": ["croupier_voile", "croupier_onde", "croupier_explosion", "croupier_eclat", "croupier_noir",
		"croupier_gangue"],
	"dragon": ["dragon_explosion", "dragon_colonne", "dragon_fissure", "dragon_onde", "dragon_voile",
		"dragon_nova", "dragon_gangue", "dragon_brasier"],
	"braise": ["braise_fissure", "braise_gueule", "braise_rappel", "braise_explosion", "braise_sceau",
		"braise_colonne", "braise_voile", "braise_onde"],
}


static func make_material(key: String, seed_value: float = 0.0) -> ShaderMaterial:
	var shaded := ShaderMaterial.new()
	shaded.shader = SHADERS[key]
	shaded.set_shader_parameter("noise", NOISES.get(key, NOISE))
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
