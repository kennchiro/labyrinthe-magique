shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL : ses âmes s'envolent vers le haut et s'éteignent, l'auréole se refend.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		vec2 at = vec2((f_hash(f, seed) - 0.5) * 1.2, 0.3 - t * 1.4 - f_hash(f, 2.0) * 0.3);
		color = f_over(f_soul(p - at, 0.1, vec2(0.0, 1.0), 1.0 - t), color);
	}
	COLOR = color;
}
