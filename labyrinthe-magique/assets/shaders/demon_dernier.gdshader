shader_type canvas_item;
render_mode blend_mix;

// LE DERNIER PACTE, en cinq temps. Le bord tombe sur le rayon réel du sort.
//   1. L'APPEL : des filets de sang convergent de tout le cercle vers lui.
//   2. LE SCEAU d'or se trace au rayon du sort, double anneau, graduations et étoile à quatre pointes.
//   3. LA FENTE : quatre branches de lumière pâle fendent le sceau depuis le centre.
//   4. L'ÉCLATEMENT : un flash, une onde, et les éclats noirs du sceau partent vers le bord.
//   5. LA PLUIE : il ne reste que des gouttes qui tombent et des braises qui montent.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float EDGE = 0.8;
const float SHARDS = 14.0;
const float THREADS = 12.0;
const float RAIN = 12.0;
const float TICKS = 48.0;
const float CRACK_AT = 0.3;
const float BURST_AT = 0.42;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = 1.0 - pow(1.0 - clamp((progress - 0.05) / 0.2, 0.0, 1.0), 3.0);
	float cracked = smoothstep(CRACK_AT, BURST_AT, progress);
	float burst = smoothstep(BURST_AT, BURST_AT + 0.12, progress);
	float fade = smoothstep(0.62, 0.9, progress);
	float reach = EDGE * open;
	vec3 color = DEEP;
	float alpha = 0.34 * step(d, reach) * (1.0 - burst);
	// L'appel : chaque filet glisse du bord vers le centre.
	for (int i = 0; i < int(THREADS); i++) {
		float f = float(i);
		float angle = (f + hash(f) * 0.5) / THREADS * TAU;
		float run = clamp(progress / 0.28 - hash(f + 2.0) * 0.3, 0.0, 1.0);
		vec2 dir = vec2(cos(angle), sin(angle));
		float along = dot(p, dir);
		float across = abs(dot(p, vec2(-dir.y, dir.x)) + 0.04 * sin(along * 11.0 + f));
		float head = mix(EDGE, 0.05, run * run);
		float thread = 0.016 * smoothstep(EDGE, 0.1, along) + 0.004 - across;
		if (thread > 0.0 && along > head && along < min(head + 0.42, EDGE) && run > 0.0 && run < 1.0) {
			color = CRIMSON;
			alpha = 1.0;
		}
	}
	// Le sceau, qui tourne un peu avant de se fendre.
	float turned = a + progress * 1.2 * (1.0 - burst);
	float ring = 0.026 - abs(d - reach);
	float ring2 = 0.011 - abs(d - reach * 0.88);
	float ticks = min(0.022 - abs(d - reach * 0.94), abs(fract(turned * TICKS / TAU) - 0.5) * 0.12 - 0.012);
	float inner = 0.011 - abs(d - reach * 0.46);
	vec2 s = vec2(p.x * cos(turned - a) - p.y * sin(turned - a), p.x * sin(turned - a) + p.y * cos(turned - a));
	float star = 0.018 - abs(pow(abs(s.x), 0.6) + pow(abs(s.y), 0.6) - pow(max(reach * 0.72, 0.001), 0.6));
	float line = max(max(ring, ring2), max(ticks, max(inner, star)));
	// Le sceau se rompt en arcs : des trous s'y ouvrent à l'éclatement.
	line -= burst * step(0.55, fract(a * 5.0 / TAU + seed)) * 1.0;
	if (line > 0.0) {
		color = mix(GOLD, PALE, smoothstep(0.008, 0.018, line));
		alpha = 1.0;
	}
	// La fente.
	float rays = abs(sin(a * 2.0 + 0.785));
	float crack = 0.11 * cracked * (1.0 - d / EDGE) - rays * d * 0.62;
	if (cracked > 0.0 && crack > 0.0 && d < reach && d > 0.16) {
		color = mix(CRIMSON, PALE, smoothstep(0.0, 0.028, crack));
		alpha = 1.0;
	}
	// L'onde de l'éclatement.
	float wave_t = clamp((progress - BURST_AT) / 0.3, 0.0, 1.0);
	float wave = 0.05 * (1.0 - wave_t) - abs(d - EDGE * 1.05 * wave_t);
	if (wave_t > 0.0 && wave_t < 1.0 && wave > 0.0) {
		color = mix(CRIMSON, PALE, smoothstep(0.015, 0.03, wave));
		alpha = 1.0;
	}
	// Les éclats : un losange noir à bord cramoisi, plus une traînée derrière.
	for (int i = 0; i < int(SHARDS); i++) {
		float f = float(i);
		float angle = hash(f) * TAU;
		vec2 dir = vec2(cos(angle), sin(angle));
		float dist = 0.12 + burst * (0.48 + hash(f + 3.0) * 0.42) + wave_t * 0.08;
		vec2 q = p - dir * dist;
		vec2 r = vec2(dot(q, dir), dot(q, vec2(-dir.y, dir.x)));
		float small = 1.0 - fade * 0.8;
		float shard = 0.08 * small - (abs(r.x) * 0.55 + abs(r.y) * 1.5);
		if (burst > 0.0 && shard > 0.0) {
			color = mix(CRIMSON, BLACK, smoothstep(0.0, 0.016, shard));
			alpha = 1.0;
		}
		float streak = 0.012 * small * burst - abs(r.y);
		if (burst > 0.0 && streak > 0.0 && r.x < 0.0 && r.x > -0.3 * (1.0 - fade) && alpha < 0.5) {
			color = CRIMSON;
			alpha = 1.0;
		}
	}
	// La pluie : gouttes et braises sur tout le disque.
	for (int i = 0; i < int(RAIN); i++) {
		float f = float(i) + 60.0;
		float life = clamp((progress - 0.5 - hash(f) * 0.25) / 0.3, 0.0, 1.0);
		bool ember = mod(f, 3.0) < 0.5;
		vec2 at = vec2((hash(f + 2.0) - 0.5) * 1.4, (hash(f + 3.0) - 0.5) * 1.3);
		at.y += (ember ? -0.28 : 0.42) * life;
		vec2 q = p - at;
		float size = 0.032 * (1.0 - life) + 0.006;
		float shape = ember ? size - (abs(q.x) + abs(q.y)) : size - length(q * vec2(1.0, 0.55));
		if (shape > 0.0 && life > 0.0 && life < 1.0) {
			color = ember ? PALE : CRIMSON;
			alpha = 1.0;
		}
	}
	// Le flash de l'éclatement.
	float flash = 1.0 - clamp(abs(progress - BURST_AT) / 0.06, 0.0, 1.0);
	if (flash * 0.42 - d > 0.0) {
		color = PALE;
		alpha = 1.0;
	}
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.86, 1.0, progress)) * COLOR.a);
}
