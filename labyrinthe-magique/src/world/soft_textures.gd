class_name SoftTextures
extends RefCounted

## Les dégradés de la vue en volume, calculés une seule fois et partagés.

static var _glow: Texture2D = null
static var _blot: Texture2D = null


## Le halo peint au sol : aucune vraie lumière, aucune passe de rendu en plus.
static func glow() -> Texture2D:
	if _glow == null:
		var gradient := Gradient.new()
		gradient.offsets = [0.0, 0.35, 1.0]
		gradient.colors = [Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.32), Color(1, 1, 1, 0)]
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.width = 128
		texture.height = 128
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		_glow = texture
	return _glow


## Une tache à cœur plein : le halo retombe trop vite pour dessiner une ombre, dont seul
## le centre se verrait, justement sous ce qui la projette.
static func blot() -> Texture2D:
	if _blot == null:
		var gradient := Gradient.new()
		gradient.offsets = [0.0, 0.6, 1.0]
		gradient.colors = [Color(1, 1, 1, 1), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0)]
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.width = 128
		texture.height = 128
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(0.5, 0.5)
		texture.fill_to = Vector2(1.0, 0.5)
		_blot = texture
	return _blot


## Sprite3D n'a pas de mode additif : il passe par ce matériau, sa teinte étant
## portée par la couleur de ses sommets.
static func additive(texture: Texture2D) -> StandardMaterial3D:
	var material := shade(texture)
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.render_priority = -2
	return material


## La même chose en alpha ordinaire : ce qui assombrit le sol au lieu de l'éclairer.
static func shade(texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material
