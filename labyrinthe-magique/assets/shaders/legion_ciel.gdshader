shader_type canvas_item;
render_mode blend_mix;

// L'APPEL DU ROI-DRAGON : le ciel s'assombrit sur tout l'écran et un sceau géant s'y ouvre, d'où le dragon
// surgit.

#include "res://assets/shaders/legion.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float veil = smoothstep(0.0, 0.15, t) * (1.0 - smoothstep(0.7, 1.0, t));
	vec3 color = L_VOID;
	float a = 0.5 * veil;
	float open = smoothstep(0.05, 0.3, t) * (1.0 - smoothstep(0.65, 0.95, t));
	// Le sceau, au-dessus du mage : assez fin pour ne pas couvrir l'écran (vu en jeu, à 0,34 il le noyait).
	vec2 sky = p - vec2(0.0, -0.12);
	if (l_seal(sky, 0.13 * open, 0.009, t * 2.0, 18.0, color)) {
		a = 0.85 * veil;
	}
	if (l_seal(sky, 0.085 * open, 0.006, -t * 3.0, 10.0, color)) {
		a = 0.85 * veil;
	}
	// L'œil de feu au centre du sceau.
	float core = 0.03 * open - length(sky * vec2(1.0, 2.2));
	if (core > -0.006) {
		color = core <= 0.0 ? L_RIM : (core > 0.04 ? L_FLAME : L_EMBER);
		a = veil;
	}
	COLOR = vec4(color, a);
}
