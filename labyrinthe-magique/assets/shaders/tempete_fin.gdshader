shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'AVATAR : la foudre le quitte en un dernier éclair qui remonte vers le ciel, et des
// étincelles retombent autour de lui.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = T_BLUE;
	float a = 0.0;
	float flick = floor(TIME * 16.0);
	// L'éclair qui remonte : son pied quitte le mage et file vers le haut.
	float rise = smoothstep(0.0, 0.35, t);
	float fade = 1.0 - smoothstep(0.35, 0.6, t);
	// u monte vers le haut de l'écran ; le pied de l'éclair part de lui et file vers le haut.
	float foot = -0.1 + rise * 1.4;
	vec2 q = vec2(-p.y - foot, p.x);
	float bolt = t_bolt(q, 0.8, 0.07 * fade, 0.3, seed, flick);
	if (bolt > -0.02 && fade > 0.0) {
		color = bolt <= 0.0 ? T_RIM : t_bolt_color(bolt / 0.07);
		a = 1.0;
	}
	// Les étincelles qui retombent.
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float k = smoothstep(0.1, 0.9, t);
		float ang = f / 8.0 * TAU + seed;
		vec2 c = vec2(cos(ang) * (0.2 + 0.5 * k), -0.2 + sin(ang) * 0.3 * k + k * k * 0.6);
		float spark = t_star(p - c, 0.08 * (1.0 - k), 4.0, 6.0);
		if (spark > -0.01 && k < 1.0) {
			color = spark <= 0.0 ? T_RIM : (mod(f, 2.0) == 0.0 ? T_YELLOW : T_WHITE);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
