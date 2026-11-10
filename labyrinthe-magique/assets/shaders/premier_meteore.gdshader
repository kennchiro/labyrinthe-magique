shader_type canvas_item;
render_mode blend_mix;

// LE MÉTÉORE : une boule de lave tombe en biais du haut du quad dans une traînée de feu, s'écrase, et une colonne de
// flammes jaillit du point d'impact. Quad haut : l'impact est au bas du quad.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	vec2 impact = vec2(0.0, 0.62);
	float fall = clamp(t / 0.3, 0.0, 1.0);
	vec2 start = vec2(-0.7, -1.0);
	vec2 at = mix(start, impact, fall * fall);
	// La traînée.
	if (fall < 1.0) {
		vec2 dir = normalize(impact - start);
		float along = dot(p - at, -dir);
		float side = abs(dot(p - at, vec2(-dir.y, dir.x)));
		float w = 0.1 * (1.0 - along / 0.8);
		if (along > 0.0 && along < 0.8 && side < w) {
			color = side < w * 0.4 ? P_YELLOW : P_MAGMA;
			a = 1.0;
		}
		float ball = 0.12 - length(p - at);
		if (ball > -0.02) {
			color = ball <= 0.0 ? P_OBSIDIAN : (ball > 0.06 ? P_CORE : P_MAGMA);
			a = 1.0;
		}
	}
	// La colonne de flammes à l'impact.
	float burst = smoothstep(0.3, 0.45, t) * (1.0 - smoothstep(0.7, 1.0, t));
	vec3 c = color;
	if (burst > 0.02 && p_paint_tongue(p - impact, 0.28 * burst, 1.2 * burst, c)) {
		color = c;
		a = 1.0;
	}
	vec2 g = (p - impact) * vec2(1.0, 2.6);
	float ring = 0.04 * burst - abs(length(g) - 0.6 * burst);
	if (ring > 0.0) {
		color = P_YELLOW;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
