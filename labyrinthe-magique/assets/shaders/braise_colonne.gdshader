shader_type canvas_item;
render_mode blend_mix;

// LE FEU DANS LA CAGE : il monte du sol à l'intérieur des barreaux pendant toute l'attente,
// et l'ennemi y disparaît peu à peu. `progress` le fait passer de la braise au brasier.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.851, 0.627);
const vec3 EMBER = vec3(1.0, 0.604, 0.122);
const vec3 LAVA = vec3(1.0, 0.478, 0.094);
const vec3 DEEP = vec3(0.541, 0.173, 0.031);
const vec3 BLACK = vec3(0.165, 0.129, 0.094);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = smoothstep(0.08, 1.0, progress);
	vec3 color = EMBER;
	float a = 0.0;
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float x = (f - 2.0) * 0.26;
		float top = 0.82 - t * (0.9 + hash(f) * 0.75) * (0.8 + 0.2 * sin(TIME * (8.0 + f) + f * 3.0));
		float y = clamp((0.86 - p.y) / max(0.86 - top, 0.01), 0.0, 1.0);
		float wave = sin(p.y * 8.0 - TIME * 11.0 + f * 2.0 + seed) * 0.06 * y;
		float width = 0.2 * pow(1.0 - y, 0.75);
		float flame = width - abs(p.x - x - wave);
		if (flame > 0.0 && p.y < 0.86) {
			color = flame > width * 0.6 ? PALE : (flame > width * 0.3 ? EMBER : LAVA);
			a = 0.9;
		}
	}
	vec2 g = vec2(p.x, (p.y - 0.84) * 4.0);
	if (0.42 + t * 0.12 - length(g) > 0.0) {
		color = t > 0.6 ? EMBER : LAVA;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
