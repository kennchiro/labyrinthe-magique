shader_type canvas_item;
render_mode blend_mix;

// LE DISQUE SOLAIRE, toute la minute : il tourne lentement derrière lui, ses rayons battent. Posé sous le mage.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

uniform float fade = 1.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float born = smoothstep(0.0, 0.03, progress);
	float pulse = 0.85 + 0.15 * sin(TIME * 2.4);
	vec4 color = vec4(0.0);
	float beams = pow(abs(cos(ang * 6.0 + TIME * 0.5)), 8.0) * a_glow(d, 0.95 * pulse) * step(0.42, d);
	color = a_over(vec4(A_GOLD_LIGHT, beams * 0.55), color);
	float ring = smoothstep(0.05, 0.0, abs(d - 0.45)) ;
	color = a_over(vec4(mix(A_GOLD, A_WHITE, 0.3), ring * 0.85), color);
	float disc = a_glow(d, 0.45) * 0.22;
	color = a_over(vec4(A_GOLD_LIGHT, disc), color);
	color.a *= born * fade;
	COLOR = color;
}
