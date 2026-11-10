shader_type canvas_item;
render_mode blend_mix;

// LE PETIT ASTRE, toute la minute : une étoile blanche tourne autour d'elle en ellipse, avec une fine traînée
// bleue. Elle passe derrière son corps sur la moitié haute de l'ellipse (plus pâle).

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float born = smoothstep(0.0, 0.02, progress) * (1.0 - smoothstep(0.985, 1.0, progress));
	float now = TIME * 2.2;
	vec4 color = vec4(0.0);
	for (int i = 9; i >= 1; i--) {
		float back = now - float(i) * 0.07;
		vec2 at = vec2(cos(back) * 0.78, sin(back) * 0.28 - 0.1);
		float fade = 1.0 - float(i) / 10.0;
		color = r_over(vec4(R_BLUE, r_glow(length(p - at), 0.07 * fade) * fade * 0.8), color);
	}
	vec2 head = vec2(cos(now) * 0.78, sin(now) * 0.28 - 0.1);
	float front = 0.55 + 0.45 * step(0.0, sin(now));
	color = r_over(r_star(p - head, 0.13, now * 3.0, front), color);
	color = r_over(vec4(R_SHINE, r_glow(length(p - head), 0.18) * 0.35 * front), color);
	color.a *= born;
	COLOR = color;
}
