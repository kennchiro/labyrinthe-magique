shader_type canvas_item;
render_mode blend_mix;

// L'ORBE DU NÉANT, le projectile : une éclipse qui file, une traînée de vrilles noires au liseré violet
// derrière elle, et un anneau qui tourne. UV.x va de la queue à la pointe.

#include "res://assets/shaders/neant.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const float LENGTH = 1.6;
const float HEIGHT = 0.8;

void fragment() {
	// Le quad fait 1,6 sur 0,8 : la hauteur est ramenée à la même échelle, sans quoi l'éclipse s'écrase.
	vec2 p = vec2((UV.x - 0.7) * LENGTH, (UV.y - 0.5) * HEIGHT);
	vec3 color = N_VOID;
	float a = 0.0;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		vec2 q = vec2(-p.x - 0.1, p.y - (f - 1.0) * 0.1);
		float tail = n_tendril(q, 0.75 - abs(f - 1.0) * 0.2, 0.08, 0.12, f + TIME * 2.0 + seed);
		if (tail > -0.02) {
			color = tail <= 0.0 ? N_VIOLET : (tail > 0.04 ? N_VOID : N_DEEP);
			a = 1.0;
		}
	}
	if (n_eclipse(p, 0.24, color)) {
		a = 1.0;
	}
	// Un éclat qui tourne sur l'anneau.
	float ang = atan(p.y, p.x) - TIME * 8.0;
	if (abs(length(p) - 0.27) < 0.03 && fract(ang / TAU) < 0.12) {
		color = N_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
