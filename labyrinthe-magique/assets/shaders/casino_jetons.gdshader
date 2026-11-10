shader_type canvas_item;
render_mode blend_mix;

// LA MAISON GAGNE TOUJOURS : un Coup de chance paie. Un éclair d'or, puis une gerbe de jetons d'or jaillit de la cible
// en arc et retombe sur ses voisins en tournant.

#include "res://assets/shaders/casino.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float flash = 0.5 * (1.0 - smoothstep(0.0, 0.25, t)) - length(p) - abs(sin(atan(p.y, p.x) * 4.0)) * 0.2;
	if (flash > 0.0) {
		color = flash > 0.12 ? K_WHITE : K_GOLD;
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float ang = f * TAU / 10.0 + k_hash(f, seed) * 0.4;
		float reach = smoothstep(0.0, 0.8, t) * (0.5 + k_hash(f + 1.0, seed) * 0.4);
		float lift = sin(clamp(t * 1.3, 0.0, 1.0) * 3.14159) * 0.35;
		vec2 at = vec2(cos(ang) * reach, sin(ang) * reach * 0.6 - lift);
		vec2 q = vec2((p - at).x / max(abs(cos(t * 12.0 + f)), 0.2), (p - at).y);
		vec3 c = color;
		if (t < 0.95 && k_paint_chip(q, 0.07 * (1.0 - smoothstep(0.8, 0.95, t)), c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
