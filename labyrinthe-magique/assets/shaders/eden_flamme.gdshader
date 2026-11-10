shader_type canvas_item;
render_mode blend_mix;

// LE COULOIR EN FEU de l'Épée flamboyante : des langues de flamme saphir dressées sur la case, qui ondulent et
// baissent avant de s'éteindre.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.6, 1.0, t));
	vec4 color = vec4(E_DEEP, e_glow(length(vec2(p.x, (p.y - 0.4) * 2.0)), 0.7) * 0.45 * life);
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		vec2 base = vec2((f - 1.5) * 0.28 + (e_hash(f, seed) - 0.5) * 0.1, 0.55);
		float h = (0.5 + 0.4 * e_hash(f + 3.0, seed)) * life * (0.85 + 0.15 * sin(TIME * 9.0 + f));
		float tongue = e_tongue(p - base, h, TIME, f + seed);
		float inner = e_tongue((p - base) * vec2(1.8, 1.0), h * 0.7, TIME, f + seed);
		color = e_over(vec4(e_flame(0.5), tongue), color);
		color = e_over(vec4(e_flame(0.95), inner), color);
	}
	COLOR = color;
}
