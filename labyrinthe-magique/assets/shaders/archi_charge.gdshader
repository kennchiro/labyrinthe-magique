shader_type canvas_item;
render_mode blend_mix;

// LE GESTE D'ÉVEIL DE L'ARCHIDÉMON : trois volutes de sang montent en spirale autour de lui en se resserrant,
// des gouttes gonflent et éclatent à ses pieds, puis un éclair pâle : le pacte se resserre avant de céder.

#include "res://assets/shaders/archi.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_VENOM;
	float a = 0.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float reach = mix(0.95, 0.35, t);
	// Les volutes : trois bras qui s'enroulent vers le haut, à bord franc.
	float arm = fract((ang + d * 4.0 - t * 9.0) / TAU * 3.0);
	float wisp = texture(noise, p * 0.8 + vec2(0.0, t) + seed).r;
	float band = 0.2 + 0.1 * wisp - abs(arm - 0.5);
	if (d < reach && d > 0.12 && band > 0.0) {
		color = band > 0.12 ? F_BRIGHT : (band > 0.04 ? F_VENOM : F_SHADE);
		a = smoothstep(reach, reach - 0.2, d) * smoothstep(0.0, 0.15, t);
	}
	// Les bulles à ses pieds, sur une ellipse au sol.
	vec2 g = (p - vec2(0.0, 0.55)) * vec2(1.0, 2.2);
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float life = fract(t * 2.5 + f * 0.31);
		vec2 at = vec2(cos(f * 2.1), sin(f * 2.1)) * (0.25 + 0.35 * f_hash(f, 1.0));
		float r = 0.09 * life;
		float ring = 0.02 - abs(length(g - at) - r);
		if (ring > 0.0 && life < 0.92) {
			color = F_CORE;
			a = 1.0;
		} else if (length(g - at) < r) {
			color = F_VENOM;
			a = max(a, 0.6);
		}
	}
	float flash = smoothstep(0.8, 1.0, t);
	if (d < 0.45 * flash) {
		color = mix(F_CORE, F_BRIGHT, d / max(0.01, 0.45 * flash));
		a = max(a, flash * (1.0 - d / max(0.01, 0.45 * flash)));
	}
	COLOR = vec4(color, a);
}
