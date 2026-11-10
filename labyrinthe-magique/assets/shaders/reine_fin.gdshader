shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DE LA REINE : ses fils se rompent et retombent en boucles autour d'elle, le cercle s'ouvre en
// arcs qui s'éparpillent, et un dernier œil se ferme à ses pieds.

#include "res://assets/shaders/reine.gdshaderinc"

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
	float r = 0.6 + t * 0.35;
	float chunks = abs(fract((ang + seed * 6.0) * 5.0 / TAU) - 0.5) - 0.12 - t * 0.3;
	float ring = min(0.022 * (1.0 - t) - abs(d - r), chunks);
	if (ring > 0.0) {
		color = R_SILVER;
		a = 1.0;
	}
	// Les fils rompus tombent en ondulant.
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float x0 = (r_hash(f, seed) - 0.5) * 1.5;
		float y0 = -0.9 + t * 1.3 + r_hash(f + 3.0, seed) * 0.3;
		float len = 0.35 * (1.0 - t);
		float k = (p.y - y0) / max(len, 0.001);
		float x = x0 + sin(k * 6.0 + f) * 0.06;
		if (k > 0.0 && k < 1.0 && abs(p.x - x) < 0.011) {
			color = i % 2 == 0 ? R_SILVER : R_MAGENTA;
			a = 1.0 - t;
		}
	}
	vec3 eye = color;
	float open = 1.0 - smoothstep(0.2, 0.6, t);
	if (r_paint_eye((p - vec2(0.0, 0.6)) * vec2(1.0, 1.6), vec2(0.2, 0.08), open, eye) && t < 0.65) {
		color = eye;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
