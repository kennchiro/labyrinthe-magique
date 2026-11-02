shader_type canvas_item;
render_mode blend_mix;

// LE BOND DE SOUFRE, en trois temps :
//   1. LE SOL SE FEND : un anneau déchiqueté s'ouvre, vu en plongée comme tout ce qui est au sol.
//   2. LES FLAMMES MONTENT : des langues hautes et ondulantes, noires au bord, cramoisies, à cœur d'or.
//   3. LA RETOMBÉE : elles se tassent dans le sol, des gouttes retombent et des braises s'élèvent.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float TONGUES = 8.0;
const float DROPS = 10.0;
const float GROUND_Y = 0.42;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = BLACK;
	float alpha = 0.0;
	float grow = 1.0 - pow(1.0 - clamp(progress / 0.3, 0.0, 1.0), 3.0);
	float sink = smoothstep(0.5, 0.95, progress);
	// L'anneau au sol : sombre et plein, puis il se referme.
	vec2 g = vec2(p.x, (p.y - GROUND_Y) * 2.5);
	float a = atan(g.y, g.x) + seed;
	float reach = 0.66 * grow * (1.0 - sink * 0.6);
	float jag = 0.05 * abs(sin(a * 7.0)) + 0.025 * abs(sin(a * 17.0));
	float pit = reach + jag - length(g);
	if (pit > 0.0) {
		color = mix(BLACK, DEEP, smoothstep(0.05, 0.0, pit));
		color = mix(color, CRIMSON, smoothstep(0.03, 0.0, pit));
		alpha = 0.92;
	}
	// Les langues, de la plus lointaine à la plus proche.
	for (int i = 0; i < int(TONGUES); i++) {
		float f = float(i);
		float angle = 3.14159 + (f + 0.5) / TONGUES * 3.14159 * 2.0;
		float depth = sin(angle);
		vec2 foot = vec2(cos(angle) * 0.55 * grow, GROUND_Y + depth * 0.22 * grow);
		float tall = (0.72 + 0.58 * hash(f)) * grow * (1.0 - sink * 0.92);
		float up = (foot.y - p.y) / max(tall, 0.001);
		if (up < -0.03 || up > 1.0) {
			continue;
		}
		float sway = 0.06 * sin(up * 6.0 + progress * 16.0 + f * 2.4) * up;
		float w = 0.15 * pow(max(1.0 - up, 0.0), 0.9) * smoothstep(-0.05, 0.12, up);
		float tongue = w - abs(p.x - foot.x - sway);
		if (tongue > 0.0) {
			vec3 inside = mix(DEEP, CRIMSON, smoothstep(0.012, 0.04, tongue));
			inside = mix(inside, GOLD, smoothstep(0.065, 0.085, tongue) * (1.0 - up));
			inside = mix(inside, PALE, smoothstep(0.09, 0.11, tongue) * (1.0 - up));
			color = mix(BLACK, inside, smoothstep(0.0, 0.012, tongue));
			alpha = 1.0;
		}
	}
	for (int i = 0; i < int(DROPS); i++) {
		float f = float(i);
		float angle = hash(f) * TAU;
		float life = clamp((progress - 0.1 - hash(f + 4.0) * 0.2) / 0.7, 0.0, 1.0);
		bool ember = mod(f, 3.0) < 0.5;
		vec2 at = vec2(cos(angle) * (0.25 + life * 0.5), GROUND_Y - life * (ember ? 1.15 : 0.7) * (hash(f + 6.0) + 0.4));
		if (!ember) {
			at.y += life * life * 0.9;
		}
		vec2 d = p - at;
		float size = 0.042 * (1.0 - life) + 0.006;
		float shape = ember ? size - (abs(d.x) + abs(d.y)) : size - length(d * vec2(1.0, 0.65));
		if (shape > 0.0 && life > 0.0 && life < 1.0) {
			color = ember ? PALE : CRIMSON;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
