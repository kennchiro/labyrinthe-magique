shader_type canvas_item;
render_mode blend_mix;

// LA GERBE DU CRACHAT : la goutte s'écrase, une tache de venin s'étale au sol, et une couronne de huit gouttelettes
// part tout autour avant de retomber.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_VENOM;
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.25)) * vec2(1.0, 2.0);
	float ang = atan(g.y, g.x);
	float splat = (0.45 + 0.1 * sin(ang * 7.0 + seed * 11.0)) * smoothstep(0.0, 0.15, t) - length(g);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	if (splat > -0.03) {
		color = splat <= 0.0 ? F_RIM : (splat > 0.25 ? F_CORE : (splat > 0.1 ? F_BRIGHT : F_VENOM));
		a = fade;
	}
	// Le choc : un anneau clair qui s'ouvre au sol.
	float ring = 0.04 * (1.0 - t) - abs(length(g) - (0.3 + t * 0.6));
	if (ring > 0.0 && t < 0.6) {
		color = F_CORE;
		a = 1.0 - t / 0.6;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ca = f / 8.0 * TAU + seed * 3.0;
		float k = clamp(t / 0.8, 0.0, 1.0);
		vec2 at = vec2(0.0, 0.25) + vec2(cos(ca), sin(ca) * 0.55) * (0.15 + k * 0.7) - vec2(0.0, sin(k * PI) * 0.45);
		vec3 drop = color;
		if (k < 1.0 && f_paint_drop(p - at, 0.065 * (1.0 - k * 0.4), drop)) {
			color = drop;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
