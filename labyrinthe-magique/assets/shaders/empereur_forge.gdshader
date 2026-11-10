shader_type canvas_item;
render_mode blend_mix;

// LA FORGE IMPÉRIALE QUI ASPIRE : une bouche de forge rougeoie au centre, et des langues de flamme y sont aspirées en
// spirale depuis le bord. Un temps d'aspiration, joué à chaque fois qu'elle tire les ennemis vers elle.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 g = p * vec2(1.0, 1.6);
	float d = length(g);
	float ang = atan(g.y, g.x);
	float fade = 1.0 - smoothstep(0.8, 1.0, t);
	// Les bras de flamme en spirale qui rentrent vers le centre.
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float arm = ang + d * 4.5 - t * 9.0 + f * TAU / 5.0 + seed;
		float s = abs(fract(arm / TAU) - 0.5);
		float w = 0.07 * (1.0 - d) * fade;
		if (d < 0.95 && d > 0.15 && s * d * 6.0 < w * 6.0) {
			color = s * d * 6.0 < w * 3.0 ? E_EMBER : E_LAVA;
			a = 1.0;
		}
	}
	// La bouche de forge.
	float mouth = 0.22 * fade - d;
	if (mouth > -0.02) {
		color = mouth <= 0.0 ? E_BLACK : (mouth > 0.1 ? E_PALE : E_LAVA);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
