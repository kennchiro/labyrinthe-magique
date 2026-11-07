shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DE L'AVATAR : la foudre tombe du ciel sur lui, l'étoile blanche éclate, puis une onde
// électrique court au sol en crépitant, et des éclairs partent en étoile.

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
	// L'éclair du ciel, du haut du quad jusqu'à lui.
	float fall = smoothstep(0.0, 0.12, t);
	float fade = 1.0 - smoothstep(0.25, 0.45, t);
	vec2 q = vec2(p.y + 1.0, p.x);
	float bolt = t_bolt(q, 1.05 * fall, 0.09 * fade, 0.35, seed, flick);
	if (bolt > -0.03 && fade > 0.0) {
		color = bolt <= 0.0 ? T_RIM : t_bolt_color(bolt / 0.09);
		a = 1.0;
	}
	// L'onde au sol, aux bords en zigzag.
	vec2 g = p * vec2(1.0, 1.5);
	float gd = length(g);
	float wave = smoothstep(0.12, 0.75, t);
	float zig = 0.03 * sin(atan(g.y, g.x) * 18.0 + flick);
	float width = 0.05 * (1.0 - smoothstep(0.6, 1.0, t)) * step(0.12, t);
	float ring = width - abs(gd - (0.2 + wave * 0.72) - zig);
	if (ring > -0.015 && width > 0.0) {
		color = ring <= 0.0 ? T_RIM : (ring > width * 0.5 ? T_WHITE : T_BLUE);
		a = 1.0;
	}
	// Les éclairs en étoile, après le choc.
	float burst = smoothstep(0.12, 0.3, t) * (1.0 - smoothstep(0.55, 0.85, t));
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		vec2 r = t_rot(g, -(f / 6.0 * TAU + seed));
		float arm = t_bolt(r - vec2(0.15, 0.0), 0.75 * burst, 0.045, 0.25, f + 2.0, flick);
		if (arm > -0.015 && burst > 0.0) {
			color = arm <= 0.0 ? T_RIM : t_bolt_color(arm / 0.045);
			a = 1.0;
		}
	}
	float star = t_star(p, 0.55 * smoothstep(0.08, 0.14, t) * (1.0 - smoothstep(0.14, 0.32, t)), 8.0, 6.0);
	if (star > -0.02) {
		color = star <= 0.0 ? T_RIM : (star > 0.08 ? T_WHITE : T_YELLOW);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
