shader_type canvas_item;
render_mode blend_mix;

// LE GRAND TOUR DE MAGIE : un HAUT-DE-FORME géant tombe du ciel, l'engloutit, puis se soulève vide dans un nuage de
// cartes qui s'envolent en tournoyant.

#include "res://assets/shaders/casino.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float drop = smoothstep(0.0, 0.25, t);
	float lift = smoothstep(0.45, 0.75, t);
	float gone = 1.0 - smoothstep(0.75, 0.95, t);
	vec2 c = vec2(0.0, mix(-1.2, 0.1, drop) - lift * 0.9);
	vec2 q = p - c;
	float crown = min(0.32 - abs(q.x), min(q.y + 0.55, -q.y));
	float brim = min(0.55 - abs(q.x), 0.07 - abs(q.y - 0.02));
	float hat = max(crown, brim) * gone;
	if (hat > -0.02) {
		color = hat <= 0.0 ? K_BLACK : (abs(q.y + 0.12) < 0.07 && crown > 0.0 ? K_GOLD : K_BLACK * 1.8);
		a = 1.0;
	}
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float k = clamp((t - 0.45) / 0.5, 0.0, 1.0);
		float ang = f * TAU / 9.0 + k_hash(f, seed);
		vec2 at = vec2(cos(ang) * k * 0.8, 0.3 - k * 0.6 + sin(ang) * k * 0.3);
		vec2 cq = k_rot(p - at, ang + k * 6.0);
		vec3 cc = color;
		if (k > 0.0 && k < 1.0 && k_paint_card(cq, 0.06, 0.09, mod(f, 2.0) < 1.0, cc)) {
			color = cc;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
