shader_type canvas_item;
render_mode blend_mix;

// LA GARDE DU SEIGNEUR, pendant qu'elle dure : un cercle de six lames blanches cerclées de rouge tourne autour de lui,
// pointes vers l'extérieur, et se resserre peu à peu. Quad centré sur son corps.

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
	float show = smoothstep(0.0, 0.06, t) * (1.0 - smoothstep(0.94, 1.0, t));
	vec2 g = p * vec2(1.0, 1.5);
	float r = mix(0.85, 0.62, t);
	for (int i = 0; i < 6; i++) {
		float an = float(i) * TAU / 6.0 + TIME * 2.4;
		vec2 dir = vec2(cos(an), sin(an));
		vec2 inner = dir * (r - 0.2);
		vec2 outer = dir * (r + 0.12);
		vec3 c = color;
		if (s_paint_cut(g, inner, outer, 0.08, c)) {
			color = c;
			a = 1.0;
		}
	}
	float ring = 0.012 - abs(length(g) - r + 0.25);
	if (ring > 0.0) {
		color = S_RED;
		a = 0.8;
	}
	COLOR = vec4(color, a * show);
}
