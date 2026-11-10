shader_type canvas_item;
render_mode blend_mix;

// LA PLUME QUI TOMBE, debout : une grande plume blanche à pointe d'or, pointe en bas, tombe du haut du quad jusqu'au
// pied en tournoyant un peu, avec une traînée de lumière, puis se plante dans un éclat. SKY_GROUND = 0,97 : le sol tombe à 0,94.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float fall = smoothstep(0.0, 0.7, t);
	fall *= fall;
	vec2 tip = vec2(sin(t * 9.0 + seed) * 0.08 * (1.0 - fall), mix(-1.1, 0.94, fall));
	vec4 color = vec4(0.0);
	// La traînée.
	float trail = smoothstep(0.05, 0.0, abs(p.x - tip.x)) * step(p.y, tip.y - 0.4) * step(tip.y - 1.2, p.y) * (1.0 - smoothstep(0.7, 0.9, t));
	color = s_over(vec4(S_CORE, trail * 0.6), color);
	// La plume, pointe en bas : une amande blanche à tige d'or et pointe d'or, cernée.
	float sway = sin(t * 9.0 + seed) * 0.25 * (1.0 - fall);
	vec2 q = p - tip;
	q = vec2(q.x * cos(sway) - q.y * sin(sway), q.x * sin(sway) + q.y * cos(sway));
	float along = -q.y;
	float len = 0.75;
	float w = 0.2 * sin(clamp(along / len, 0.0, 1.0) * PI) * (0.6 + 0.4 * along / len);
	float alpha = 1.0 - smoothstep(0.85, 1.0, t);
	if (along > 0.0 && along < len && abs(q.x) < w + 0.02) {
		vec3 c = abs(q.x) > w ? S_RIM : (abs(q.x) < 0.015 ? S_GOLD : mix(S_WHITE, S_SHADE, abs(q.x) / max(0.01, w)));
		c = along < 0.12 && abs(q.x) <= w ? S_GOLD : c;
		color = s_over(vec4(c, alpha), color);
	}
	// L'éclat au sol.
	vec2 foot = p - vec2(0.0, 0.94);
	float burst = step(0.7, t) * (1.0 - smoothstep(0.7, 1.0, t));
	color = s_over(vec4(S_EMERALD, s_glow(length(vec2(foot.x, foot.y * 2.5)), 0.5) * burst), color);
	COLOR = color;
}
