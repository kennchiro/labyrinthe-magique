shader_type canvas_item;
render_mode blend_mix;

// LA GRANDE CONVERGENCE ÉCLATE : un éclair blanc, puis l'onde d'or qui court, et les quatre bras des éléments qui
// s'ouvrent en grand avant de retomber.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float reach = mix(0.25, 0.85, sqrt(t));
	vec4 arms = pinwheel(p, TIME + seed, reach, t * 4.0, 2.2);
	arms.a *= (1.0 - smoothstep(0.45, 0.9, t)) * 0.85;
	vec4 color = arms;
	// L'onde d'or.
	float front = mix(0.15, 0.82, sqrt(t));
	float wave = 0.05 * (1.0 - t) - abs(d - front);
	if (wave > 0.0) {
		color = p_over(vec4(mix(P_GOLD, P_GOLD_LIGHT, wave / 0.05), 1.0 - smoothstep(0.7, 1.0, t)), color);
	}
	// Les runes de l'anneau qui se dilatent avec l'onde.
	vec4 ring = p_ring(p, front * 0.9, 0.035, t * 3.0, vec4(1.0));
	ring.a *= (1.0 - smoothstep(0.4, 0.7, t)) * step(0.06, t);
	color = p_over(ring, color);
	float flash = 1.0 - smoothstep(0.0, 0.3, t);
	float core = p_glow(d, 0.55 * (0.4 + t));
	color = p_over(vec4(mix(P_GOLD_LIGHT, P_WHITE, core), core * flash), color);
	COLOR = color;
}
