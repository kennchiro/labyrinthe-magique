shader_type canvas_item;
render_mode blend_mix;

// LA SONNERIE de la bombe-horloge : un éclair sarcelle, trois cadrans qui s'ouvrent l'un après l'autre jusqu'au
// rayon du sort, et les traits de la sonnerie qui vibrent tout autour. Ce qui s'y trouve est figé.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = H_TEAL;
	float a = 0.0;
	float d = length(p);
	float fade = 1.0 - smoothstep(0.6, 1.0, t);
	float flash = 1.0 - smoothstep(0.0, 0.25, t);
	if (d < 0.8) {
		color = mix(H_PALE, H_BRIGHT, d / 0.8);
		a = flash * (1.0 - d / 0.8);
	}
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float k = clamp((t - f * 0.08) / 0.4, 0.0, 1.0);
		float grow = 1.0 - pow(1.0 - k, 3.0);
		if (k > 0.0 && h_dial(p, 0.8 * grow, 0.06 - f * 0.012, f * 0.5 + t * 2.0, color)) {
			a = fade;
		}
	}
	// Les traits de la sonnerie : seize éclats qui vibrent hors du cadran.
	float ang = atan(p.y, p.x);
	float slot = fract(ang / TAU * 16.0) - 0.5;
	float shake = sin(TIME * 60.0 + floor(ang / TAU * 16.0) * 2.0) * 0.015;
	float reach = 0.86 + t * 0.12;
	if (abs(slot + shake * 8.0) < 0.07 && d > reach - 0.02 && d < reach + 0.1 * fade) {
		color = H_GOLD;
		a = fade;
	}
	COLOR = vec4(color, a);
}
