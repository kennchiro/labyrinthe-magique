class_name FxTextures
extends RefCounted

## Textures d'effets fabriquées en mémoire, partagées par tous les effets.
##
## Sans texture, CPUParticles2D dessine des POINTS d'un pixel : mis à l'échelle,
## ce sont des carrés durs — des étincelles, pas des flammes. C'est la texture
## qui fait la différence entre « ça scintille » et « ça brûle ».
##
## Elles sont générées plutôt que dessinées : un blob en dégradé radial est
## quatre lignes de code, et une image de plus dans `assets/` serait une image
## de plus à exporter vers l'iPhone pour une forme que le moteur sait faire.

## Une seule instance pour tout le jeu : chaque brasier, chaque orbe et chaque
## explosion la réutilise. En fabriquer une par émetteur allouerait une texture
## à chaque sort lancé.
static var _blob: Texture2D = null


## Blob doux : cœur plein, retombée franche.
##
## Le point d'arrêt à 45 % est ce qui lui donne du CORPS. Un dégradé linéaire du
## centre au bord rend un halo mou, qui se lit comme de la brume ; une flamme a
## un cœur.
static func soft_blob() -> Texture2D:
	if _blob != null:
		return _blob
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 1))
	ramp.set_color(1, Color(1, 1, 1, 0))
	ramp.add_point(0.45, Color(1, 1, 1, 0.85))
	var blob := GradientTexture2D.new()
	blob.gradient = ramp
	blob.fill = GradientTexture2D.FILL_RADIAL
	blob.fill_from = Vector2(0.5, 0.5)
	blob.fill_to = Vector2(1.0, 0.5)
	blob.width = 32
	blob.height = 32
	_blob = blob
	return _blob


## Émetteur de FUMÉE : sombre, lent, il monte et GROSSIT en se diluant.
##
## En blending NORMAL et non additif, contrairement au feu : une fumée additive
## éclaircit le décor au lieu de le masquer, et ne se lit plus comme de la
## fumée. C'est elle qui fait qu'une explosion a un après — sans elle, le feu
## s'éteint et il ne s'est rien passé.
static func smoke_emitter(amount: int, life: float, size: float,
		rise: float) -> CPUParticles2D:
	var smoke := CPUParticles2D.new()
	smoke.texture = soft_blob()
	smoke.amount = clampi(amount, 4, 90)
	smoke.lifetime = maxf(0.1, life)
	smoke.lifetime_randomness = 0.4
	smoke.spread = 180.0
	smoke.gravity = Vector2(0.0, rise)
	smoke.damping_min = 30.0
	smoke.damping_max = 70.0        # la fumée s'essouffle vite, puis dérive
	smoke.scale_amount_min = (size * 0.5) / 32.0
	smoke.scale_amount_max = size / 32.0
	# Elle GROSSIT en vieillissant : c'est l'inverse d'une flamme, et c'est ce
	# qui distingue un panache qui se dilue d'une étincelle qui s'éteint.
	var swell := Curve.new()
	swell.add_point(Vector2(0.0, 0.35))
	swell.add_point(Vector2(1.0, 1.0))
	smoke.scale_amount_curve = swell
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.24, 0.19, 0.17, 0.75))
	ramp.set_color(1, Color(0.16, 0.15, 0.16, 0.0))
	smoke.color_ramp = ramp
	return smoke


## Émetteur de flammes prêt à l'emploi, en blending additif.
## `rise` NÉGATIF fait monter le feu ; positif le fait retomber.
## `additive` : une flamme de FEU ajoute de la lumière, c'est ce qui lui donne
## son cœur incandescent. Une flamme SOMBRE fait l'inverse — elle mange la
## lumière — et l'additif lui est structurellement interdit : le noir n'y
## existe pas, et le violet y sature en rose. Elle se compose donc normalement.
static func flame_emitter(amount: int, life: float, size: float,
		hot: Color, cold: Color, rise: float, spread: float,
		additive: bool = true) -> CPUParticles2D:
	var flames := CPUParticles2D.new()
	flames.texture = soft_blob()
	flames.amount = clampi(amount, 6, 240)
	flames.lifetime = maxf(0.05, life)
	flames.lifetime_randomness = 0.55     # le vacillement : sans lui, ça pulse
	flames.spread = spread
	flames.gravity = Vector2(0.0, rise)
	flames.initial_velocity_min = 4.0
	flames.initial_velocity_max = 22.0
	# En fraction de la texture (32 px) : c'est un multiplicateur, pas des pixels.
	flames.scale_amount_min = (size * 0.45) / 32.0
	flames.scale_amount_max = size / 32.0
	# Les langues MAIGRISSENT en vivant, comme une flamme qui s'effile.
	var taper := Curve.new()
	taper.add_point(Vector2(0.0, 1.0))
	taper.add_point(Vector2(1.0, 0.0))
	flames.scale_amount_curve = taper
	var ramp := Gradient.new()
	ramp.set_color(0, hot)
	ramp.set_color(1, cold)
	flames.color_ramp = ramp
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD if additive \
		else CanvasItemMaterial.BLEND_MODE_MIX
	flames.material = material
	return flames
