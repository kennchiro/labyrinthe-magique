shader_type canvas_item;
render_mode blend_mix;

// LE SOUFFLE DU TITAN : une onde de vent part en cercle jusqu'au bout de son rayon, faite de croissants
// qui se suivent, avec des traits de vitesse vers l'extérieur et une spirale qui s'ouvre au centre.

#include "res://assets/shaders/souverain.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = S_SKY;
	float a = 0.0;
	float front = 0.12 + smoothstep(0.0, 0.55, t) * 0.7;
	float fade = 1.0 - smoothstep(0.45, 0.9, t);
	// L'onde : un anneau ondulé, épais, qui se brise en croissants.
	float wav = 0.5 + 0.5 * cos(atan(p.y, p.x) * 10.0 + t * 6.0);
	float width = 0.07 * fade * smoothstep(0.15, 0.6, wav);
	float ring = width - abs(d - front);
	if (ring > -0.015 && width > 0.01) {
		color = ring <= 0.0 ? S_RIM : s_wind(ring / width);
		a = 1.0;
	}
	// Les traits de vitesse, vers l'extérieur.
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ang = f / 12.0 * TAU + seed;
		vec2 q = s_rot(p, -ang);
		float start = front - 0.25;
		float dash = q.x > start && q.x < front - 0.05 ? 0.018 * fade - abs(q.y) : -1.0;
		if (dash > -0.008 && fade > 0.0) {
			color = dash <= 0.0 ? S_RIM : S_SILVER;
			a = 1.0;
		}
	}
	float spin = s_spiral(p, 0.1, 2.0, 0.4, t * 10.0, 0.25 * (1.0 - smoothstep(0.2, 0.7, t)));
	if (spin > 0.0) {
		color = S_WHITE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
