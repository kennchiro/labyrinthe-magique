shader_type canvas_item;
render_mode blend_mix;

// LE MIASME, le trait du Seigneur du Fléau : un anneau de fumée verte basse tourne à ses pieds pendant toute la
// minute, à bord franc, avec des bulles qui crèvent. Ce qui y entre s'empoisonne.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 2.2);
	float show = smoothstep(0.0, 0.01, progress) * (1.0 - smoothstep(0.97, 1.0, progress));
	float d = length(g);
	float ang = atan(g.y, g.x);
	vec3 color = F_SHADE;
	float a = 0.0;
	// Des volutes qui tournent : un bruit lu en coordonnées polaires, qui avance avec le temps.
	float swirl = texture(noise, vec2(ang / TAU * 3.0 - TIME * 0.12, d * 1.4 - TIME * 0.05) + seed).r;
	// Un anneau, jamais un disque : à l'intérieur, on doit voir ses pieds et le sol.
	float ring = 0.06 + 0.14 * swirl - abs(d - 0.66);
	if (ring > 0.0) {
		color = ring > 0.12 ? F_BRIGHT : (ring > 0.06 ? F_VENOM : F_SHADE);
		a = ring > 0.03 ? 0.6 : 0.4;
	}
	if (ring > -0.02 && ring <= 0.0) {
		color = F_RIM;
		a = 0.35;
	}
	// Les bulles qui crèvent sur l'anneau.
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float life = fract(TIME * 0.7 + f * 0.37);
		float ca = f * 1.7 + floor(TIME * 0.7 + f * 0.37) * 2.3;
		vec2 at = vec2(cos(ca), sin(ca)) * 0.62;
		float r = 0.08 * life;
		if (abs(length(g - at) - r) < 0.018 && life < 0.9) {
			color = F_CORE;
			a = 0.9;
		}
	}
	COLOR = vec4(color, a * show);
}
