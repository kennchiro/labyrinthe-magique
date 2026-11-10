shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL : les rayons rentrent dans le disque, qui pâlit et s'éteint.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float reach = mix(1.0, 0.2, t);
	float beams = pow(abs(cos(ang * 6.0)), 10.0) * a_glow(d, reach);
	vec4 color = vec4(A_GOLD_LIGHT, beams * (1.0 - t) * 0.8);
	color = a_over(vec4(A_WHITE, a_glow(d, 0.3) * (1.0 - t)), color);
	COLOR = color;
}
