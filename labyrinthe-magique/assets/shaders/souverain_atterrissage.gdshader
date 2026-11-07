shader_type canvas_item;
render_mode blend_mix;

// IL RETOMBE : une bourrasque rabat tout en cercle, quatre croissants partent vers l'extérieur, et un
// anneau d'or marque le sol où il se pose.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 1.5);
	float d = length(g);
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	float gold = 0.04 * (1.0 - smoothstep(0.5, 1.0, t)) - abs(d - 0.3);
	if (gold > -0.015) {
		color = gold <= 0.0 ? S_RIM : S_GOLD;
		a = 1.0;
	}
	float fly = smoothstep(0.0, 0.6, t);
	float fade = 1.0 - smoothstep(0.5, 0.95, t);
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float ang = f / 4.0 * TAU + PI * 0.25 + seed;
		vec2 q = s_rot(g, -ang) - vec2(0.3 + fly * 0.5, 0.0);
		float moon = s_crescent(vec2(-q.x, q.y), 0.2 * fade, -0.09);
		if (moon > -0.02 && fade > 0.0) {
			color = moon <= 0.0 ? S_RIM : s_wind(clamp(moon / 0.06, 0.0, 1.0));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
