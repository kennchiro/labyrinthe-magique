shader_type canvas_item;
render_mode blend_mix;

// LE CRACHAT DU FLÉAU, le projectile : une grosse goutte de venin couchée, pointe vers l'arrière, cernée de vert
// sombre, reflet clair, suivie de gouttelettes qui se détachent. La tête est à droite.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;

void fragment() {
	vec3 color = F_VENOM;
	float a = 0.0;
	// En coordonnées de la goutte : la queue à gauche, la tête ronde à droite.
	vec2 q = vec2((UV.x - 0.78) * 2.6, (UV.y - 0.5) * 2.0);
	// `f_drop` pointe vers -y : on la couche, pointe vers -x.
	vec2 laid = vec2(q.y, q.x);
	vec3 body = color;
	if (f_paint_drop(laid, 0.5, body)) {
		color = body;
		a = 1.0;
	}
	// Les gouttelettes qui se détachent derrière.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float x = 0.45 - f * 0.12 - fract(TIME * 2.0 + f * 0.25) * 0.08;
		vec2 at = vec2(x, 0.5 + sin(f * 2.7 + seed * 5.0) * 0.18);
		vec2 dq = vec2((UV.x - at.x) * 2.6, (UV.y - at.y) * 2.0);
		vec3 small = color;
		if (f_paint_drop(vec2(dq.y, dq.x), 0.16 - f * 0.025, small)) {
			color = small;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * COLOR.a);
}
