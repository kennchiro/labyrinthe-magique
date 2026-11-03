shader_type canvas_item;
render_mode blend_mix;

// LA GUEULE DU FOUR : le feu sort du sol sous la proie en langues hautes, dans un anneau de dents
// de métal qui claquent. C'est un lieu, pas un éclat : il tient toute la morsure.

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
	float t = progress;
	float open = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.9, 1.0, t));
	vec3 color = EMBER;
	float a = 0.0;
	vec2 g = vec2(p.x, (p.y - 0.35) * 2.4);
	float d = length(g);
	float angle = atan(g.y, g.x);
	float pit = 0.62 * open - d;
	if (pit > 0.0) {
		color = pit > 0.3 ? PALE : (pit > 0.15 ? EMBER : LAVA);
		a = 1.0;
	}
	float clack = 0.5 + 0.5 * cos(TIME * 16.0);
	float teeth = abs(fract(angle / 6.2832 * 14.0) - 0.5) * 2.0;
	float jaw = 0.62 * open + (1.0 - teeth) * 0.2 * (0.5 + clack * 0.5);
	if (d < jaw + 0.07 * open && d > 0.62 * open - 0.13 && open > 0.02) {
		color = d < jaw ? vec3(0.722, 0.525, 0.169) : BLACK;
		a = 1.0;
	}
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float x = (f - 3.0) * 0.17 + sin(TIME * 2.0 + f) * 0.03;
		float top = 0.35 - open * (0.45 + hash(f) * 0.55) * (0.75 + 0.25 * sin(TIME * (9.0 + f) + f * 2.0));
		float y = clamp((0.42 - p.y) / max(0.42 - top, 0.01), 0.0, 1.0);
		float wave = sin(p.y * 10.0 - TIME * 13.0 + f * 1.7) * 0.05 * y;
		float width = 0.11 * pow(1.0 - y, 0.7) * open;
		float flame = width - abs(p.x - x - wave);
		if (flame > 0.0 && p.y < 0.42) {
			color = flame > width * 0.55 ? PALE : (flame > width * 0.25 ? EMBER : LAVA);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
