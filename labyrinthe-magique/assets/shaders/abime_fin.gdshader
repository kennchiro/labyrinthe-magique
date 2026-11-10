shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DU GARDIEN : le cercle de maillons se brise et ses maillons tombent, le givre fond en flaque qui
// rétrécit. La serrure se referme.

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
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	float pool = 0.6 * (1.0 - t) - length(g);
	if (pool > 0.0) {
		color = pool > 0.1 ? A_DEEP : A_CYAN;
		a = 0.8;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		vec2 at = vec2((a_hash(f, seed) - 0.5) * 1.3, -0.5 + t * 1.2 + a_hash(f + 2.0, seed) * 0.3);
		vec3 c = color;
		if (t < 0.92 && a_paint_link(a_rot(p - at, f + t * 6.0), 0.07, 0.045, c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
