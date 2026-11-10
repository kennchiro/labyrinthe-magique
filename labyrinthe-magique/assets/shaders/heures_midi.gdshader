shader_type canvas_item;
render_mode blend_mix;

// MIDI SONNE, le coup du Jugement sur chaque créature : une aiguille d'or géante tombe du ciel, pointe en bas,
// se plante sur elle, et un cadran s'imprime au sol dans un éclair sarcelle, ses éclats partant tout autour.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = H_TEAL;
	float a = 0.0;
	float fall = clamp(t / 0.22, 0.0, 1.0);
	float hit = smoothstep(0.2, 0.26, t);
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	// L'impact : le cadran au sol, et l'éclair.
	vec2 g = (p - vec2(0.0, 0.25)) * vec2(1.0, 2.0);
	float grow = 1.0 - pow(1.0 - clamp((t - 0.22) / 0.3, 0.0, 1.0), 3.0);
	if (hit > 0.0 && h_dial(g, 0.75 * grow, 0.08, seed, color)) {
		a = fade;
	}
	float flash = hit * (1.0 - smoothstep(0.26, 0.5, t));
	float core = 0.7 * flash - length(g);
	if (core > 0.0) {
		color = mix(H_BRIGHT, H_WHITE, clamp(core * 3.0, 0.0, 1.0));
		a = max(a, flash);
	}
	// L'aiguille : elle tombe, se plante, reste un instant, puis s'efface.
	float tip_y = mix(-1.6, 0.25, fall * fall);
	vec2 q = vec2(p.x, p.y - tip_y);
	float hand = h_hand(q, -1.5708, 1.5, 0.09);
	float stay = 1.0 - smoothstep(0.5, 0.8, t);
	if (h_paint_hand(hand, 0.09, color) && stay > 0.0) {
		a = max(a, stay);
	}
	// La traîne de la chute.
	if (fall < 1.0 && abs(p.x) < 0.05 * (1.0 - fall) && p.y < tip_y - 1.5 && p.y > tip_y - 2.2) {
		color = H_PALE;
		a = max(a, 0.6);
	}
	// Les éclats.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ang = -f / 9.0 * PI;
		vec2 dir = vec2(cos(ang), sin(ang) * 0.6);
		float k = clamp((t - 0.22) / 0.6, 0.0, 1.0);
		vec2 at = vec2(0.0, 0.25) + dir * (0.15 + k * 0.85) + vec2(0.0, k * k * 0.4);
		float shard = 0.05 * (1.0 - k) - length(p - at);
		if (k > 0.0 && shard > -0.01) {
			color = shard <= 0.0 ? H_RIM : H_GOLD;
			a = max(a, 1.0 - k);
		}
	}
	COLOR = vec4(color, a);
}
