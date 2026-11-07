shader_type canvas_item;
// Le Croupier des Enfers : recoloré depuis braise_traine, or, bordeaux et noir.
render_mode blend_mix;

// LE POING EN VOL : trois langues de flamme à plages nettes, qui claquent derrière lui.
// Le poing lui-même est un sprite posé par `Level` : ce dessin n'est que sa traînée.

uniform float seed = 0.0;
uniform sampler2D noise;

const vec3 PALE = vec3(1.0, 0.949, 0.769);
const vec3 EMBER = vec3(0.91, 0.71, 0.29);
const vec3 LAVA = vec3(0.788, 0.635, 0.153);
const vec3 DEEP = vec3(0.478, 0.059, 0.078);
const vec3 BLACK = vec3(0.082, 0.063, 0.059);

void fragment() {
	vec2 p = UV;
	float t = TIME * 5.0 + seed * 9.0;
	float a = 0.0;
	vec3 color = EMBER;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float y = 0.5 + (f - 1.0) * 0.22 * (1.0 - p.x);
		float wave = sin(p.x * 11.0 - t * 2.0 + f * 2.1) * 0.05 * (1.0 - p.x);
		float width = 0.2 * p.x * p.x * (1.0 - f * 0.12);
		float d = width - abs(p.y - y - wave);
		if (d > 0.0) {
			a = 1.0;
			color = d > width * 0.55 ? PALE : (d > width * 0.25 ? EMBER : LAVA);
		}
	}
	if (a > 0.0 && p.x < 0.25) {
		color = DEEP;
	}
	COLOR = vec4(color, a);
}
