shader_type canvas_item;
render_mode blend_mix;

// L'APOTHÉOSE : une colonne de lumière le soulève, et une grande auréole d'or rayonnante s'ouvre derrière lui.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = smoothstep(0.0, 0.2, t) * (1.0 - smoothstep(0.75, 1.0, t));
	vec4 color = vec4(0.0);
	// Les rayons de l'auréole, derrière sa tête.
	vec2 h = p - vec2(0.0, -0.35);
	float dh = length(h);
	float ang = atan(h.y, h.x);
	float beam = pow(abs(sin(ang * 8.0 + TIME * 0.8)), 6.0) * p_glow(dh, 0.95) * step(0.5, dh);
	color = p_over(vec4(P_GOLD_LIGHT, beam * 0.75 * life), color);
	vec4 halo = p_ring(h, 0.48 * smoothstep(0.0, 0.3, t) + 0.02, 0.05, TIME * 0.7, vec4(1.0));
	halo.a *= life;
	color = p_over(halo, color);
	// La colonne.
	float column = clamp(1.0 - abs(p.x) / 0.3, 0.0, 1.0);
	column *= column * (1.0 - smoothstep(0.0, 0.5, t) * 0.6);
	color = p_over(vec4(mix(P_GOLD_LIGHT, P_WHITE, column), column * 0.8 * life), color);
	// Les étincelles qui montent.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float rise = fract(t * 1.6 + p_hash(f, seed));
		vec2 at = vec2((p_hash(f, 2.0) - 0.5) * 0.8, 0.8 - rise * 1.7);
		float s = p_glow(length(p - at), 0.06);
		color = p_over(vec4(P_WHITE, s * life), color);
	}
	COLOR = color;
}
