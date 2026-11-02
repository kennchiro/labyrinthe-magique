shader_type canvas_item;
render_mode blend_mix;

// LE CERCLE DE DISCORDE : un anneau d'argent se trace d'un seul trait, gradué, avec un filet magenta
// qui tourne en sens inverse. L'intérieur reste creux, seulement semé de fils en étoile : les liens
// entre les ennemis sont dessinés par le jeu. À la fin, l'anneau se rompt en arcs.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.945);
const vec3 SILVER = vec3(0.788, 0.824, 0.839);
const vec3 MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 DEEP = vec3(0.416, 0.059, 0.29);
const vec3 BLACK = vec3(0.086, 0.102, 0.11);
const float TICKS = 40.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float base = atan(p.y, p.x);
	float sweep = clamp(phase / 0.35, 0.0, 1.0);
	float traced = step(fract((base + 3.14159) / TAU), sweep);
	float breaking = smoothstep(0.22, 0.0, life);
	float chunks = abs(fract((base + seed * 6.0) * 5.0 / TAU) - 0.5) - 0.5 * breaking;
	float ring = min(0.024 - abs(d - 0.8), chunks);
	float a = base + phase * 0.55 + seed;
	float ticks = min(0.02 - abs(d - 0.88), abs(fract(a * TICKS / TAU) - 0.5) * 0.14 - 0.022);
	float back = base - phase * 0.9 + seed;
	float gaps = abs(fract(back * 3.82) - 0.5) - 0.13;
	float inner = min(0.014 - abs(d - 0.71), min(gaps, chunks));
	float line = max(ring, ticks) * traced;
	vec3 color = mix(BLACK, SILVER, smoothstep(0.0, 0.012, line));
	color = mix(color, PALE, smoothstep(0.016, 0.022, line));
	float alpha = smoothstep(-0.008, 0.0, line);
	if (inner > 0.0) {
		color = mix(DEEP, MAGENTA, smoothstep(0.0, 0.008, inner));
		alpha = 1.0;
	}
	float pulse = fract(phase * 0.8 + seed);
	float inward = 0.012 - abs(d - 0.78 * (1.0 - pulse));
	if (inward > 0.0 && pulse < 0.85 && life > 0.2 && alpha < 0.5) {
		color = MAGENTA;
		alpha = 0.9 * sweep;
	}
	for (int i = 0; i < 6; i++) {
		float angle = float(i) * TAU / 6.0 + phase * 1.5;
		vec2 s = abs(p - vec2(cos(angle), sin(angle)) * 0.8);
		float gem = (0.05 * (1.0 - breaking)) * sweep - (s.x + s.y);
		if (gem > -0.012) {
			color = gem > 0.0 ? PALE : BLACK;
			alpha = 1.0;
		}
	}
	// Le sol s'assombrit un peu, en plaques franches qui battent : on voit où le cercle mord.
	if (alpha < 0.5 && d < 0.8) {
		float web = abs(fract(base * 12.0 / TAU + seed) - 0.5) * d;
		float thread = 0.012 - web;
		float beat = 0.5 + 0.5 * sin(phase * 7.0 - d * 8.0);
		if (thread > 0.0 && d > 0.3) {
			color = mix(DEEP, MAGENTA, beat);
			alpha = 0.8 * sweep * (1.0 - breaking);
		} else if (d > 0.2) {
			color = DEEP;
			alpha = 0.16 * sweep * (1.0 - breaking);
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
