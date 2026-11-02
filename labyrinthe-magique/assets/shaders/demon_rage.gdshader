shader_type canvas_item;
render_mode blend_mix;

// LA RAGE : un cercle de langues sombres sous ses pieds, qui grandit à chaque PV perdu. Rien à
// pleine vie. Plus elle monte, plus il bat vite et plus il crache de braises : à 1 PV, un filet d'or
// borde le cercle. Elle dit au joueur, sans chiffre, à quel point il tape fort.

uniform float seed = 0.0;
uniform float rage = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float EMBERS = 9.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x) + seed;
	float teeth = abs(fract(a * 11.0 / TAU + TIME * 0.35) - 0.5) * 2.0;
	float small_teeth = abs(fract(a * 23.0 / TAU - TIME * 0.5) - 0.5) * 2.0;
	float pulse = 0.04 * sin(TIME * (4.0 + rage * 6.0));
	float outer = (0.42 + 0.46 * rage) * (1.0 - teeth * 0.2 - small_teeth * 0.05) + pulse;
	float body = outer - d;
	// Le bord seul est plein : un disque entier cachait le sol, et ce qui s'y approche.
	float rim = 1.0 - smoothstep(0.05, 0.09, body);
	vec3 color = mix(DEEP, CRIMSON, rim);
	color = mix(BLACK, color, smoothstep(0.0, 0.016, body));
	color = mix(color, GOLD, smoothstep(0.86, 1.0, rage) * smoothstep(0.012, 0.0, abs(body - 0.035)));
	float alpha = smoothstep(-0.006, 0.0, body) * mix(mix(0.12, 0.28, rage), mix(0.55, 0.95, rage), rim);
	for (int i = 0; i < int(EMBERS); i++) {
		float f = float(i);
		if (hash(f + 9.0) > rage) {
			continue;
		}
		float run = fract(hash(f) + TIME * (0.45 + hash(f + 1.0) * 0.4));
		float angle = hash(f + 2.0) * TAU;
		vec2 at = vec2(cos(angle), sin(angle)) * outer * 0.85 * (1.0 + run * 0.15);
		at.y -= run * 0.28;
		vec2 q = abs(p - at);
		float ember = 0.04 * (1.0 - run) - (q.x + q.y);
		if (ember > 0.0) {
			color = PALE;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * step(0.001, rage) * COLOR.a);
}
