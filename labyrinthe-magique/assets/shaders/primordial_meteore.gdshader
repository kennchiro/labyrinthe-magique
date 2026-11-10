shader_type canvas_item;
render_mode blend_mix;

// UNE MÉTÉORE DE LA GENÈSE TOUCHE LE SOL : une gerbe de la matière de son élément, et un anneau d'or qui court.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform int kind = 0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float front = mix(0.18, 0.66, sqrt(t));
	float ang = atan(p.y, p.x);
	float jag = texture(noise, vec2(ang * 0.4 + seed, t * 0.3)).r;
	float h = (front * (0.75 + 0.4 * jag) - d) * 2.0 * (1.0 - smoothstep(0.5, 1.0, t));
	vec4 color = paint_element(kind, vec2(d * 2.0 - t, ang * 0.5 + seed), TIME * 1.5 + seed, h);
	// ⚠️ Le bruit rallume de la matière au-delà du front : sans cette borne, la gerbe se coupait au bord du quad.
	color.a *= smoothstep(0.98, 0.84, d);
	float wave = 0.04 - abs(d - front);
	if (wave > 0.0) {
		color = p_over(vec4(P_GOLD_LIGHT, 1.0 - smoothstep(0.6, 1.0, t)), color);
	}
	float core = p_glow(d, 0.4) * (1.0 - smoothstep(0.0, 0.35, t));
	color = p_over(vec4(mix(p_element(kind), P_WHITE, core), core), color);
	COLOR = color;
}
