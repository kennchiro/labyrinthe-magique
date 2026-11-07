shader_type canvas_item;
render_mode blend_mix;

// LE COCON DE VENT, porté sur lui : une sphère de rubans entrelacés qui tournent dans deux sens, un
// anneau d'or à sa taille. Le dedans reste presque vide pour qu'on le voie.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = S_PALE;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.92, 1.0, t));
	float r = 0.82 * grow;
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		// Chaque ruban est un arc de la sphère, aplati différemment pour donner le volume.
		float tilt = 0.35 + 0.6 * s_hash(f, seed);
		vec2 q = vec2(p.x, p.y / tilt);
		float dir = mod(f, 2.0) == 0.0 ? 1.0 : -1.0;
		float rel;
		float arc = s_arc(s_rot(q, f * 0.9), r, TIME * 2.2 * dir + f, 2.4, 0.08, rel);
		if (arc > -0.02 && r > 0.0) {
			color = arc <= 0.0 ? S_RIM : s_wind(arc / 0.08);
			a = 1.0;
		}
	}
	vec2 g = vec2(p.x, p.y * 4.0);
	float ring = 0.06 - abs(length(g) - r * 1.05);
	if (ring > -0.03 && r > 0.0 && p.y > -0.02) {
		color = ring <= 0.0 ? S_RIM : S_GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
