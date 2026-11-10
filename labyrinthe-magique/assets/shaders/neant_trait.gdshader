shader_type canvas_item;
render_mode blend_mix;

// LE COUP DE L'OMBRE, couché d'elle à sa cible : une lance noire au liseré violet qui file d'un bout à
// l'autre en ondulant, et laisse une traînée qui s'efface. UV.x va de l'ombre (0) à la cible (1).

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	vec3 color = N_VOID;
	float a = 0.0;
	float head = smoothstep(0.0, 0.55, t);
	float tail = smoothstep(0.3, 1.0, t);
	if (p.x < head && p.x > tail) {
		float centre = sin(p.x * 12.0 - TIME * 10.0 + seed) * 0.25 * (head - p.x);
		float w = 0.3 * (1.0 - (head - p.x) * 0.8);
		float band = w - abs(p.y - centre);
		if (band > -0.12) {
			color = band <= 0.0 ? N_VIOLET : N_VOID;
			a = 1.0;
		}
	}
	vec2 h = vec2((p.x - head) * 8.0, p.y);
	float tip = 0.5 - length(h);
	if (tip > -0.1 && t < 0.7) {
		color = tip <= 0.0 ? N_VIOLET : N_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
