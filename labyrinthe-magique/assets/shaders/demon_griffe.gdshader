shader_type canvas_item;
render_mode blend_mix;

// LA GRIFFE DE SANG : trois griffures qui s'effilent vers l'arrière, cœur pâle, chair cramoisie et
// cerne noir, légèrement courbes. Derrière elles traînent des gouttes et de petits éclats d'or.

uniform float seed = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float TRAIL = 7.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	float y = (UV.y - 0.5) * 2.0;
	float best = -1.0;
	for (int i = 0; i < 3; i++) {
		float rank = float(i) - 1.0;
		float along = UV.x + abs(rank) * 0.1;
		float width = 0.17 * along * (1.0 - smoothstep(0.84, 1.0, along));
		float line = y - rank * (0.26 + 0.36 * UV.x) - 0.12 * sin(UV.x * 3.14 + seed);
		best = max(best, width - abs(line));
	}
	vec3 color = mix(CRIMSON, PALE, smoothstep(0.05, 0.085, best));
	color = mix(DEEP, color, smoothstep(0.012, 0.03, best));
	color = mix(BLACK, color, smoothstep(0.0, 0.014, best));
	float alpha = smoothstep(-0.008, 0.0, best);
	// La traînée : les gouttes reculent et rapetissent, avec un éclat d'or sur trois.
	for (int i = 0; i < int(TRAIL); i++) {
		float f = float(i);
		float run = fract(hash(f) + TIME * (1.6 + hash(f + 1.0)));
		vec2 at = vec2(0.5 - run * 0.5, 0.5 + (hash(f + 2.0) - 0.5) * 0.8);
		vec2 d = (UV - at) * vec2(1.75, 1.0);
		float size = 0.042 * (1.0 - run);
		bool spark = mod(f, 3.0) < 0.5;
		float shape = spark ? size - (abs(d.x) + abs(d.y)) : size - length(d * vec2(0.55, 1.0));
		if (shape > 0.0 && alpha < 0.5) {
			color = spark ? PALE : CRIMSON;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
