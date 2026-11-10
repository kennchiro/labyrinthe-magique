shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLOSION DE L'ARCHIDÉMON : une mare de sang s'ouvre sous lui et bouillonne, une colonne de sang jaillit et
// retombe, puis la couronne d'éclaboussures part au sol, ses gouttes lancées tout autour.

#include "res://assets/shaders/archi.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_SHADE;
	float a = 0.0;
	vec2 g = (p - vec2(0.0, 0.35)) * vec2(1.0, 2.0);
	float dg = length(g);
	float ang = atan(g.y, g.x);
	float open = smoothstep(0.0, 0.2, t);
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	// La flaque, au bord en lobes.
	float lobe = 0.62 + 0.08 * sin(ang * 5.0 + seed * 9.0) + 0.05 * sin(ang * 9.0 + seed);
	float pool = lobe * open - dg;
	if (pool > -0.03) {
		color = pool <= 0.0 ? F_RIM : mix(F_VENOM, F_SHADE, smoothstep(0.0, 0.4, pool));
		float bubble = texture(noise, g * 1.5 + vec2(t * 0.6, 0.0) + seed).r;
		if (pool > 0.05 && abs(bubble - 0.55) < 0.025) {
			color = F_CORE;
		}
		a = fade;
	}
	// Le geyser : une colonne qui monte puis retombe.
	float rise = sin(clamp((t - 0.1) / 0.6, 0.0, 1.0) * PI);
	float top = 0.35 - rise * 1.25;
	float column = (0.13 + 0.04 * sin(p.y * 18.0 + t * 30.0)) * (0.4 + 0.6 * smoothstep(top, 0.35, p.y)) - abs(p.x);
	if (rise > 0.02 && p.y > top && p.y < 0.38 && column > -0.025) {
		color = column <= 0.0 ? F_RIM : (column > 0.08 ? F_CORE : (column > 0.04 ? F_BRIGHT : F_VENOM));
		a = 1.0;
	}
	if (rise > 0.02) {
		vec2 cap = p - vec2(0.0, top);
		float head = 0.17 * rise - length(cap * vec2(1.0, 1.3));
		if (head > -0.025) {
			color = head <= 0.0 ? F_RIM : (head > 0.08 ? F_CORE : F_BRIGHT);
			a = 1.0;
		}
	}
	// La couronne : douze gouttes lancées tout autour.
	float k = clamp((t - 0.35) / 0.6, 0.0, 1.0);
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float ca = f / 12.0 * TAU + seed;
		vec2 dir = vec2(cos(ca), sin(ca) * 0.5);
		vec2 at = vec2(0.0, 0.35) + dir * (0.5 + k * 0.5) + vec2(0.0, -sin(k * PI) * 0.35);
		vec3 drop_color = color;
		if (k > 0.0 && k < 1.0 && f_paint_drop(f_rot(p - at, -ca * 0.0), 0.06 * (1.0 - k * 0.5), drop_color)) {
			color = drop_color;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
