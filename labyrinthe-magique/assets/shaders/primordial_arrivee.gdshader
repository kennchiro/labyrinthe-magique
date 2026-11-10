shader_type canvas_item;
render_mode blend_mix;

// LE PAS DES ÉLÉMENTS, À L'ARRIVÉE : l'anneau d'or s'imprime au sol, ses quatre runes s'allument d'un coup, et il
// se reforme dans un éclair blanc.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = (p - vec2(0.0, 0.3)) * vec2(1.0, 2.2);
	float grow = smoothstep(0.0, 0.3, t);
	vec4 ring = p_ring(g, 0.7 * grow, 0.06, -t * 2.0, vec4(1.0 - smoothstep(0.5, 1.0, t)));
	ring.a *= 1.0 - smoothstep(0.75, 1.0, t);
	vec4 color = ring;
	// La croix des quatre couleurs, qui part vers les rayons.
	for (int k = 0; k < 4; k++) {
		float ang = float(k) * TAU / 4.0 - TAU / 4.0;
		vec2 dir = vec2(cos(ang), sin(ang) / 2.2);
		float along = dot(p - vec2(0.0, 0.3), dir) / dot(dir, dir);
		float across = length((p - vec2(0.0, 0.3)) - dir * along);
		float arm = step(0.0, along) * step(along, 0.95) * clamp(1.0 - across / 0.07, 0.0, 1.0);
		color = p_over(vec4(p_element(k), arm * (1.0 - smoothstep(0.15, 0.45, t))), color);
	}
	float flash = p_glow(length(p - vec2(0.0, -0.1)), 0.5) * (1.0 - smoothstep(0.0, 0.4, t));
	color = p_over(vec4(mix(P_GOLD_LIGHT, P_WHITE, flash), flash), color);
	COLOR = color;
}
