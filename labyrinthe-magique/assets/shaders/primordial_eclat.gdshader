shader_type canvas_item;
render_mode blend_mix;

// UN ÉCLAT DE LA CONVERGENCE : une comète de son élément qui file vers sa cible et s'y éteint. x le long du trajet.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform int kind = 0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float t = progress;
	float head = mix(0.06, 0.94, smoothstep(0.0, 0.55, t));
	float behind = head - x;
	float tail = 0.42;
	float body = behind >= 0.0 ? (1.0 - behind / tail) : (1.0 + behind / 0.05);
	float h = (body * 0.55 - y) * 1.6;
	vec4 color = paint_element(kind, vec2(x * 3.0 - t + seed, (UV.y - 0.5) * 0.8), TIME * 1.6, h);
	float spark = p_glow(length(vec2((x - head) * 3.0, y)), 0.35);
	color = p_over(vec4(mix(p_element(kind), P_WHITE, spark), spark), color);
	color.a *= 1.0 - smoothstep(0.6, 1.0, t);
	COLOR = color;
}
