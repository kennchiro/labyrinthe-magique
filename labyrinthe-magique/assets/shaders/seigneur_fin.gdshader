shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DU SEIGNEUR : le cercle de coupes se brise en arcs, les derniers pétales tombent et se fanent en
// rouge sombre. Le démon rentre dans sa lame.

#include "res://assets/shaders/seigneur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float chunks = abs(fract((ang + seed * 6.0) * 6.0 / TAU) - 0.5) - 0.1 - t * 0.35;
	float ring = min(0.022 * (1.0 - t) - abs(d - 0.6 - t * 0.25), chunks);
	if (ring > 0.0) {
		color = S_RED;
		a = 1.0;
	}
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		vec2 at = vec2((s_hash(f, seed) - 0.5) * 1.4, -0.8 + t * 1.4 + s_hash(f + 2.0, seed) * 0.3);
		vec3 c = color;
		if (t < 0.95 && s_paint_petal(s_rot(p - at, f + t * 5.0), 0.06 * (1.0 - t * 0.6), t > 0.4, c)) {
			color = t > 0.6 && c != S_BLACK ? S_DARK : c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
