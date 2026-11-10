shader_type canvas_item;
render_mode blend_mix;

// LA BRÛLURE QUE LAISSE LA BOULE DE FEU : une tache de sol calciné, fendue de braises qui s'éteignent.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = p * vec2(1.0, 1.8);
	float ang = atan(g.y, g.x);
	float edge = 0.62 + 0.08 * sin(ang * 5.0 + seed * 7.0) + 0.05 * sin(ang * 11.0);
	float d = length(g);
	vec3 color = vec3(0.1, 0.05, 0.04);
	float a = 0.0;
	if (d < edge) {
		a = 0.7;
		// Les fissures de braise.
		float crack = abs(fract(ang / TAU * 7.0 + seed + d * 0.6) - 0.5);
		float glow = 1.0 - smoothstep(0.1, 0.8, t);
		if (crack * d < 0.03 && d > 0.08 && glow > 0.0) {
			color = mix(L_BLOOD, L_FLAME, glow * (0.6 + 0.4 * sin(TIME * 8.0 + d * 10.0)));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * (1.0 - smoothstep(0.6, 1.0, t)));
}
