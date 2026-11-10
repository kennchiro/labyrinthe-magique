shader_type canvas_item;
render_mode blend_mix;

// MINUIT, tout l'écran : la nuit tombe, une lune rouge se lève au-dessus de lui, et la faux géante traverse
// l'écran de gauche à droite, puis REVIENT de droite à gauche ; chaque passage laisse une entaille de braise. Les
// âmes de ce qu'elle a pris montent vers la lune à la fin. ⚠️ Le quad couvre deux fois l'écran, comme l'Heure dernière.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

const float PASS1_FROM = 0.26;
const float PASS1_TO = 0.46;
const float PASS2_FROM = 0.625;
const float PASS2_TO = 0.82;

vec4 scythe(vec2 s, float blade_x, float facing, float slope) {
	vec2 b = vec2((s.x - blade_x) * facing, s.y + s.x * slope);
	vec4 c = vec4(0.0);
	float haft = min(0.02 - abs(b.y - 0.62 - (b.x + 0.5) * 0.15), min(b.x + 1.5, -0.32 - b.x));
	if (haft > 0.0) {
		c = vec4(F_BONE, 1.0);
	}
	vec4 blade = f_blade(b - vec2(-0.5, 0.0), 0.72, 0.22, PI, 1.0);
	return f_over(blade, c);
}

void fragment() {
	vec2 s = (UV - 0.5) * 4.4;
	float t = progress;
	float fall = smoothstep(0.0, 0.18, t);
	float leave = smoothstep(0.88, 1.0, t);
	vec4 color = vec4(mix(F_BLACK, F_EMBER, 0.06), 0.78 * fall * (1.0 - leave));
	// La lune rouge.
	vec2 m = s - vec2(0.0, -0.42);
	float moon = smoothstep(0.13, 0.125, length(m));
	float crater = texture(noise, m * 2.0 + seed).r;
	color = f_over(vec4(mix(F_EMBER, vec3(0.55, 0.1, 0.08), crater * 0.6), moon * smoothstep(0.08, 0.25, t) * (1.0 - leave)), color);
	color = f_over(vec4(F_EMBER, f_glow(length(m), 0.3) * 0.25 * fall * (1.0 - leave)), color);
	// Les deux entailles, l'aller penché d'un côté, le retour de l'autre.
	float t1 = clamp((t - PASS1_FROM) / (PASS1_TO - PASS1_FROM), 0.0, 1.0);
	float t2 = clamp((t - PASS2_FROM) / (PASS2_TO - PASS2_FROM), 0.0, 1.0);
	float x1 = mix(-2.2, 2.2, t1);
	float x2 = mix(2.2, -2.2, t2);
	float slit1 = step(abs(s.y + s.x * 0.18), 0.026) * step(s.x, x1) * step(0.0, t1) * (1.0 - leave) * step(PASS1_FROM, t);
	float slit2 = step(abs(s.y + 0.1 - s.x * 0.18), 0.026) * step(x2, s.x) * (1.0 - leave) * step(PASS2_FROM, t);
	color = f_over(vec4(F_EMBER, max(slit1, slit2)), color);
	if (t1 > 0.0 && t1 < 1.0) {
		color = f_over(scythe(s, x1, 1.0, 0.18), color);
	}
	if (t2 > 0.0 && t2 < 1.0) {
		color = f_over(scythe(vec2(s.x, s.y + 0.1), x2, -1.0, -0.18), color);
	}
	// Les âmes qui montent vers la lune.
	float rise = smoothstep(0.82, 1.0, t);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		vec2 from = vec2((f_hash(f, seed) - 0.5) * 3.0, 0.6 + f_hash(f, 4.0) * 0.4);
		vec2 at = mix(from, vec2(0.0, -0.42), rise);
		color = f_over(f_soul(s - at, 0.028, normalize(from - vec2(0.0, -0.42)), step(0.82, t) * (1.0 - smoothstep(0.95, 1.0, t))), color);
	}
	COLOR = color;
}
