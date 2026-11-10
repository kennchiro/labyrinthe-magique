shader_type canvas_item;
render_mode blend_mix;

// LES COUPS ACCUMULÉS du Jugement : au-dessus de la créature, un petit cadran se remplit d'or à mesure que ses
// coups s'y ajoutent (`fill`, part des PV qui lui restent). Plein, il bat et blanchit : midi la tuera.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float fill = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float lethal = step(1.0, fill);
	float beat = lethal * (0.5 + 0.5 * sin(TIME * 14.0));
	p /= 1.0 + beat * 0.08;
	float d = length(p);
	vec3 color = H_DEEP;
	float a = 0.0;
	float pop = smoothstep(0.0, 0.04, progress);
	if (d < 0.62 * pop) {
		color = H_DEEP;
		a = 0.75;
		// Le quartier rempli part de midi, dans le sens des aiguilles.
		float ang = mod(atan(p.y, p.x) + 1.5708, TAU) / TAU;
		if (ang < clamp(fill, 0.0, 1.0)) {
			color = mix(H_GOLD, H_LIGHT, d / 0.62);
			color = mix(color, H_WHITE, beat * 0.6);
			a = 1.0;
		}
	}
	if (h_dial(p, 0.7 * pop, 0.09, 0.0, color)) {
		a = 1.0;
	}
	float glow = 0.12 - abs(d - 0.86);
	if (glow > 0.0) {
		color = lethal > 0.5 ? H_LIGHT : H_BRIGHT;
		a = max(a, glow / 0.12 * (0.35 + beat * 0.6));
	}
	COLOR = vec4(color, a);
}
