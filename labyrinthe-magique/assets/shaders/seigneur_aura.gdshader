shader_type canvas_item;
render_mode blend_mix;

// L'AURA DU SEIGNEUR, toute la minute : un cercle de coupes courtes tourne couché sous ses pieds, chacune blanche à
// filet rouge, et des pétales tombent lentement autour de lui en tournoyant. Posée derrière lui.

#include "res://assets/shaders/seigneur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float show = smoothstep(0.0, 0.012, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.64)) * vec2(1.0, 2.6);
	float d = length(g);
	float ring = 0.01 - abs(d - 0.66);
	if (ring > 0.0) {
		color = S_RED;
		a = 0.8;
	}
	// Douze coupes courtes en arc, qui tournent.
	vec2 rg = s_rot(g, TIME * 0.6);
	float ang = atan(rg.y, rg.x);
	float sector = fract(ang * 12.0 / TAU) - 0.5;
	float along = abs(sector) / 0.36;
	float w = 0.03 * (1.0 - along * along);
	float cut = w - abs(d - 0.56 - sector * 0.08);
	if (along < 1.0 && cut > -0.012) {
		color = cut <= 0.0 ? S_BLACK : (cut > w * 0.45 ? S_WHITE : S_RED);
		a = 0.9;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float life = fract(TIME * 0.18 + s_hash(f, seed));
		vec2 at = vec2((s_hash(f + 3.0, seed) - 0.5) * 1.5 + sin(TIME * 1.3 + f) * 0.12, -0.95 + life * 1.6);
		vec3 c = color;
		if (life < 0.92 && s_paint_petal(s_rot(p - at, TIME * 2.0 + f), 0.05, mod(f, 3.0) < 1.0, c)) {
			color = c;
			a = max(a, 0.9 * (1.0 - smoothstep(0.75, 0.92, life)));
		}
	}
	COLOR = vec4(color, a * show);
}
