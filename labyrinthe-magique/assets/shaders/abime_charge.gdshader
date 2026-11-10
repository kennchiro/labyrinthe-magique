shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DU GARDIEN : des chaînes jaillissent du sol tout autour de lui et montent en spirale autour de son
// corps en se resserrant, puis une serrure de flamme tourne et s'ouvre au milieu de son plastron, dans un éclair.

#include "res://assets/shaders/abime.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	// Trois chaînes qui montent en spirale.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		for (int j = 0; j < 9; j++) {
			float fj = float(j);
			float k = fj / 8.0;
			if (k > smoothstep(0.0, 0.6, t)) {
				break;
			}
			float r = mix(0.8, 0.38, smoothstep(0.2, 0.8, t)) * (1.0 - k * 0.2);
			float ang = f * TAU / 3.0 + k * 5.0 + t * 4.0;
			vec2 at = vec2(cos(ang) * r, 0.7 - k * 1.4 + sin(ang) * r * 0.25);
			vec2 q = a_rot(p - at, ang + 1.5708);
			vec3 c = color;
			if (a_paint_link(mod(fj, 2.0) > 0.5 ? vec2(q.x, q.y * 2.0) : q, 0.06, 0.04, c)) {
				color = c;
				a = 1.0;
			}
		}
	}
	// La serrure qui s'ouvre au plastron.
	vec2 lock = p - vec2(0.0, -0.1);
	float open = smoothstep(0.6, 0.85, t);
	float ring = 0.03 - abs(length(lock) - 0.16);
	if (open > 0.0 && ring > 0.0) {
		color = A_LINK;
		a = 1.0;
	}
	if (open > 0.0 && a_keyhole(a_rot(lock, (1.0 - open) * 3.0), 0.16) > 0.0) {
		color = A_PALE;
		a = 1.0;
	}
	float flash = smoothstep(0.8, 0.86, t) * (1.0 - smoothstep(0.88, 1.0, t));
	float star = 0.6 * flash - length(lock) - abs(sin(atan(lock.y, lock.x) * 4.0)) * 0.25;
	if (star > 0.0) {
		color = star > 0.12 ? A_PALE : A_CYAN;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
