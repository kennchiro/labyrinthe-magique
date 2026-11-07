shader_type canvas_item;
render_mode blend_mix;

// UNE BRANCHE DE LA FAILLE, couchée entre deux cases : une crevasse de lave s'ouvre de la case de
// départ vers la suivante, bordée de roche soulevée, puis refroidit. UV.x va du départ à l'arrivée.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	vec3 color = C_ROCK;
	float a = 0.0;
	float reach = smoothstep(0.0, 0.3, t);
	float heat = 1.0 - smoothstep(0.55, 1.0, t);
	float fade = 1.0 - smoothstep(0.8, 1.0, t);
	if (p.x <= reach) {
		float seg = floor(p.x * 6.0);
		float f = fract(p.x * 6.0);
		float centre = mix(c_hash(seg, seed) - 0.5, c_hash(seg + 1.0, seed) - 0.5, f) * 0.35;
		float width = 0.28 * fade;
		float crack = width - abs(p.y - centre);
		// Les lèvres de roche, de chaque côté de la lave.
		float lip = crack + 0.16 * fade;
		if (lip > 0.0) {
			color = lip < 0.035 ? C_RIM : (p.y < centre ? C_ROCK_LIGHT : C_ROCK_DARK);
			a = 1.0;
		}
		if (crack > -0.03) {
			color = crack <= 0.0 ? C_RIM : c_lava(crack / max(width, 0.001), max(heat, 0.15));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
