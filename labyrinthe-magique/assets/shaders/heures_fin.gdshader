shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DU SEIGNEUR DES HEURES : le cadran autour de lui se fend en douze éclats qui s'envolent,
// et ses aiguilles tombent.

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
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	// Chaque heure du cadran est un éclat qui part vers l'extérieur en tournant.
	float ang = atan(p.y, p.x);
	float slot = floor(ang / TAU * 12.0 + 0.5);
	float mid = slot / 12.0 * TAU;
	float push = t * (0.4 + h_hash(slot, 2.0) * 0.5);
	vec2 dir = vec2(cos(mid), sin(mid));
	vec2 q = p - dir * push;
	q = h_rot(q - dir * 0.6, t * (h_hash(slot, 5.0) - 0.5) * 6.0) + dir * 0.6;
	float qa = atan(q.y, q.x);
	if (abs(fract(qa / TAU * 12.0 + 0.5) - 0.5) < 0.42 - t * 0.2) {
		if (h_dial(q, 0.6, 0.08, 0.0, color)) {
			a = fade;
		}
	}
	// Les aiguilles tombent.
	vec2 fall = p - vec2(0.0, t * t * 0.9);
	float hand = h_hand(fall, -1.57 + t * 2.0, 0.45, 0.05);
	if (h_paint_hand(hand, 0.05, color)) {
		a = fade;
	}
	hand = h_hand(fall, 0.4 - t * 3.0, 0.3, 0.06);
	if (h_paint_hand(hand, 0.06, color)) {
		a = fade;
	}
	float flash = 1.0 - smoothstep(0.0, 0.2, t);
	if (length(p) < 0.5 * flash) {
		color = H_PALE;
		a = max(a, flash * 0.8);
	}
	COLOR = vec4(color, a);
}
