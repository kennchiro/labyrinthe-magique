shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAT DE SANG : une bulle de sang gonfle, tremble, puis ÉCLATE en étoile de gouttes, avec un éclair pâle
// et une tache qui s'étale au sol. L'impact de la serre géante de l'Apocalypse.

#include "res://assets/shaders/archi.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_VENOM;
	float a = 0.0;
	float swell = smoothstep(0.0, 0.25, t);
	float burst = smoothstep(0.25, 0.3, t);
	vec2 c = p - vec2(sin(TIME * 60.0) * 0.02 * swell * (1.0 - burst), -0.15);
	float d = length(c);
	// La bulle qui gonfle.
	float bubble = 0.38 * swell - d;
	if (burst < 1.0 && bubble > -0.025) {
		color = bubble <= 0.0 ? F_RIM : mix(F_VENOM, F_BRIGHT, smoothstep(0.0, 0.3, bubble));
		if (length(c - vec2(-0.12, -0.12)) < 0.08 * swell) {
			color = F_CORE;
		}
		a = 0.85;
	}
	// L'éclat : l'éclair, et l'étoile de gouttes.
	float k = clamp((t - 0.28) / 0.6, 0.0, 1.0);
	float flash = burst * (1.0 - smoothstep(0.3, 0.5, t));
	if (d < 0.6 * flash) {
		color = mix(F_CORE, F_BRIGHT, d / max(0.01, 0.6 * flash));
		a = max(a, flash);
	}
	vec2 g = (p - vec2(0.0, 0.3)) * vec2(1.0, 2.0);
	float splat = (0.55 + 0.12 * sin(atan(g.y, g.x) * 7.0 + seed * 9.0)) * smoothstep(0.28, 0.45, t) - length(g);
	if (burst > 0.0 && splat > -0.03) {
		color = splat <= 0.0 ? F_RIM : (splat > 0.2 ? F_BRIGHT : F_VENOM);
		a = max(a, 1.0 - smoothstep(0.6, 1.0, t));
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ca = f / 10.0 * TAU + seed * 4.0;
		vec2 at = vec2(0.0, -0.15) + vec2(cos(ca), sin(ca)) * (0.2 + k * 0.75) + vec2(0.0, k * k * 0.5);
		vec3 drop = color;
		if (burst > 0.0 && k < 1.0 && f_paint_drop(f_rot(p - at, ca - 1.5708 + PI), 0.075 * (1.0 - k * 0.5), drop)) {
			color = drop;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
