shader_type canvas_item;
// L'Avide : recoloré depuis braise_fissure, vert bile, os et noir d'encre.
render_mode blend_mix;

// LE SOL QUI SE FEND : des veines de lave courent depuis le centre en se brisant, restent
// ouvertes un instant, puis refroidissent du bord vers le centre.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.949, 1.0, 0.69);
const vec3 EMBER = vec3(0.784, 0.91, 0.188);
const vec3 LAVA = vec3(0.608, 0.761, 0.122);
const vec3 DEEP = vec3(0.353, 0.478, 0.071);
const vec3 BLACK = vec3(0.067, 0.063, 0.078);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

// Une ligne brisée, pas une courbe : c'est ce qui dit « roche fendue » et non « racine ».
float zigzag(float x) {
	return abs(fract(x) - 0.5) * 4.0 - 1.0;
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.5;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	float reach = smoothstep(0.0, 0.22, t) * 0.92;
	float cool = 1.0 - smoothstep(0.4, 1.0, t);
	vec3 color = LAVA;
	float a = 0.0;
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float dir = f / 8.0 * 6.283 + (hash(f) - 0.5) * 0.55;
		float bend = zigzag(d * (2.2 + hash(f + 1.0) * 2.5) + f * 0.37) * 0.22 * smoothstep(0.0, 0.2, d);
		float delta = abs(mod(angle - dir - bend + 3.1416, 6.2832) - 3.1416) * d;
		float width = 0.026 * (1.0 - d) * cool;
		float vein = width - delta;
		if (vein > -0.014 && d < reach && width > 0.0) {
			a = 1.0;
			color = vein > width * 0.45 ? PALE : (vein > 0.0 ? LAVA : BLACK);
		}
	}
	float core = 0.11 * (1.0 - smoothstep(0.0, 0.3, t)) - d;
	if (core > 0.0) {
		color = PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
