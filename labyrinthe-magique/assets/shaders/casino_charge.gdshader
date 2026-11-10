shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DU MAÎTRE DU CASINO : un jeu de cartes s'envole en spirale autour de lui en se resserrant, les
// cartes se retournent une à une (dos rouge, puis face blanche), puis un éclat d'or claque au-dessus de sa tête.

#include "res://assets/shaders/casino.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float r = mix(0.85, 0.4, smoothstep(0.0, 0.75, t));
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ang = f * TAU / 10.0 + t * 6.0;
		vec2 at = vec2(cos(ang) * r, sin(ang) * r * 0.45 + 0.3 - f * 0.06);
		vec2 q = k_rot(p - at, ang * 0.5);
		float flip = abs(cos(t * 9.0 + f));
		vec3 c = color;
		if (k_paint_card(vec2(q.x / max(flip, 0.15), q.y), 0.07, 0.1, f / 10.0 > t * 1.3, c)) {
			color = c;
			a = 1.0;
		}
	}
	float flash = smoothstep(0.78, 0.86, t) * (1.0 - smoothstep(0.88, 1.0, t));
	vec2 e = p - vec2(0.0, -0.65);
	float star = 0.55 * flash - length(e) - abs(sin(atan(e.y, e.x) * 4.0)) * 0.22;
	if (star > 0.0) {
		color = star > 0.14 ? K_WHITE : K_GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
