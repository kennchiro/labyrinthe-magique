shader_type canvas_item;
render_mode blend_mix;

// LE SILLON DE SOUFRE : le sol se fend, et des flammes hautes en sortent, noires au bord, cramoisies
// et à cœur d'or. Elles ondulent tant que la zone tient, crachent des braises, puis se tassent.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 0.5;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float EMBERS = 5.0;
const float BASE = 0.8;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = BLACK;
	float alpha = 0.0;
	float rise = 1.0 - pow(1.0 - clamp(phase / 0.2, 0.0, 1.0), 3.0);
	float close = smoothstep(0.18, 0.0, life);
	float height = mix(1.75, 1.2, smoothstep(0.2, 0.7, phase)) * rise * (1.0 - close);
	// La fente au sol, noire à bord rouge.
	vec2 g = vec2(p.x, (p.y - BASE + 0.06) * 3.2);
	float crack = 0.82 * rise - length(g) + 0.07 * abs(sin(p.x * 11.0 + seed * 7.0));
	if (crack > 0.0) {
		color = mix(CRIMSON, BLACK, smoothstep(0.0, 0.1, crack));
		alpha = 1.0;
	}
	float wave = texture(noise, vec2(p.x * 0.5 + seed, phase * 0.9 - p.y * 0.25)).r - 0.5;
	float tongues = abs(fract(p.x * 1.6 + seed + wave + sin(phase * 7.0 + p.y * 3.0) * 0.08) - 0.5) * 2.0;
	float top = BASE - height * max(1.0 - p.x * p.x, 0.0) * (0.45 + tongues * 0.55 + wave * 0.5);
	float flame = min(p.y - top, BASE - p.y);
	if (flame > -0.01) {
		vec3 inside = mix(BLACK, DEEP, smoothstep(0.03, 0.08, flame));
		inside = mix(inside, CRIMSON, smoothstep(0.1, 0.2, flame));
		inside = mix(inside, GOLD, smoothstep(0.32, 0.4, flame));
		inside = mix(inside, PALE, smoothstep(0.5, 0.56, flame));
		color = mix(BLACK, inside, smoothstep(0.0, 0.03, flame));
		alpha = smoothstep(-0.01, 0.0, flame);
	}
	for (int i = 0; i < int(EMBERS); i++) {
		float f = float(i);
		float run = fract(hash(f) + phase * (0.7 + hash(f + 1.0) * 0.5));
		vec2 at = vec2((hash(f + 2.0) - 0.5) * 1.3 + sin(run * 6.0 + f) * 0.08, BASE - run * 1.7);
		vec2 d = abs(p - at);
		float ember = 0.07 * (1.0 - run) * (1.0 - close) - (d.x + d.y);
		if (ember > 0.0 && alpha < 0.5) {
			color = PALE;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
