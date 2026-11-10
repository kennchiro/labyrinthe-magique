shader_type canvas_item;
render_mode blend_mix;

// LA PLAQUE DE GIVRE de l'Hiver de l'Abîme : une plaque de glace pâle, couchée sur le sol, striée de fissures en
// étoile et bordée de cristaux. Elle craque en s'effaçant. Le centre reste clair pour qu'on voie les ennemis.

#include "res://assets/shaders/abime.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 3.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float grow = clamp(phase / 0.3, 0.0, 1.0);
	float melt = smoothstep(0.25, 0.0, life);
	float edge = 0.9 * grow - d + sin(ang * 9.0 + seed * 3.0) * 0.04;
	vec3 color = vec3(0.0);
	float a = 0.0;
	if (edge > 0.0) {
		color = mix(A_PALE, A_CYAN, smoothstep(0.0, 0.5, d));
		a = 0.32 * (1.0 - melt);
		float crack = 0.012 - abs(fract(ang * 7.0 / TAU + seed) - 0.5) * d;
		if (crack > 0.0 && d > 0.15) {
			color = A_PALE;
			a = 0.85 * (1.0 - melt);
		}
		float ring = 0.014 - abs(d - 0.55 * grow);
		if (ring > 0.0) {
			color = A_PALE;
			a = 0.7 * (1.0 - melt);
		}
	}
	if (edge > -0.012 && edge <= 0.0) {
		color = A_DEEP;
		a = 0.8 * (1.0 - melt);
	}
	// Les cristaux du bord.
	float sector = fract(ang * 14.0 / TAU + seed) - 0.5;
	float s = a_shard(vec2(sector * d * 0.5, d - 0.86 * grow), 0.03, 0.09 * (1.0 - melt));
	if (s > -0.2 && melt < 0.95) {
		color = s <= 0.0 ? A_OBSIDIAN : (s > 0.5 ? A_PALE : A_CYAN);
		a = 1.0;
	}
	COLOR = vec4(color, a * COLOR.a);
}
