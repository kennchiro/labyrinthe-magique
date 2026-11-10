shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLIPSE, tant que les coups la traversent : derrière elle, un disque bleu nuit cerclé d'une couronne d'argent
// à longs rayons, qui tourne lentement. Le disque reste derrière son corps : on la voit toujours.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 c = p - vec2(0.0, -0.15);
	float d = length(c);
	float born = smoothstep(0.0, 0.12, progress) * (1.0 - smoothstep(0.85, 1.0, progress));
	float a = atan(c.y, c.x) + TIME * 0.5;
	float spikes = pow(abs(cos(a * 6.0)), 6.0) * r_glow(d - 0.6, 0.35) * step(0.6, d);
	vec4 color = vec4(R_BLUE, spikes * 0.6);
	color = r_over(vec4(R_SHINE, smoothstep(0.05, 0.0, abs(d - 0.6))), color);
	color = r_over(vec4(R_SILVER, smoothstep(0.12, 0.0, abs(d - 0.6)) * 0.5), color);
	color = r_over(vec4(R_DEEP, smoothstep(0.58, 0.55, d) * 0.55), color);
	color.a *= born;
	COLOR = color;
}
