shader_type canvas_item;
render_mode blend_mix;

// FIGÉ PAR LE DÔME : la créature est prise dans une gangue de verre sarcelle, un petit cadran aux aiguilles
// arrêtées au-dessus de la tête. À la fin le verre se fend et vole en éclats.

#include "res://assets/shaders/heures.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = H_TEAL;
	float a = 0.0;
	float in_t = smoothstep(0.0, 0.08, t);
	float shatter = smoothstep(0.82, 1.0, t);
	// La gangue : une capsule de verre.
	vec2 q = vec2(p.x * 1.55, p.y + 0.12);
	vec2 box = abs(q) - vec2(0.42, 0.55) * in_t;
	float capsule = 0.25 - (length(max(box, 0.0)) + min(max(box.x, box.y), 0.0));
	float crack = texture(noise, p * 1.3 + seed).r;
	float gone = step(crack, shatter * 1.1);
	if (capsule > 0.0 && gone < 0.5) {
		color = mix(H_TEAL, H_BRIGHT, smoothstep(0.0, 0.2, 0.25 - capsule));
		a = 0.32 + smoothstep(0.18, 0.25, 0.25 - capsule + 0.18) * 0.4;
		if (abs(q.x + 0.25 - q.y * 0.2) < 0.04 && q.y < 0.2) {
			color = H_WHITE;
			a = 0.7;
		}
		if (smoothstep(0.015, 0.004, abs(crack - 0.5)) > 0.5) {
			color = H_PALE;
			a = 0.8;
		}
	}
	if (capsule > -0.02 && capsule <= 0.0 && gone < 0.5) {
		color = H_RIM;
		a = 0.8 * in_t;
	}
	// Le petit cadran arrêté, au-dessus de la tête.
	vec2 c = p - vec2(0.0, -0.86);
	float dc = length(c);
	if (dc < 0.13 * in_t) {
		color = H_WHITE;
		a = 1.0 - shatter;
	}
	if (h_dial(c, 0.15 * in_t, 0.035, 0.0, color)) {
		a = 1.0 - shatter;
	}
	float hand = h_hand(c, -1.57, 0.11, 0.022);
	if (h_paint_hand(hand, 0.022, color) && dc < 0.15) {
		a = 1.0 - shatter;
	}
	hand = h_hand(c, 0.35, 0.08, 0.026);
	if (h_paint_hand(hand, 0.026, color) && dc < 0.15) {
		a = 1.0 - shatter;
	}
	COLOR = vec4(color, a);
}
