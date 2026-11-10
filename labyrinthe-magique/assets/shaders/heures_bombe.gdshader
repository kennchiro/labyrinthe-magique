shader_type canvas_item;
render_mode blend_mix;

// LA BOMBE-HORLOGE du Saut temporel : un réveil de cuivre posé au sol, cadran d'émail, deux cloches. Son
// aiguille fait le tour une fois, il tremble de plus en plus, et un cercle sarcelle bat au sol de plus en plus
// vite, au rayon de la sonnerie.

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
	// Le cercle d'alerte au sol, au rayon du sort : il bat, de plus en plus vite.
	vec2 g = p * vec2(1.0, 2.0);
	float beat = fract(t * t * 9.0);
	float alert = 0.02 + 0.02 * (1.0 - beat) - abs(length(g) - 0.8);
	if (alert > 0.0) {
		color = mix(H_BRIGHT, H_WHITE, 1.0 - beat);
		a = 0.5 + 0.5 * (1.0 - beat);
	}
	if (length(g) < 0.8) {
		a = max(a, 0.1 + 0.15 * (1.0 - beat));
	}
	// Le réveil, qui tremble.
	vec2 c = p - vec2(sin(TIME * 70.0) * 0.012 * t * 2.0, -0.18);
	float body = 0.2 - length(c);
	for (int s = -1; s <= 1; s += 2) {
		vec2 b = c - vec2(float(s) * 0.15, -0.2);
		float bell = 0.08 - length(b * vec2(1.0, 1.3));
		if (bell > -0.012) {
			color = bell <= 0.0 ? H_RIM : (bell > 0.05 ? H_LIGHT : H_COPPER);
			a = 1.0;
		}
		vec2 leg = c - vec2(float(s) * 0.12, 0.2);
		if (abs(leg.x - float(s) * leg.y * 0.4) < 0.025 && leg.y > 0.0 && leg.y < 0.1) {
			color = H_RIM;
			a = 1.0;
		}
	}
	if (body > -0.014) {
		color = body <= 0.0 ? H_RIM : (body < 0.04 ? H_COPPER : H_WHITE);
		a = 1.0;
		if (body > 0.04) {
			float hours = fract(atan(c.y, c.x) / TAU * 12.0 + 0.5) - 0.5;
			if (abs(hours) < 0.1 && body < 0.07) {
				color = H_TEAL;
			}
			float hand = h_hand(c, -1.5708 + t * TAU, 0.13, 0.018);
			if (hand > 0.0) {
				color = hand > 0.008 ? H_BRIGHT : H_TEAL;
			}
			if (length(c) < 0.022) {
				color = H_RIM;
			}
		}
	}
	COLOR = vec4(color, a);
}
