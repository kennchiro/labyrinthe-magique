shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DE L'EMPEREUR : six éclats de sa couronne brisée se soulèvent et tournent au-dessus de sa tête, la
// lave coule entre eux et les ressoude en se resserrant, puis un éclair pâle : la couronne est reforgée.

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
	vec2 c = vec2(0.0, -0.45);
	float r = mix(0.75, 0.32, smoothstep(0.1, 0.8, t));
	// Le cercle de lave qui les ressoude.
	vec2 g = (p - c) * vec2(1.0, 2.4);
	float weld = 0.03 * smoothstep(0.25, 0.6, t) - abs(length(g) - r);
	if (weld > 0.0) {
		color = weld > 0.015 ? E_PALE : E_LAVA;
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float ang = f * TAU / 6.0 + t * 5.0;
		vec2 at = c + vec2(cos(ang) * r, sin(ang) * r / 2.4 - smoothstep(0.0, 0.3, t) * 0.12);
		vec2 q = e_rot(p - at, ang * 0.3);
		float shard = e_spike(q, 0.07, 0.13);
		if (shard > -0.12) {
			color = shard <= 0.0 ? E_BLACK : (shard > 0.5 ? E_EMBER : E_GOLD);
			a = 1.0;
		}
	}
	// L'éclair de la couronne reforgée.
	float flash = smoothstep(0.78, 0.86, t) * (1.0 - smoothstep(0.88, 1.0, t));
	vec2 e = p - c;
	float star = 0.6 * flash - length(e * vec2(1.0, 1.6)) - abs(sin(atan(e.y, e.x) * 5.0)) * 0.22;
	if (star > 0.0) {
		color = star > 0.14 ? E_PALE : E_EMBER;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
