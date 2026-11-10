shader_type canvas_item;
render_mode blend_mix;

// UNE ORBE DE LA ROUE : une sphère de la matière de son élément, cerclée d'or. L'orbe en tête (`lead` à 1) est plus
// vive et porte un halo.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform int kind = 0;
uniform float lead = 0.0;
uniform float fade = 1.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float r = 0.62;
	vec4 color = vec4(0.0);
	// Le halo de l'orbe en tête.
	float halo = p_glow(d - r, 0.36) * step(r, d) * lead;
	color = vec4(p_element(kind), halo * 0.7);
	if (d < r) {
		float spin = TIME * 1.8 + seed * 6.0;
		vec2 q = mat2(vec2(cos(spin), sin(spin)), vec2(-sin(spin), cos(spin))) * p;
		vec4 matter = paint_element(kind, q * 1.6 + seed, TIME * 1.5, (r - d) / r * 1.6 + 0.2);
		vec3 base = mix(p_element(kind) * 0.55, matter.rgb, matter.a);
		// Le reflet, et l'éclat de l'orbe en tête.
		base = mix(base, P_WHITE, p_glow(length(p - vec2(-0.2, -0.22)), 0.2) * 0.8);
		base = mix(base, P_WHITE, lead * 0.18);
		color = vec4(base, 1.0);
	}
	float rim = 0.07 - abs(d - r);
	if (rim > 0.0) {
		color = vec4(mix(P_GOLD_DARK, P_GOLD_LIGHT, rim / 0.07), 1.0);
	}
	color.a *= fade;
	COLOR = color;
}
