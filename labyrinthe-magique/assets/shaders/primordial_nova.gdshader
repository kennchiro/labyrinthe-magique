shader_type canvas_item;
render_mode blend_mix;

// LA LUMIÈRE DE L'ORIGINE : un blanc d'or qui part de lui et balaie l'écran, avec des rayons, et un front aux quatre
// couleurs des éléments.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float front = mix(0.05, 0.95, sqrt(t));
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	// L'intérieur : un blanc d'or qui s'éclaircit.
	float inside_light = step(d, front) * (0.35 + 0.4 * p_glow(d, front + 0.01));
	vec4 color = vec4(mix(P_GOLD_LIGHT, P_WHITE, p_glow(d, front + 0.01)), inside_light * fade);
	// Les rayons.
	float beam = pow(abs(sin(ang * 12.0 + seed * 3.0)), 10.0) * step(d, front * 1.1);
	color = p_over(vec4(P_WHITE, beam * 0.6 * fade), color);
	// Le front : quatre quartiers, un par élément.
	int k = int(mod(floor((ang + PI) / TAU * 4.0 + 0.5), 4.0));
	float band = 0.06 - abs(d - front);
	if (band > 0.0) {
		color = p_over(vec4(mix(p_element(k), P_WHITE, band / 0.12), fade), color);
	}
	COLOR = color;
}
