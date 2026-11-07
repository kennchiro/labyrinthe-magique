shader_type canvas_item;
render_mode blend_mix;

// LES CHARGES DE SURTENSION, au-dessus de sa tête : une petite étoile jaune par charge, qui tournent en
// couronne. À la cinquième, elles battent : la prochaine attaque appellera la foudre.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float charges = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = T_YELLOW;
	float a = 0.0;
	float full = charges >= 5.0 ? 1.0 : 0.0;
	float beat = full * (0.5 + 0.5 * sin(TIME * 12.0));
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		if (f >= charges) {
			continue;
		}
		float ang = TIME * 2.0 + f / 5.0 * TAU;
		vec2 c = vec2(cos(ang) * 0.6, sin(ang) * 0.22);
		float star = t_star(p - c, 0.2 * (1.0 + 0.3 * beat), 5.0, 3.0);
		if (star > -0.03) {
			color = star <= 0.0 ? T_RIM : (star > 0.07 + 0.03 * beat ? T_WHITE : T_YELLOW);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
