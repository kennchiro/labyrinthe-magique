shader_type canvas_item;
render_mode blend_mix;

// LE SOL EN FEU DU DRAGON : une flaque de terre brûlée fendue de braises, des langues de flamme
// basses qui la lèchent, et une fumée noire qui monte. Le feu prend vite, tient, puis SE RÉDUIT en
// braises au lieu de s'estomper : c'est la case qui refroidit, pas l'image qui pâlit.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.416);
const vec3 EMBER = vec3(1.0, 0.353, 0.063);
const vec3 LAVA = vec3(0.82, 0.125, 0.047);
const vec3 DEEP = vec3(0.541, 0.086, 0.047);
const vec3 SMOKE = vec3(0.11, 0.071, 0.063);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	// Le quad fait au moins 0,9 case de rayon : le brasier n'en occupe que les deux tiers, dans sa case.
	vec2 p = (UV - 0.5) * 2.0 * 1.55;
	float grow = smoothstep(0.0, 0.1, progress);
	float fade = 1.0 - smoothstep(0.68, 1.0, progress);
	float life = grow * fade;
	vec3 color = SMOKE;
	float a = 0.0;
	// La terre brûlée : une flaque sombre et aplatie, fendue de braises qui s'éteignent.
	vec2 g = vec2(p.x, (p.y - 0.6) * 2.8);
	float pool = 0.84 * grow * (0.5 + 0.5 * fade) - length(g);
	if (pool > 0.0) {
		float crack = abs(sin(g.x * 9.0 + seed * 7.0 + sin(g.y * 6.0 + seed) * 1.6));
		color = crack < 0.2 * fade + 0.06 ? (fade > 0.45 ? EMBER : DEEP) : SMOKE;
		a = 0.9;
	}
	// La fumée noire, derrière les flammes : des volutes qui montent et se défont.
	for (int j = 0; j < 3; j++) {
		float f = float(j);
		float cycle = fract(TIME * 0.42 + hash(f + 9.0));
		vec2 c = vec2((hash(f + 5.0) - 0.5) * 0.8 + sin(cycle * 6.0 + f) * 0.12, 0.15 - cycle * 1.0);
		float r = (0.1 + cycle * 0.16) * life * (1.0 - cycle);
		if (r - length(p - c) > 0.0 && a < 0.5) {
			color = SMOKE;
			a = 0.78;
		}
	}
	// Les langues de flamme, basses et nerveuses.
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float x = (f - 2.0) * 0.3 + (hash(f) - 0.5) * 0.12;
		float base = 0.6 + abs(f - 2.0) * 0.04;
		float top = base - life * (0.3 + hash(f + 3.0) * 0.4) * (0.75 + 0.25 * sin(TIME * (9.0 + f) + f * 2.3 + seed));
		float y = clamp((base - p.y) / max(base - top, 0.01), 0.0, 1.0);
		float wave = sin(p.y * 9.0 - TIME * 12.0 + f * 1.7 + seed) * 0.05 * y;
		float width = 0.17 * pow(1.0 - y, 0.7) * life;
		float flame = width - abs(p.x - x - wave);
		if (flame > 0.0 && p.y < base && p.y > top) {
			color = flame > width * 0.6 ? PALE : (flame > width * 0.3 ? EMBER : LAVA);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
