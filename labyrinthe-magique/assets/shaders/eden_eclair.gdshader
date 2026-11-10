shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAIR À L'ARRIVÉE, debout : un éclair saphir à cœur blanc tombe du haut du quad jusqu'au sol en zigzag, éclate
// au pied en étoile, et laisse une flamme qui s'éteint.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

float bolt_x(float y, float s) {
	return (e_hash(floor(y * 7.0), s) - 0.5) * 0.35 * (1.0 - fract(y * 7.0)) + (e_hash(floor(y * 7.0) + 1.0, s) - 0.5) * 0.35 * fract(y * 7.0);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float reach = smoothstep(0.0, 0.15, t);
	float y = (p.y + 1.0) * 0.5;
	float strike = step(y, reach) * (1.0 - smoothstep(0.35, 0.7, t));
	float d = abs(p.x - bolt_x(y, seed + floor(t * 10.0) * 0.0));
	color = e_over(vec4(E_SAPPHIRE, smoothstep(0.09, 0.03, d) * strike), color);
	color = e_over(vec4(E_CORE, smoothstep(0.035, 0.0, d) * strike), color);
	vec2 foot = p - vec2(0.0, 0.9);
	float burst = (1.0 - smoothstep(0.12, 0.6, t)) * step(0.12, t);
	float star = pow(abs(cos(atan(foot.y, foot.x) * 3.0)), 8.0) * e_glow(length(foot), 0.7);
	color = e_over(vec4(E_CORE, star * burst), color);
	color = e_over(vec4(e_flame(0.7), e_glow(length(vec2(foot.x, foot.y * 2.0)), 0.5) * burst), color);
	COLOR = color;
}
