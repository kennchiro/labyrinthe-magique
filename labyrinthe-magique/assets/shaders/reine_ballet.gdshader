shader_type canvas_item;
render_mode blend_mix;

// LE BALLET DES PANTINS : elle tourne sur elle-même dans un tourbillon de fils d'argent et de rubans magenta, qui
// se resserre sur elle puis se défait. Aux deux bouts de l'échange.

#include "res://assets/shaders/reine.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	// Le tourbillon : une ellipse couchée par spire, qui monte autour d'elle.
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float y0 = 0.55 - f * 0.28;
		float r = (0.75 - f * 0.08) * (1.0 - 0.45 * smoothstep(0.2, 0.6, t)) * (0.6 + 0.4 * smoothstep(0.0, 0.2, t));
		vec2 g = (p - vec2(0.0, y0)) * vec2(1.0, 3.2);
		float d = length(g);
		float ang = atan(g.y, g.x) - t * 18.0 - f;
		float arc = fract(ang / TAU);
		float span = 0.6 * (1.0 - smoothstep(0.7, 1.0, t));
		float band = 0.035 - abs(d - r * 1.0);
		if (band > 0.0 && arc < span) {
			color = i % 2 == 0 ? (band > 0.02 ? R_PALE : R_SILVER) : R_MAGENTA;
			a = 1.0;
		} else if (band > -0.02 && arc < span) {
			color = R_BLACK;
			a = 1.0;
		}
	}
	// Des éclats émeraude jaillissent quand le tourbillon se défait.
	float burst = smoothstep(0.6, 0.75, t) * (1.0 - smoothstep(0.85, 1.0, t));
	for (int i = 0; i < 8; i++) {
		float ai = float(i) * TAU / 8.0 + seed;
		vec2 c = vec2(cos(ai), sin(ai) * 0.6) * (0.3 + t * 0.6);
		vec2 q = r_rot(p - c, ai);
		float shard = 0.05 * burst - (abs(q.x) * 0.5 + abs(q.y));
		if (shard > 0.0) {
			color = R_EMERALD;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
