shader_type canvas_item;
render_mode blend_mix;

// L'AURA DU DRAGON PRIMORDIAL, toute la minute : un cercle de LAVE CRAQUELÉE tourne lentement sous ses pieds, à
// croûte d'obsidienne fendue de magma, et des BRAISES montent de ses épaules. Posée derrière lui.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float show = smoothstep(0.0, 0.012, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.66)) * vec2(1.0, 2.6);
	float d = length(g);
	vec2 rg = p_rot(g, TIME * 0.2);
	float ang = atan(rg.y, rg.x);
	float band = 0.09 - abs(d - 0.6);
	if (band > 0.0) {
		float plate = abs(fract(ang * 14.0 / TAU + seed) - 0.5);
		float seam = 0.08 - plate;
		color = seam > 0.0 ? (seam > 0.04 ? P_YELLOW : P_MAGMA) : P_OBSIDIAN;
		if (band < 0.02) {
			color = P_BLOOD;
		}
		a = 0.85;
	}
	// Les braises qui montent.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float life = fract(TIME * 0.4 + p_hash(f, seed));
		vec2 at = vec2((p_hash(f + 3.0, seed) - 0.5) * 1.2 + sin(TIME * 2.0 + f) * 0.05, 0.3 - life * 1.2);
		float s = p_shard(p_rot(p - at, TIME + f), 0.025, 0.04);
		if (s > -0.2 && life < 0.9) {
			color = s <= 0.0 ? P_OBSIDIAN : (life < 0.4 ? P_YELLOW : P_MAGMA);
			a = max(a, 0.9 * (1.0 - smoothstep(0.7, 0.9, life)));
		}
	}
	COLOR = vec4(color, a * show);
}
