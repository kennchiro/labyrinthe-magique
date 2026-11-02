shader_type canvas_item;
render_mode blend_mix;

// L'ENTAILLE : une fente en diagonale qui s'ouvre d'un coup et se referme, cœur de braise, bords
// rouges et cerne noir, avec des braises projetées de part et d'autre.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 EMBER = vec3(1.0, 0.416, 0.169);
const vec3 RED = vec3(0.886, 0.22, 0.165);
const vec3 BLACK = vec3(0.078, 0.075, 0.11);
const vec3 BONE = vec3(0.902, 0.875, 0.792);
const float SPARKS = 9.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 r = vec2(p.x * 0.707 - p.y * 0.707, p.x * 0.707 + p.y * 0.707);
	float run = clamp(progress / 0.22, 0.0, 1.0);
	float span = 0.86 * run;
	float along = clamp(abs(r.x) / max(span, 0.001), 0.0, 1.0);
	float open = (1.0 - smoothstep(0.35, 1.0, progress)) * smoothstep(0.0, 0.14, progress);
	float heat = 0.13 * open * (1.0 - along * along) - abs(r.y);
	heat = min(heat, span - abs(r.x));
	vec3 color = mix(RED, EMBER, smoothstep(0.012, 0.04, heat));
	color = mix(color, BONE, smoothstep(0.05, 0.085, heat));
	color = mix(BLACK, color, smoothstep(0.0, 0.012, heat));
	float alpha = smoothstep(-0.006, 0.0, heat);
	for (int i = 0; i < int(SPARKS); i++) {
		float f = float(i);
		float side = mod(f, 2.0) * 2.0 - 1.0;
		float life = clamp(progress * 1.4 - hash(f) * 0.25, 0.0, 1.0);
		float at_x = (hash(f + 3.0) - 0.5) * 1.2;
		vec2 at = vec2(at_x * 0.707 + side * life * 0.5 * 0.707, -at_x * 0.707 + side * life * 0.5 * 0.707);
		at.y += life * life * 0.25;
		float spark = (0.028 * (1.0 - life) + 0.006) - length(p - at);
		if (spark > 0.0 && life > 0.0 && life < 1.0 && alpha < 0.5) {
			color = hash(f + 7.0) > 0.5 ? EMBER : RED;
			alpha = 1.0 - life * life;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
